#!/usr/bin/env python3
"""
Workflow MCP Server
extracted from mcp-structure.py
"""

import asyncio
import json
import sys
from typing import Any, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Tool,
    Resource,
    Prompt,
    TextContent,
    ImageContent,
    EmbeddedResource,
)

class WorkflowMCPServer:
    """
    Clean implementation of the MCP Server workflow.
    """
    
    def __init__(self):
        # 1. Initialization
        self.server = Server("workflow-mcp-server")
        self.data_store = {}
    
    def register_tools(self):
        # 2. Register tools definition
        @self.server.list_tools()
        async def list_tools() -> list[Tool]:
            return [
                Tool(
                    name="calculate",
                    description="Performs basic mathematical calculations",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "operation": {"type": "string", "enum": ["add", "subtract", "multiply", "divide"]},
                            "a": {"type": "number"},
                            "b": {"type": "number"}
                        },
                        "required": ["operation", "a", "b"]
                    }
                ),
                Tool(
                    name="store_data",
                    description="Stores a key-value pair",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "key": {"type": "string"},
                            "value": {"type": "string"}
                        },
                        "required": ["key", "value"]
                    }
                ),
                Tool(
                    name="retrieve_data",
                    description="Retrieves a value by key",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "key": {"type": "string"}
                        },
                        "required": ["key"]
                    }
                ),
                Tool(
                    name="echo",
                    description="Echoes back the input text",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "text": {"type": "string"}
                        },
                        "required": ["text"]
                    }
                )
            ]
    
    def register_tool_handlers(self):
        # 3. Register tool handlers (implementation)
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Any) -> list[TextContent]:
            if name == "calculate":
                op = arguments["operation"]
                a = arguments["a"]
                b = arguments["b"]
                
                if op == "add": result = a + b
                elif op == "subtract": result = a - b
                elif op == "multiply": result = a * b
                elif op == "divide": 
                    result = a / b if b != 0 else "Error: Division by zero"
                
                return [TextContent(type="text", text=f"Result: {a} {op} {b} = {result}")]
            
            elif name == "store_data":
                self.data_store[arguments["key"]] = arguments["value"]
                return [TextContent(type="text", text=f"Stored: {arguments['key']} = {arguments['value']}")]
            
            elif name == "retrieve_data":
                value = self.data_store.get(arguments["key"], "Key not found")
                return [TextContent(type="text", text=f"Retrieved: {arguments['key']} = {value}")]
            
            elif name == "echo":
                return [TextContent(type="text", text=f"Echo: {arguments['text']}")]
            
            return [TextContent(type="text", text=f"Unknown tool: {name}")]
    
    def register_resources(self):
        # 4. Register resources definition
        @self.server.list_resources()
        async def list_resources() -> list[Resource]:
            return [
                Resource(uri="resource://server-info", name="Server Information", mimeType="application/json"),
                Resource(uri="resource://data-store", name="Data Store Contents", mimeType="application/json"),
                Resource(uri="resource://welcome", name="Welcome Message", mimeType="text/plain")
            ]
    
    def register_resource_handlers(self):
        # 5. Register resource handlers (implementation)
        @self.server.read_resource()
        async def read_resource(uri: str) -> str:
            if uri == "resource://server-info":
                return json.dumps({
                    "name": "workflow-mcp-server",
                    "version": "1.0.0",
                    "status": "active"
                }, indent=2)
            
            elif uri == "resource://data-store":
                return json.dumps(self.data_store, indent=2)
            
            elif uri == "resource://welcome":
                return "Welcome to the Workflow MCP Server!"
            
            return f"Resource not found: {uri}"
    
    def register_prompts(self):
        # 6. Register prompts definition
        @self.server.list_prompts()
        async def list_prompts() -> list[Prompt]:
            return [
                Prompt(
                    name="analyze-data",
                    description="Analyze stored data",
                    arguments=[
                        {"name": "key", "description": "The key to analyze", "required": True}
                    ]
                )
            ]
    
    def register_prompt_handlers(self):
        # 7. Register prompt handlers (implementation)
        @self.server.get_prompt()
        async def get_prompt(name: str, arguments: dict[str, str] | None) -> str:
            if name == "analyze-data":
                key = arguments.get("key", "") if arguments else ""
                value = self.data_store.get(key, "No data found")
                return f"Analyze the data for key '{key}'. Value: {value}"
            
            return f"Prompt not found: {name}"
    
    def setup_lifecycle_handlers(self):
        # 8. Lifecycle handlers (if any)
        pass
    
    async def run(self):
        # 9. Run the server
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                self.server.create_initialization_options()
            )

async def main():
    # Execute the workflow
    server = WorkflowMCPServer()
    server.register_tools()
    server.register_tool_handlers()
    server.register_resources()
    server.register_resource_handlers()
    server.register_prompts()
    server.register_prompt_handlers()
    server.setup_lifecycle_handlers()
    
    # Run server
    await server.run()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
