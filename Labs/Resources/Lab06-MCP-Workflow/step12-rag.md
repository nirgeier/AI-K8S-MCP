```python
#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
Built step by step for learning purposes.
Step 12: RAG (Retrieval Augmented Generation)
"""

import asyncio
import csv
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
  GetPromptResult,
  PromptMessage,
)
import sys

# Initialize an in-memory users
users = []

def load_users(csv_file_path: str):
  """Load users from a CSV file."""
  global users
  users = []

  try:
    with open(csv_file_path, 'r', encoding='utf-8') as f:
      reader = csv.DictReader(f)
      for i, row in enumerate(reader):
        # Assuming CSV has 'content' and 'id' columns or similar
        # Adjust column names as needed
        content = row.get('content') or row.get('text') or list(row.values())[0]
        doc_id = row.get('id') or f"doc_{i}"

        if content:
          users.append({"id": doc_id, "content": content})

    print(f"Loaded {len(users)} documents into users.")
  except Exception as e:
    print(f"Error loading users: {e}")

# Load the users
# Make sure you have a 'users.csv' file in the same directory
# Format: id,content
load_users("users.csv")

class CompleteMCPServer:
  """
  A comprehensive MCP Server implementation showcasing all protocol features.

  This class demonstrates:
  - Server initialization
  - Tool registration and execution
  - Resource management
  - Prompt templates
  - Request handling
  - RAG capabilities
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
        ),
        Tool(
          name="filter_users_by_city",
          description="Filter and return users who live in a specific city",
          inputSchema={
            "type": "object",
            "properties": {
              "city": {
                "type": "string",
                "description": "The city to filter users by"
              }
            },
            "required": ["city"]
          }
        ),
        Tool(
          name="filter_users_by_age",
          description="Filter and return users who are older than the specified minimum age",
          inputSchema={
            "type": "object",
            "properties": {
              "min_age": {
                "type": "number",
                "description": "The minimum age to filter users by"
              }
            },
            "required": ["min_age"]
          }
        )
      ]

    print("Tools registered: calculate, store_data, retrieve_data, echo, filter_users_by_city, filter_users_by_age")

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

      elif name == "filter_users_by_city":
        city = arguments.get("city", "")
        filtered_users = []
        target_city = city.lower().strip()

        for user in users:
          # Assuming user dict has 'city' key (loaded from CSV)
          u_city = user.get("city", "").lower()

          if u_city == target_city:
             filtered_users.append(f"User {user.get('id')}: {user.get('content')} (City: {u_city})")

        if not filtered_users:
          result = f"No users found in {city}."
        else:
          result = "\n".join(filtered_users)

        return [TextContent(type="text", text=result)]

      elif name == "filter_users_by_age":
        min_age = arguments.get("min_age", 0)
        filtered_users = []

        for user in users:
          # Assuming user dict has 'age' (or 'value') key
          u_age = user.get("age", user.get("value", 0))

          try:
            u_age = int(u_age)
          except ValueError:
            continue

          if u_age > min_age:
             filtered_users.append(f"User {user.get('id')}: {user.get('content')} (Age: {u_age})")

        if not filtered_users:
          result = f"No users found older than {min_age}."
        else:
          result = "\n".join(filtered_users)

        return [TextContent(type="text", text=result)]

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
    async def read_resource(uri: Any) -> str:
      """
      Handle resource read requests.
      This is called when a client wants to read a resource.
      """
      # Extract the URI string from the AnyUrl object
      uri_str = str(uri)

      if uri_str == "resource://server-info":
        info = {
          "name": "complete-mcp-server",
          "version": "1.0.0",
          "description": "A comprehensive MCP server implementation",
          "capabilities": {
            "tools": 6,
            "resources": 3,
            "prompts": 2
          }
        }
        return json.dumps(info, indent=2)

      elif uri_str == "resource://data-store":
        return json.dumps(self.data_store, indent=2)

      elif uri_str == "resource://welcome":
        return """Welcome to the Complete MCP Server!

This server demonstrates all MCP protocol capabilities:
- Tools: Execute operations and computations
- Resources: Access data and information
- Prompts: Get structured prompt templates
- RAG: Retrieval Augmented Generation for user filtering

Explore the available tools and resources to see what this server can do."""

      else:
        raise ValueError(f"Unknown resource: {uri_str}")

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
    async def get_prompt(name: str, arguments: dict) -> GetPromptResult:
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

        return GetPromptResult(
          messages=[
            PromptMessage(
              role="user",
              content=TextContent(type="text", text=prompt_text)
            )
          ]
        )

      elif name == "calculate-scenario":
        operation = arguments.get("operation", "add")

        prompt_text = f"""Let's work through a {operation} calculation scenario.

Use the calculate tool with the operation '{operation}'.
For example:
- Choose two numbers (a and b)
- Execute: calculate(operation="{operation}", a=10, b=5)
- Explain the result

This demonstrates how to use computational tools in the MCP server."""

        return GetPromptResult(
          messages=[
            PromptMessage(
              role="user",
              content=TextContent(type="text", text=prompt_text)
            )
          ]
        )

      else:
        return GetPromptResult(
          messages=[
            PromptMessage(
              role="user",
              content=TextContent(
                type="text",
                text=f"Error: Unknown prompt '{name}'"
              )
            )
          ]
        )

    print("Prompt handlers implemented")

  def setup_lifecycle_handlers(self):
    """Setup lifecycle management (conceptual for MCP)."""
    print("Lifecycle management configured")

  async def run(self):
    """Run the MCP server."""
    # Initialize everything
    self.register_tools()
    self.register_tool_handlers()
    self.register_resources()
    self.register_resource_handlers()
    self.register_prompts()
    self.register_prompt_handlers()
    self.setup_lifecycle_handlers()

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
