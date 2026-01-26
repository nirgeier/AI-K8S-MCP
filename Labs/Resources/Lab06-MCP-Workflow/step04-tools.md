```python
#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
Built step by step for learning purposes.
Step 4: Register Tools
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

  async def run(self):
    """Run the MCP server."""
    # Initialize everything
    self.register_tools()
    
    # Connect to stdio
    async with stdio_server() as (read_stream, write_stream):
      print("Server running on stdio...")
      await self.server.run(
        read_stream,
        write_stream,
        self.server.create_initialization_options()
      )

async def main():
  """Main entry point."""
  server = CompleteMCPServer()
  await server.run()

if __name__ == "__main__":
  try:
    asyncio.run(main())
  except KeyboardInterrupt:
    print("Server stopped by user")
  except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
```
