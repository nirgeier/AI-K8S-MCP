import asyncio
import json
import os
import sqlite3
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

import ollama
import pandas as pd
import requests
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    TextResourceContents,
    Prompt,
    GetPromptResult,
    CallToolResult,
    ListResourcesResult,
    ListToolsResult,
    ReadResourceResult,
    ListPromptsResult,
)

class CompleteOllamaMCPServer:
    def __init__(self):
        self.server = Server("complete-ollama-mcp-server")
        self.data_store = {}
        self.db_path = "data.db"
        self.ollama_client = ollama.Client()
        self.country_data = self._load_country_data()
        self._setup_handlers()

    def _load_country_data(self):
        """Load country information from CSV files for RAG retrieval."""
        data = {}
        script_dir = Path(__file__).parent
        info_types = ['capital', 'population', 'height', 'foundation_year']
        for info_type in info_types:
            try:
                file_path = script_dir / f'{info_type}.csv'
                df = pd.read_csv(file_path)
                # Convert country names to lowercase for case-insensitive matching
                data[info_type] = dict(zip(df['country'].str.lower(), df[info_type]))
            except Exception as e:
                print(f"Error loading {info_type}.csv: {e}", file=sys.stderr)
                data[info_type] = {}
        return data

    def _setup_handlers(self):
        # Register handlers manually since we can't use @self.server decorators in class body
        self.server.list_tools()(self.list_tools)
        self.server.call_tool()(self.call_tool)
        self.server.list_resources()(self.list_resources)
        self.server.read_resource()(self.read_resource)
        self.server.list_prompts()(self.list_prompts)
        self.server.get_prompt()(self.get_prompt)

    async def list_tools(self) -> List[Tool]:
        return [
            Tool(
                name="country_info",
                description="Get country information using RAG from Excel databases",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "country": {
                            "type": "string",
                            "description": "The country name to get information for"
                        },
                        "info_types": {
                            "type": "array",
                            "items": {"type": "string", "enum": ["capital", "population", "height", "foundation_year"]},
                            "description": "Types of information to retrieve"
                        }
                    },
                    "required": ["country"]
                }
            ),
            Tool(
                name="read_file",
                description="Read and analyze file contents with metadata",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "filepath": {
                            "type": "string",
                            "description": "Absolute path to the file to read"
                        },
                        "max_size": {
                            "type": "number",
                            "default": 1048576,
                            "description": "Maximum file size in bytes (default 1MB)"
                        },
                        "encoding": {
                            "type": "string",
                            "default": "utf-8",
                            "description": "File encoding"
                        }
                    },
                    "required": ["filepath"]
                }
            ),
            Tool(
                name="query_database",
                description="Execute SELECT queries on SQLite database",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "SELECT SQL query to execute"
                        },
                        "database": {
                            "type": "string",
                            "default": "data.db",
                            "description": "Database file path"
                        }
                    },
                    "required": ["query"]
                }
            )
        ]

    async def call_tool(self, name: str, arguments: Dict[str, Any]) -> List[TextContent]:
        if name == "country_info":
            country = arguments.get("country", "").lower()
            info_types = arguments.get("info_types", [])

            if not country:
                raise ValueError("Country name is required")

            if not info_types:
                info_types = ["capital", "population", "height", "foundation_year"]

            retrieved_info = {}
            for info_type in info_types:
                # Safe access to nested dictionary
                type_data = self.country_data.get(info_type, {})
                if country in type_data:
                    retrieved_info[info_type] = type_data[country]
                else:
                    retrieved_info[info_type] = f"Information not available (Data loaded: {len(type_data)} records)"

            # Use Ollama to generate a formatted response
            prompt = f"Format the following information about {country.title()} into a nice, readable response: {json.dumps(retrieved_info, indent=2)}"

            try:
                # Use llama3.2 as detected on your system
                response = self.ollama_client.generate(
                    model='llama3.2', 
                    prompt=prompt,
                    options={'temperature': 0.7, 'max_tokens': 300}
                )

                result = response['response'].strip()

                return [TextContent(type="text", text=result)]

            except Exception as e:
                # Fallback if Ollama fails
                return [TextContent(type="text", text=f"Error getting AI response: {str(e)}\n\nRaw Data: {retrieved_info}")]

        elif name == "read_file":
            filepath = arguments.get("filepath", "")
            max_size = arguments.get("max_size", 1048576)
            encoding = arguments.get("encoding", "utf-8")

            if not filepath:
                raise ValueError("File path is required")

            path = Path(filepath)
            if not path.exists():
                raise ValueError(f"File not found: {filepath}")

            if not path.is_file():
                raise ValueError(f"Path is not a file: {filepath}")

            try:
                file_size = path.stat().st_size
                if file_size > max_size:
                    raise ValueError(f"File too large: {file_size} bytes (max: {max_size})")

                with open(path, 'r', encoding=encoding) as f:
                    content = f.read()

                metadata = f"File: {path.name}\nSize: {file_size} bytes\nEncoding: {encoding}\n\n"
                result = metadata + "Content:\n" + content

                return [TextContent(type="text", text=result)]

            except Exception as e:
                return [TextContent(type="text", text=f"Error reading file: {str(e)}")]

        elif name == "query_database":
            query = arguments.get("query", "").strip()
            database = arguments.get("database", self.db_path)

            if not query:
                raise ValueError("Query is required")

            if not query.upper().startswith("SELECT"):
                raise ValueError("Only SELECT queries are allowed")

            try:
                conn = sqlite3.connect(database)
                cursor = conn.cursor()

                cursor.execute(query)
                rows = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description]

                conn.close()

                if not rows:
                    result = "No results found."
                else:
                    # Format as table
                    result = "| " + " | ".join(columns) + " |\n"
                    result += "|" + "|".join(["---"] * len(columns)) + "|\n"
                    for row in rows:
                        result += "| " + " | ".join(str(cell) for cell in row) + " |\n"

                return [TextContent(type="text", text=result)]

            except Exception as e:
                return [TextContent(type="text", text=f"Database error: {str(e)}")]

        else:
            raise ValueError(f"Unknown tool: {name}")

    async def list_resources(self) -> List[Resource]:
        return [
            Resource(
                uri="resource://server-info",
                name="Server Information",
                description="Basic information about this MCP server",
                mimeType="application/json"
            ),
            Resource(
                uri="resource://ollama-models",
                name="Available Ollama Models",
                description="List of available Ollama models",
                mimeType="application/json"
            )
        ]

    async def read_resource(self, uri: str) -> str:
        uri_str = str(uri).strip()
        
        # Debug log to help diagnose the mismatch
        print(f"DEBUG: Requesting URI: '{uri_str}'", file=sys.stderr)

        # Allow exact match or match without scheme to be robust
        if uri_str == "resource://server-info" or uri_str.endswith("server-info"):
            info = {
                "name": "Complete Ollama MCP Server",
                "version": "1.0.0",
                "capabilities": ["tools", "resources", "ollama-integration"],
                "tools": ["country_info", "read_file", "query_database"],
                "country_database": "193 UN member states with capitals, populations, topographic heights, and foundation years"
            }
            return json.dumps(info, indent=2)

        elif uri_str == "resource://ollama-models" or uri_str.endswith("ollama-models"):
            try:
                models = self.ollama_client.list()
                return json.dumps(models, indent=2)
            except Exception as e:
                return json.dumps({"error": str(e)}, indent=2)

        else:
            raise ValueError(f"Unknown resource: {uri_str}")

    async def list_prompts(self) -> List[Prompt]:
        return [
            Prompt(
                name="analyze-country-data",
                description="Analyze country data and provide insights",
                arguments=[
                    {
                        "name": "country",
                        "description": "Country to analyze",
                        "required": True
                    }
                ]
            )
        ]

    async def get_prompt(self, name: str, arguments: Dict[str, Any]) -> GetPromptResult:
        if name == "analyze-country-data":
            country = arguments.get("country", "Unknown Country")
            prompt_text = f"""Analyze the data for {country} and provide insights:

1. Use the country_info tool to get information about the country's capital, population, topographic height, and foundation year
2. Analyze the retrieved information and provide interesting facts
3. Consider historical context and geographical significance
4. Provide recommendations or interesting trivia based on the data

Please provide a comprehensive country analysis."""

            return GetPromptResult(
                description=f"Country analysis prompt for {country}",
                messages=[
                    {
                        "role": "user",
                        "content": {
                            "type": "text",
                            "text": prompt_text
                        }
                    }
                ]
            )

        else:
            raise ValueError(f"Unknown prompt: {name}")

    def setup_lifecycle_handlers(self):
        # Already handled in _setup_handlers
        pass

    async def run(self):
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(read_stream, write_stream, self.server.create_initialization_options())


async def main():
    server = CompleteOllamaMCPServer()
    await server.run()

if __name__ == "__main__":
    asyncio.run(main())