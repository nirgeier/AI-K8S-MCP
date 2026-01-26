#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
Built step by step for learning purposes.
Step 5: Register Tool Handlers
"""

import asyncio
import json
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
import sys

class CompleteMCPServer:
    """
    A comprehensive MCP Server implementation showcasing all protocol features.
    
    This class demonstrates:
    - Server initialization
    - Tool registration and execution
    - Resource management
    - Prompt templates
    - Request handling
    """
    
    def __init__(self):
        """Initialize the MCP Server instance."""
        self.server = Server("complete-mcp-server")
        self.data_store = {}  # Simple in-memory data storage
        print("Server instance created successfully!")
    
    def register_tools(self):
        """Register all available tools with the MCP server."""
        
        @self.server.list_tools()
        async def list_tools() -> list[Tool]:
            """
            Return the list of available tools.
            This is called when clients want to discover what tools are available.
            """
            return [
                Tool(
                    name="calculate",
                    description="Perform mathematical operations (add, subtract, multiply, divide)",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "operation": {
                                "type": "string",
                                "enum": ["add", "subtract", "multiply", "divide"],
                                "description": "The operation to perform"
                            },
                            "a": {
                                "type": "number",
                                "description": "First number"
                            },
                            "b": {
                                "type": "number",
                                "description": "Second number"
                            }
                        },
                        "required": ["operation", "a", "b"]
                    }
                ),
                Tool(
                    name="store_data",
                    description="Store a key-value pair in the server's data store",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "key": {
                                "type": "string",
                                "description": "The key to store"
                            },
                            "value": {
                                "type": "string",
                                "description": "The value to store"
                            }
                        },
                        "required": ["key", "value"]
                    }
                ),
                Tool(
                    name="retrieve_data",
                    description="Retrieve a value from the server's data store",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "key": {
                                "type": "string",
                                "description": "The key to retrieve"
                            }
                        },
                        "required": ["key"]
                    }
                ),
                Tool(
                    name="echo",
                    description="Echo back the input text",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "text": {
                                "type": "string",
                                "description": "Text to echo back"
                            }
                        },
                        "required": ["text"]
                    }
                )
            ]
        
        print("Tools registered: calculate, store_data, retrieve_data, echo")

    def register_tool_handlers(self):
        """Implement the actual logic for each tool."""
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Any) -> list[TextContent]:
            """
            Handle tool execution requests.
            This is called when a client wants to execute a tool.
            """
            if name == "calculate":
                operation = arguments.get("operation")
                a = arguments.get("a")
                b = arguments.get("b")
                
                if operation == "add":
                    result = a + b
                elif operation == "subtract":
                    result = a - b
                elif operation == "multiply":
                    result = a * b
                elif operation == "divide":
                    if b == 0:
                        return [TextContent(
                            type="text",
                            text="Error: Cannot divide by zero"
                        )]
                    result = a / b
                else:
                    return [TextContent(
                        type="text",
                        text=f"Error: Unknown operation '{operation}'"
                    )]
                
                return [TextContent(
                    type="text",
                    text=f"Result: {a} {operation} {b} = {result}"
                )]
            
            elif name == "store_data":
                key = arguments.get("key")
                value = arguments.get("value")
                self.data_store[key] = value
                return [TextContent(
                    type="text",
                    text=f"Stored: {key} = {value}"
                )]
            
            elif name == "retrieve_data":
                key = arguments.get("key")
                value = self.data_store.get(key)
                if value is None:
                    return [TextContent(
                        type="text",
                        text=f"Error: Key '{key}' not found"
                    )]
                return [TextContent(
                    type="text",
                    text=f"Retrieved: {key} = {value}"
                )]
            
            elif name == "echo":
                text = arguments.get("text")
                return [TextContent(
                    type="text",
                    text=f"Echo: {text}"
                )]
            
            else:
                return [TextContent(
                    type="text",
                    text=f"Error: Unknown tool '{name}'"
                )]
        
        print("Tool handlers implemented")
