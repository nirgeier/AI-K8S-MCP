```python
#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
Built step by step for learning purposes.
Step 10: Lifecycle Handlers
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

    def register_resources(self):
        """Register resources that clients can access."""
        
        @self.server.list_resources()
        async def list_resources() -> list[Resource]:
            """
            Return the list of available resources.
            This is called when clients want to discover what resources are available.
            """
            return [
                Resource(
                    uri="resource://server-info",
                    name="Server Information",
                    description="Information about this MCP server",
                    mimeType="application/json"
                ),
                Resource(
                    uri="resource://data-store",
                    name="Data Store",
                    description="Current contents of the data store",
                    mimeType="application/json"
                ),
                Resource(
                    uri="resource://welcome",
                    name="Welcome Message",
                    description="Welcome message and server capabilities",
                    mimeType="text/plain"
                )
            ]
        
        print("Resources registered: server-info, data-store, welcome")

    def register_resource_handlers(self):
        """Implement resource retrieval logic."""
        
        @self.server.read_resource()
        async def read_resource(uri: str) -> str:
            """
            Handle resource read requests.
            This is called when a client wants to read a resource.
            """
            if uri == "resource://server-info":
                info = {
                    "name": "complete-mcp-server",
                    "version": "1.0.0",
                    "description": "A comprehensive MCP server implementation",
                    "capabilities": {
                        "tools": 4,
                        "resources": 3,
                        "prompts": 2
                    }
                }
                return json.dumps(info, indent=2)
            
            elif uri == "resource://data-store":
                return json.dumps(self.data_store, indent=2)
            
            elif uri == "resource://welcome":
                return """Welcome to the Complete MCP Server!

This server demonstrates all MCP protocol capabilities:
- Tools: Execute operations and computations
- Resources: Access data and information
- Prompts: Get structured prompt templates

Explore the available tools and resources to see what this server can do."""
            
            else:
                raise ValueError(f"Unknown resource: {uri}")
        
        print("Resource handlers implemented")

    def register_prompts(self):
        """Register prompt templates for clients."""
        
        @self.server.list_prompts()
        async def list_prompts() -> list[Prompt]:
            """
            Return the list of available prompts.
            This is called when clients want to discover what prompts are available.
            """
            return [
                Prompt(
                    name="analyze-data",
                    description="Analyze data stored in the server",
                    arguments=[
                        {
                            "name": "key",
                            "description": "The key of the data to analyze",
                            "required": True
                        }
                    ]
                ),
                Prompt(
                    name="calculate-scenario",
                    description="Walk through a calculation scenario",
                    arguments=[
                        {
                            "name": "operation",
                            "description": "The operation to demonstrate (add, subtract, multiply, divide)",
                            "required": True
                        }
                    ]
                )
            ]
        
        print("Prompts registered: analyze-data, calculate-scenario")

    def register_prompt_handlers(self):
        """Implement prompt generation logic."""
        
        @self.server.get_prompt()
        async def get_prompt(name: str, arguments: dict) -> list[TextContent]:
            """
            Handle prompt generation requests.
            This is called when a client wants to get a prompt.
            """
            if name == "analyze-data":
                key = arguments.get("key", "unknown")
                value = self.data_store.get(key, "not found")
                
                prompt_text = f"""Analyze the following data from the server:

Key: {key}
Value: {value}

Please provide:
1. A description of what this data represents
2. Any patterns or insights you notice
3. Suggestions for how this data could be used

Use the retrieve_data tool if you need to fetch additional context."""
                
                return [TextContent(type="text", text=prompt_text)]
            
            elif name == "calculate-scenario":
                operation = arguments.get("operation", "add")
                
                prompt_text = f"""Let's work through a {operation} calculation scenario.

Use the calculate tool with the operation '{operation}'.
For example:
- Choose two numbers (a and b)
- Execute: calculate(operation="{operation}", a=10, b=5)
- Explain the result

This demonstrates how to use computational tools in the MCP server."""
                
                return [TextContent(type="text", text=prompt_text)]
            
            else:
                return [TextContent(
                    type="text",
                    text=f"Error: Unknown prompt '{name}'"
                )]
        
        print("Prompt handlers implemented")

    def setup_lifecycle_handlers(self):
        """Setup lifecycle management (conceptual for MCP)."""
        # Note: MCP servers typically don't have explicit lifecycle hooks
        # This is a conceptual method showing where such logic would go
        print("Lifecycle management configured")
```
