# Complete MCP Server - Hands-On Lab

## MCP Server Structure Lab

## Lab Objective

* In this hands-on lab, you'll build a complete MCP (Model Context Protocol) server from scratch. 
* You'll learn how each component works by implementing it yourself, understanding why each piece is necessary, and seeing the complete architecture come together.

## Prerequisites

* Python 3.10 or higher installed
* Basic understanding of Python programming
* Terminal/command line access
* Text editor or IDE

---

## Getting Started

### Step 1: Create Your Project File

1. Create a new file called `mcp_server.py`
2. Open it in your favorite text editor
3. We'll build this server step by step!

---

## Step 01: Adding Imports

* Before we write any code, we need to understand what libraries we're using and why.

### `asyncio` - Asynchronous I/O

!!! question "asyncio"
    
    #### Definition: 
      - `asyncio` is a Python library for writing concurrent code using the async/await syntax.
    
    #### Why:
      - Enables asynchronous programming in Python
      - MCP servers handle multiple concurrent operations (I/O, requests) without blocking
    
    #### Usage: 
      - `async`/`await` keywords, event loops, concurrent task execution

---

### `json` - JavaScript Object Notation

!!! question "json"

    #### Definition:
      - JSON encoding/decoding for data serialization

    #### Why:
      - MCP uses JSON-RPC protocol; resources return JSON data

    #### Usage:
      - `json.dumps()` to serialize Python dicts, `json.loads()` to parse

---

### `typing` - Type Hints

!!! question "typing"

    #### Definition:
      - Type hints for better code documentation and IDE support

    #### Why:
      - Makes code more maintainable and catches type errors early

    #### Usage:
      - Function parameters, return types (Any = any type, Optional = can be None)

---

### `mcp.server` - Core MCP Server

!!! question "mcp.server"

    #### Definition:
      - Core MCP Server class - the foundation of our server

    #### Why:
      - Provides all MCP protocol implementation and lifecycle management

    #### Usage:
      - Create server instance, register handlers, manage connections

---

### `mcp.server.stdio` - Standard I/O Transport

!!! question "mcp.server.stdio"

    #### Definition:
      - Standard Input/Output transport layer for MCP

    #### Why:
      - MCP servers communicate via stdio (standard in/out streams)

    #### Usage:
      - Connects server to clients through stdin/stdout pipes

---

### `mcp.types` - Protocol Types

!!! question "mcp.types"

    #### Definition:
      - MCP protocol type definitions for structured data

    #### Why:
      - Type-safe definitions for all MCP primitives (tools, resources, prompts)

    #### Usage:
      - Tool = executable functions, Resource = readable data, Prompt = templates, TextContent = text responses

---

### `sys` - System Functions

!!! question "sys"

    #### Definition:
      - System-specific parameters and functions

    #### Why:
      - Handle system exits, command-line arguments, and stdio streams

    #### Usage:
      - `sys.exit()` for graceful shutdown, `sys.stdin`/`stdout` for I/O

---

## Step 02: Skeleton Code

## Skeleton 01: `Imports`

  * Set the following imports inside the `mcp_server.py`:

      ```python
    
      #!/usr/bin/env python3
      """
      Complete MCP (Model Context Protocol) Server Implementation
      Built step by step for learning purposes.
      - Enables clients to get ready-to-use prompts
      - Connects prompt templates to actual content
      
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
      ```

  - Create the `requirements.txt` file with the following content:

      ```
      mcp
      ```

  - Install the MCP library:

      ```bash
      pip install -r requirements.txt
      ```

---

## Skeleton 02: `Class`

* Add thislass definition after the imports in your `mcp_server.py` file:

    
    ```python
    class CompleteMCPServer:
        """
        A comprehensive MCP Server implementation showcasing all 
        - Enables clients to get ready-to-use prompts
        - Connects prompt templates to actual content
        protocol features.
      
      This class demonstrates:
      
        - Server initialization
        - Tool registration and execution
        - Resource management
        - Prompt templates
        - Defines the behavior of each prompt
        - Handlers make prompts functional

        - Request handling
      """ 
    ``` 

---

## Skeleton 03: `Constructor`

### Method`__init__` (Constructor)

**Capabilities:**


    - Initializes the MCP Server instance
    - Creates the server object with name and version
    - Sets up the foundation for all MCP operations
    - Enables clients to get ready-to-use prompts
    - Connects prompt templates to actual content
    
  - Prepares data structures for tools, resources, and prompts
 

  **Why This Runs First:**

    - Constructor must run before any other methods
    - Creates the server object that all other methods will use
    - Defines the behavior of each prompt
    - Handlers make prompts functional

  - No other operations can occur without this initialization
  - Sets up the basic state of the server
 
---

* Add this class definition after inside your `CompleteMCPServer` class:

  ```python
  def __init__(self):
      """Initialize the MCP Server instance."""
      self.server = Server("complete-mcp-server")
      self.data_store = {}  # Simple in-memory data storage
      print("Server instance created successfully!")
  ```

### Code break down:

  - `Server("complete-mcp-server")` creates the MCP server with a name
  - `self.data_store = {}` creates an empty dictionary for storing data
  - This object will be used throughout all other methods

---

## Skeleton 04: Register Tools

### Method`register_tools`

**Capabilities:**


    - Registers all available tools with the MCP server
    - Defines tool schemas (name, description, parameters)
    - Makes tools discoverable to clients
    - Enables clients to get ready-to-use prompts
    - Connects prompt templates to actual content
    
  - Sets up the tool execution infrastructure


  **Why This Runs Second:**
    
    - After server initialization, we need to define what tools are available
    - Defines the behavior of each prompt
    - Handlers make prompts functional

  - Tools must be registered before they can be called
  - Defines the capabilities clients can invoke

**What is a Tool?**

  - A tool is an executable function that clients can invoke. 
  - Think of it like an API endpoint that performs an action.
  - Tools have names, descriptions, and input parameters.
  - Clients can discover and call these tools to perform operations.
  - Examples: calculator, data storage, text processing
  - Tools are central to MCP's functionality.
  

---

* Add this method to your class:

    ```python
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
    ```

**What's Happening:**

  - The `@self.server.list_tools()` decorator registers a handler for tool listing
  - Each `Tool` object defines the tool's name, description, and input schema
  - The `inputSchema` uses JSON Schema format to validate inputs
  - When a client calls `list_tools()`, they get this list
  - This makes the tools discoverable and usable by clients

### Hands-On Exercise:

  - Add a new tool called `greeting` that takes a string input `name` and returns a greeting message.
  - Define its name, description, and input schema similar to the other tools.
  - Test it later when we implement tool handlers.
  - Hint: Use the existing tools as a reference for structure.
  - After adding, your `list_tools` method should include the new `greeting` tool.
  - This exercise helps you understand how to define and register new tools in the MCP server.
  - Try to implement it on your own before looking at the solution below!
  
  <details>
  <summary>Solution for Greeting Tool</summary> 

  ```python
  Tool(
      name="greeting",
      description="Return a greeting message for the given name",
      inputSchema={
          "type": "object",
          "properties": {
              "name": {
                  "type": "string",
                  "description": "The name to greet"
              }
          },
          "required": ["name"]
      }
  )
  ```
  </details>

---

## Skeleton 05: Tool(s) Handlers

### Method`register_tool_handlers`

**Capabilities:**

    
    - Implements the actual logic for each tool
    - Handles tool execution requests from clients
    - Processes input parameters and returns results
    - Enables clients to get ready-to-use prompts
    - Connects prompt templates to actual content
    
  - Provides error handling for tool execution
  - Enables dynamic tool functionality


  **Why This Runs Third:**
    
    - After tools are registered, we need to define what happens when 
    - Defines the behavior of each prompt
    - Handlers make prompts functional
    each tool is called
  - **Without handlers, tools are just definitions with no action**
  - Tools need implementation before they can be executed
  - Connects tool schemas to actual functionality
  - Defines the behavior of each tool
  - Handlers make tools operational
  - Clients rely on these handlers to perform tasks
  - This is where the server's capabilities come to life
  - Handlers are essential for a functional MCP server
  - They bridge the gap between tool definition and execution

---

* Add this method to your class:

    ```python
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
    ```

---

**What's Happening:**

  - The `@self.server.call_tool()` decorator registers the execution handler
  - Each tool's logic is in an `if/elif` block
  - Results are wrapped in `TextContent` objects
  - Error handling is included for edge cases (like division by zero)
  - When a client calls a tool, this handler processes the request and returns the output
  - This makes the tools functional and usable by clients

---

### Hands-On Exercise:

  - Implement the handler logic for the `greeting` tool you added earlier.
  - The tool should take the `name` parameter and return a greeting message like "Hello, {name}!".
  - Test it later when we run the server.
  - Hint: Follow the structure of the other tool handlers.
  - After adding, your `call_tool` method should include the new `greeting` tool logic.
  - This exercise helps you understand how to implement tool functionality in the MCP server.
  - Try to implement it on your own before looking at the solution below!
  
  <details>
  <summary>Solution for Greeting Tool Handler</summary> 

  ```python
  elif name == "greeting":
      name = arguments.get("name")
      return [TextContent(
          type="text",
          text=f"Hello, {name}!"
      )]
  ```
  </details>


---

## Skeleton 06: Register Resources

### Method`register_resources`

**Capabilities:**


    - Registers resources that clients can access
    - Defines resource URIs and metadata
    - Makes static and dynamic content available
    - Enables clients to get ready-to-use prompts
    - Connects prompt templates to actual content
    
  - Enables resource discovery and retrieval
  - Provides additional data for clients
  
    - Supports richer interactions with the server
    - Expands server capabilities beyond tools
    - Facilitates data sharing and information access

- Defines the behavior of each prompt
- Handlers make prompts functional

  **Why This Runs Fourth:**

  - After tools are set up, we add resources which provide additional data
  - Resources are complementary to tools
  - Provides data that tools might reference
  

**What is a Resource?**

* A resource is readable data or content. 
* Think of it like a file or endpoint you can read from (but not execute).
* Resources have URIs (like URLs) and metadata (name, description, MIME type).
* Clients can discover and read these resources.
* Examples: server info, data store contents, welcome message
* Resources enhance the server's functionality by providing static or dynamic data.

---

* Add this method to your class:

    ```python
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
    ```

**What's Happening:**

  - The `@self.server.list_resources()` decorator registers the resource listing handler
  - Each `Resource` defines a URI (like a URL), name, description, and MIME type
  - URIs use the `resource://` scheme to identify resources
  - When a client calls `list_resources()`, they get this list
  - This makes the resources discoverable and accessible by clients
  - Resources provide additional data that clients can read 
  - Enhances the server's capabilities beyond just tools

---

### Hands-On Exercise:

  - Add a new resource called `server-author` that return your name as the author of the server.
  - Define its URI, name, description, and MIME type similar to the other resources.
  - Test it later when we implement resource handlers.
  - Hint: Use the existing resources as a reference for structure.
  - After adding, your `list_resources` method should include the new `server-author` resource.
  - This exercise helps you understand how to define and register new resources in the MCP server.
  - Try to implement it on your own before looking at the solution below!

  <details>
  <summary>Solution for Server Stats Resource</summary> 

  ```python
  Resource(
      uri="resource://server-author",
      name="Server Author",
      description="Author of the MCP server",
      mimeType="text/plain"
  )
  ```
  </details>

---

## Skeleton 07: Resource Handlers

### Method`register_resource_handlers`

**Capabilities:**


    - Implements resource retrieval logic
    - Returns actual content for each resource
    - Handles dynamic resource generation
    - Enables clients to get ready-to-use prompts
    - Connects prompt templates to actual content
    
  - Provides resource access control
  - Enables clients to read server data
  
    - Supports various content types (JSON, text)
    - Facilitates data sharing with clients
    - Connects resource definitions to actual data
    - Enhances server usability and information access
    - Defines the behavior of each prompt
    - Handlers make prompts functional


**Why This Runs Fifth:**

  - After resources are registered, we need to implement what content is returned
  - Resources need implementation to return actual data
  - Connects resource URIs to actual content
  - Defines the behavior of each resource
  - Handlers make resources accessible
  - Clients rely on these handlers to read data
  - This is where resource definitions become functional
  - Handlers are essential for a usable MCP server
  - They bridge the gap between resource definition and content delivery
  - Without handlers, resources are just placeholders with no data
  - Handlers bring resources to life

---

* Add this method to your class:

    ```python
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

    ```

---

**What's Happening:**

  - The `@self.server.read_resource()` decorator registers the read handler
  - Each resource URI returns appropriate content
  - JSON resources use `json.dumps()` to serialize data
  - Plain text resources return strings directly
  - When a client reads a resource, this handler processes the request and returns the content
  - This makes the resources functional and usable by clients

---

### Hands-On Exercise:

- Implement the handler logic for the `server-author` resource you added earlier.
- The resource should return your name as plain text.
- Test it later when we run the server.
- Hint: Follow the structure of the other resource handlers.
- After adding, your `read_resource` method should include the new `server-author` resource logic.
- This exercise helps you understand how to implement resource functionality in the MCP server.
- Try to implement it on your own before looking at the solution below!

  <details>
  <summary>Solution for Server Author Resource Handler</summary> 

  ```python
  elif uri == "resource://server-author":
      return "Author: Your Name Here"
  ```
  </details>

--- 

### Handle Errors

  - Add Error Handling for Unknown Resources
  - Add this at the end of the `read_resource` method to handle unknown resources:

    ```python
            else:
                raise ValueError(f"Unknown resource: {uri}")
    ```

---

## Skeleton 08: Register Prompts

### Method `register_prompts`

**Capabilities:**
    
  - Registers prompt templates for clients
  - Defines structured prompts with parameters
  - Enables prompt discovery
  - Enables clients to get ready-to-use prompts
  - Connects prompt templates to actual content
  - Provides reusable prompt patterns
  - Facilitates advanced AI interactions
  - Supports dynamic prompt generation

**Why This Runs Sixth:**

  - Defines the behavior of each prompt
  - Handlers make prompts functional
  - After tools and resources, prompts add higher-level interaction patterns
  - Prompts build on available tools and resources
  - Provides templates for AI assistants

**What is a Prompt?**

* A prompt is a template that guides AI assistants on how to use the server's tools and resources effectively.
* Prompts have names, descriptions, and parameters.
* Clients can discover and request prompts.
* Examples: code review prompt, data analysis prompt
* Prompts enhance the server's capabilities by providing structured interaction patterns.

---

* Add this method to your class:

    ```python
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
    ```

---

**What's Happening:**

  - The `@self.server.list_prompts()` decorator registers the prompt listing handler
  - Each `Prompt` defines a name, description, and arguments
  - Arguments specify what parameters the prompt template needs
  - When a client calls `list_prompts()`, they get this list
  - This makes the prompts discoverable and usable by clients
  - Prompts provide structured templates for AI interactions

---

### Hands-On Exercise:

  - Add a new prompt called `greet-user` that prompts the AI to greet a user by name.
  - Define its name, description, and arguments similar to the other prompts.
  - Test it later when we implement prompt handlers.
  - Hint: Use the existing prompts as a reference for structure.
  - After adding, your `list_prompts` method should include the new `greet-user` prompt.
  - This exercise helps you understand how to define and register new prompts in the MCP server.
  - Try to implement it on your own before looking at the solution below!

  <details>
  <summary>Solution for Greet User Prompt</summary> 

  ```python
  Prompt(
      name="greet-user",
      description="Prompt the AI to greet a user by name",
      arguments=[
          {
              "name": "name",
              "description": "The name of the user to greet",
              "required": True
          }
      ]
  )
  ```
  </details>

---

## Skeleton 09: Prompt Handlers

### Method: `register_prompt_handlers`

**Capabilities:**

  - Implements prompt generation logic
  - Returns formatted prompts with embedded context
  - Handles prompt parameters and customization
  - Provides dynamic prompt content
  - Enables clients to get ready-to-use prompts
  - Connects prompt templates to actual content
  

**Why This Runs Seventh:**

  - After prompts are registered, we implement the logic that generates prompt content
  - Prompts need implementation to generate actual text
  - Connects prompt templates to actual content
  - Defines the behavior of each prompt
  - Handlers make prompts functional

---

* Add this method to your class:

    ```python
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
    ```

---

**What's Happening:**
  
  - The `@self.server.get_prompt()` decorator registers the prompt generation handler
  - Each prompt returns formatted text based on the parameters
  - Prompts can reference tools and resources
  - Dynamic content is generated based on current server state

---

### Hands On:

  - Implement the handler logic for the `greet-user` prompt you added earlier.
  - The prompt should return a greeting message using the provided `name` parameter.
  - Test it later when we run the server.
  - Hint: Follow the structure of the other prompt handlers.
  - After adding, your `get_prompt` method should include the new `greet-user` prompt logic.
  - This exercise helps you understand how to implement prompt functionality in the MCP server.
  - Try to implement it on your own before looking at the solution below!

  <details>
  <summary>Solution for Greet User Prompt Handler</summary> 

  ```python
  elif name == "greet-user":
      name = arguments.get("name", "Guest")
      prompt_text = f"Hello, {name}! Welcome to the Complete MCP Server. How can I assist you today?"
      return [TextContent(type="text", text=prompt_text)]
  ```
  </details>

---

## Skeleton 10: Lifecycle Handlers

### Method: `setup_lifecycle_handlers`

**Capabilities:**
  
  - Handles server initialization events
  - Manages server shutdown procedures
  - Logs server lifecycle events
  - Ensures clean startup and teardown
  - Enables clients to get ready-to-use prompts
  - Connects prompt templates to actual content
  - Maintains server stability and reliability

**Why This Runs Eighth:**

  - After all features are configured, we set up lifecycle management
  - Lifecycle handlers need complete server setup
  - Prepares server for actual runtime operations
  - Defines the behavior of each prompt
  - Handlers make prompts functional
  - Ensures proper resource management during startup/shutdown
  - Critical for long-running server processes
  - Helps prevent resource leaks and data corruption

**Why Servers Need Shutdown Procedures:**

  - Release system resources (memory, file handles, connections)
  - Save any pending data or state to disk
  - Close network connections gracefully
  - Notify connected clients of server shutdown
  - Clean up temporary files and caches
  - Log final statistics and status
  - Prevent data corruption from abrupt termination
  - Allow pending operations to complete

---

* Add this method to your class:

    ```python
    def setup_lifecycle_handlers(self):
        """Setup lifecycle management (conceptual for MCP)."""
        print("Lifecycle management configured")
    ```

---

!!! note "Note"
    
      * Note: MCP servers typically don't have explicit lifecycle hooks
      * This is a conceptual method showing where such logic would go

!!! tip "Tip"

      * You can implement custom startup/shutdown logic here if needed
      * Use this as a placeholder for lifecycle management        
      * The actual "lifecycle" of the server is managed implicitly by:
      * **Startup:** When `asyncio.run(main())` is called and `server.run()` begins the event loop.
      * **Shutdown:** When the process receives a signal (like `KeyboardInterrupt / Ctrl+C`), which is caught in the if `__name__ == "__main__":` block to exit gracefully.

---

**What's Happening:**

  - MCP servers use the standard Python lifecycle
  - Cleanup happens when the server process exits
  - You can use `try/except/finally` blocks in the main function for cleanup
  - This method is a placeholder for lifecycle logic
  - In real-world servers, you might add logging or resource management here
  - This prepares the server for stable operation
  - Enhances reliability during startup and shutdown
  - Critical for production-grade servers
  - Though MCP lacks explicit lifecycle hooks, this method indicates where such logic would be placed
  - It serves as a reminder to consider lifecycle management in server design
  - Helps maintain server health over long runtimes
  - Prepares for future enhancements that may introduce lifecycle events
  - Ensures the server is robust and reliable
  - Maintains server integrity during its lifecycle

---

## Skeleton 11: Run the Server

### Method: `run`

* This is the final method to add to your class.
* It starts the MCP server and begins listening for client requests.

**Capabilities:**
  
  - Starts the MCP server
  - Connects to stdio transport
  - Begins listening for client requests
  - Runs the main event loop
  - Enables clients to get ready-to-use prompts
  - Connects prompt templates to actual content
  - Facilitates real-time client-server communication

**Why This Runs Last:**

  - All tools, resources, and prompts must be registered first
  - This starts the actual server operation
  - After this, the server is live and accepting requests
  - Defines the behavior of each prompt
  - Handlers make prompts functional
  - This is the final step to make the server operational
  - Without this, the server would not run
  - This method initiates the event loop that processes requests
  - Critical for real-time interactions with clients

---

#### How does MCP Server Start:

1. **Create stdio transport:** `stdio_server()`
   
      - Opens stdin (standard input) for receiving messages
      - Opens stdout (standard output) for sending responses

2. **Run server with streams:** `server.run(read_stream, write_stream)`
   
      - Listens on stdin for JSON-RPC messages from client
      - Sends JSON-RPC responses back on stdout

3. **Event loop processes requests asynchronously**
   
      - Handles multiple concurrent requests
      - Executes tools, returns resources, generates prompts

---

#### What is STDIO (Standard Input/Output)?

| Component  | Description                                    |
|:-----------|:-----------------------------------------------|
| **stdio**  | Standard Input/Output streams                  |
| **stdin**  | Channel for receiving data (keyboard, pipe)    |
| **stdout** | Channel for sending data (screen, pipe)        |
| **Usage**  | MCP uses stdio for client-server communication |
| **Flow**   | Client stdin → Server stdout → Client          |

#### Alternatives to STDIO:

| Component               | Description                           |
|:------------------------|:--------------------------------------|
| **HTTP/HTTPS**          | Web-based API (REST or GraphQL)       |
| **WebSockets**          | Bidirectional real-time communication |
| **gRPC**                | High-performance RPC framework        |
| **Unix Domain Sockets** | Local inter-process communication     |
| **TCP/IP Sockets**      | Network communication                 |


**Why STDIO for MCP?**

   - ✓ Simple: No network configuration needed
   - ✓ Secure: Stays within local process boundary
   - ✓ Universal: Works on all operating systems
   - ✓ Easy to integrate: Pipe to any process
   - ✓ Lightweight: Minimal overhead for communication
   - ✓ Ideal for local AI assistant integrations
   - ✓ Fits well with command-line tools and scripts
   - ✓ Perfect for development and testing
   - ✓ Common in LSP (Language Server Protocol) implementations
   - ✓ Easy to debug: View raw messages in terminal
   - ✓ No firewall or network issues
   - ✓ Works well with containerized environments
   

**Async Event Loop Explained:**

   * Event Loop: Central coordinator for async operations
   * Async/Await: Write concurrent code that looks sequential
   * Non-blocking: Server handles multiple requests simultaneously
   * Efficient: Uses single thread for many connections
   * Scalable: Easily handles growing workloads
  
---

**How It Works:**
   
   1. Event loop starts and waits for events (`messages`)
   2. When message arrives, creates a Task to handle it
   3. While waiting for I/O ( `tool execution`), processes other tasks
   4. When task completes, **sends response back to client**
   5. Continues looping until server shuts down
   6. This allows high concurrency with minimal threads

**Benefits:**

   - ✓ Handle 1000s of connections with single thread
   - ✓ No waiting: Process other requests during I/O
   - ✓ Memory efficient: No thread per connection
   - ✓ Scalable: Add more tasks without more threads
   - ✓ Responsive: Quick handling of many clients
   - ✓ Ideal for I/O-bound workloads (like MCP servers)
   - ✓ Simplifies concurrency model
   - ✓ Reduces complexity of multi-threaded code
   - ✓ Easier to maintain and debug
   - ✓ Leverages Python's async capabilities effectively

---

* Add this method to your class:

    ```python
    async def run(self):
        """Start the MCP server and begin serving requests."""
        print("Starting MCP server...")
        print("Server is now running and ready to accept connections")
        
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                self.server.create_initialization_options()
            )
    ```

---

**What's Happening:**

   * `stdio_server()` creates the stdin/stdout transport
   * `self.server.run()` starts the server event loop
   * The server now listens for JSON-RPC messages on stdin
   * Responses are sent back on stdout
   * The server can now handle tool calls, resource reads, and prompt requests
   * This is the final step to make the server operational
   * The server runs indefinitely until interrupted
   * Clients can now connect and interact with the server
   * This method is asynchronous, allowing concurrent request handling
   * The server is now live and ready for use

---

## Skeleton 12: RAG 

**What is RAG?**

* RAG = Retrieval Augmented Generation
* A technique that enhances AI responses by retrieving relevant information from a knowledge base before generating answers
* Think of it like giving the AI access to a reference library
* Combines information retrieval with text generation
* Enables accurate, context-aware responses based on specific data
* Examples: Customer support bots, domain-specific Q&A systems, documentation assistants
* Critical for providing factually accurate responses from your own data sources

**Why Add RAG to Your MCP Server?**

* Makes your server more intelligent and context-aware
* Allows retrieval of relevant information from local data sources
* Provides accurate responses based on your specific domain knowledge
* Enables filtering and querying of structured data
* Enhances the server's ability to answer domain-specific questions
* No heavy vector database dependencies required for simple implementations

---

#### 1. Install Dependencies

* No heavy dependencies (like vector databases) are required for this simple implementation. 
* We will use standard Python libraries.

#### 2. Update the MCP Server

* Open your MCP server file and add the following imports and initialization code to set up a simple in-memory users. 
* We will also add a helper function to load data from a CSV file.

```python
import csv

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
                # Load all fields from the CSV
                first_name = row.get('first_name', '')
                last_name = row.get('last_name', '')
                age = row.get('age', '')
                city = row.get('city', '')
                
                # Create full name and content
                full_name = f"{first_name} {last_name}".strip()
                content = f"{full_name} from {city}" if city else full_name
                
                # Create user dict with all available fields
                user = {
                    "id": str(i + 1),
                    "first_name": first_name,
                    "last_name": last_name,
                    "full_name": full_name,
                    "content": content,
                    "age": age,
                    "city": city
                }
                users.append(user)
        
        print(f"Loaded {len(users)} users from CSV.")
    except Exception as e:
        print(f"Error loading users: {e}")

# Load the users
# Make sure you have a 'users.csv' file in the same directory
# Format: first_name,last_name,city,age
load_users("users.csv") 
```

#### 3. Register the RAG Tool(s)

* Add new tools to your MCP server that allow the agent to query this collection using simple keyword matching.
* Here are two example tools: one to filter users by city and another to filter users by age.
* Add these tool definitions to the list in your `register_tools` method (inside the `list_tools` return array):

```python
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
```

* Then add the corresponding handlers in your `register_tool_handlers` method (inside the `call_tool` function):

```python
elif name == "filter_users_by_city":
    city = arguments.get("city", "")
    filtered_users = []
    target_city = city.lower().strip()
    
    for user in users:
        # Get city from user dict
        u_city = user.get("city", "").lower().strip()
        
        if u_city == target_city:
            full_name = user.get('full_name', 'Unknown')
            age = user.get('age', 'N/A')
            filtered_users.append(f"User {user.get('id')}: {full_name}, Age: {age}, City: {user.get('city')}")
    
    if not filtered_users:
        result = f"No users found in {city}."
    else:
        result = "\n".join(filtered_users)
    
    return [TextContent(type="text", text=result)]

elif name == "filter_users_by_age":
    min_age = int(arguments.get("min_age", 0))
    filtered_users = []
    
    for user in users:
        # Get age from user dict
        u_age = user.get("age", "")
        
        # Skip if no age
        if not u_age:
            continue
        
        try:
            u_age = int(u_age)
        except (ValueError, TypeError):
            continue
        
        if u_age > min_age:
            full_name = user.get('full_name', 'Unknown')
            city = user.get('city', 'Unknown')
            filtered_users.append(f"User {user.get('id')}: {full_name}, Age: {u_age}, City: {city}")
    
    if not filtered_users:
        result = f"No users found older than {min_age}."
    else:
        result = "\n".join(filtered_users)
    
    return [TextContent(type="text", text=result)]
```

#### 4. Test the RAG Capabilities

1.  Restart your MCP server.
2.  Use the MCP Inspector or Client to call `query_users` with a question like "What is a Pod?".
3.  Verify that the tool returns the specific definition we added to the database.

---

## Skeleton 13: Roots




---

## Skeleton 14: Main / Entry Point

**What is the Main Entry Point?**

* The main entry point is the starting point of your Python script
* It's the function that orchestrates the entire server setup and execution
* Think of it like the conductor of an orchestra - it coordinates all the pieces
* The `main()` function calls all setup methods in the correct order
* The `if __name__ == "__main__"` block is what runs when you execute the script directly
* Examples: Starts server, initializes components, handles graceful shutdown
* Essential for any Python application that needs to run as a standalone program

**Why This is Important:**

* Ensures all components are initialized in the correct order
* Provides a clear execution flow that's easy to understand
* Handles errors and graceful shutdown (like Ctrl+C)
* Makes your code modular and testable
* Standard Python pattern for executable scripts
* Without this, your server would just be a collection of classes with no way to run

**Orchestration Order:**

1. Create server instance (constructor)
2. Register tools
3. Register tool handlers
4. Register resources
5. Register resource handlers
6. Register prompts
7. Register prompt handlers
8. Setup lifecycle handlers
9. Run the server

---

* Now we need to create the main function that orchestrates everything and the entry point that runs when the script is executed.
* This is where we call all the setup methods in order and start the server.
* This is the final piece to complete your MCP server implementation.
* Let's add the main function and entry point.
  
---

* Add these functions at the end of your file (outside the class):

    ```python
    async def main():
        """
        Main entry point for the MCP server.
        
        This function orchestrates the complete server setup and execution:
        1. Creates server instance (constructor)
        2. Registers tools
        3. Registers tool handlers
        4. Registers resources
        5. Registers resource handlers
        6. Registers prompts
        7. Registers prompt handlers
        8. Sets up lifecycle handlers
        9. Runs the server
        """
        print("="*80)
        print("🌟 COMPLETE MCP SERVER - STARTING")
        print("="*80)
        
        # Step 1: Create server instance
        server = CompleteMCPServer()
        
        # Step 2: Register tools
        server.register_tools()
        
        # Step 3: Register tool handlers
        server.register_tool_handlers()
        
        # Step 4: Register resources
        server.register_resources()
        
        # Step 5: Register resource handlers
        server.register_resource_handlers()
        
        # Step 6: Register prompts
        server.register_prompts()
        
        # Step 7: Register prompt handlers
        server.register_prompt_handlers()
        
        # Step 8: Setup lifecycle handlers
        server.setup_lifecycle_handlers()
        
        print("="*80)
        print("All components registered successfully!")
        print("="*80)
        
        # Step 9: Run the server
        await server.run()


    if __name__ == "__main__":
        """
        Entry point when script is run directly.
        
        This runs when you execute: python mcp_server.py
        """
        try:
            asyncio.run(main())
        except KeyboardInterrupt:
            print("\n👋 Server shutdown complete")
            sys.exit(0)
    ```

---

**What's Happening:**

  - The `main()` function calls all setup methods in order
  - The `if __name__ == "__main__"` block runs when the script is executed
  - `asyncio.run(main())` starts the async event loop
  - `KeyboardInterrupt` handler allows graceful shutdown with Ctrl+C
  - This is the final orchestration of the MCP server

---


#### Code Review

At this point, your `mcp_server.py` file should have:

1. All imports at the top
2. `CompleteMCPServer` class with all 9 methods
3. `main()` function
4. Entry point with `if __name__ == "__main__"`

---

## Testing with MCP Inspector

* Now that you've built your complete MCP server, it's time to test it!
* We'll use MCP Inspector, a web-based tool for debugging MCP servers.
* Follow the steps below to install MCP Inspector, run your server, and test all the tools, resources, and prompts you implemented.

### What is MCP Inspector?

MCP Inspector is a web-based debugging tool for MCP servers. Think of it like a browser developer console for your MCP server - it lets you:

* Connect to your server
* See all available tools, resources, and prompts
* Execute tools with custom parameters
* Read resources
* Generate prompts
* View JSON-RPC messages
* Debug server behavior

### Installing MCP Inspector

Open a terminal and run:

  ```bash
  # Install MCP Inspector globally
  npm install -g @modelcontextprotocol/inspector

  # Run the MCP Inspector
  npx @modelcontextprotocol/inspector python3 "mcp_server.py"
  ```

---

### Testing Your Tools

Follow these steps in the MCP Inspector:

## Test 01: Connect to the Server

1. Click the **"Connect"** button at the bottom left of the interface
2. Wait for the connection status to show "Connected" (green indicator)
3. If not connected, set the following:
   * transport: `stdio`
   * Command: `python3`
   * Arguments: `mcp_server.py`
4. Click **"Connect"** again
5. You should see the server name and version in the top right corner
6. Success! 

---

## Test 02: Explore Tools

1. Click the **"Tools"** tab in the upper menu
2. Click **"List tools"** to see all available tools
3. You should see: `calculate`, `store_data`, `retrieve_data`, `echo` + RAG tools if added
4. If you added the `greeting` tool, you should see that too!

---

## Test 03: Test the Calculate Tool

1. Click on **"calculate"** in the tools list
2. The tool interface opens on the right side
3. Fill in the parameters:
      - **operation**: Select "add" from the dropdown
        - **a**: Enter `10`
        - **b**: Enter `5`
4. Click **"Run Tool"**
5. Scroll down to see the result: `"Result: 10 add 5 = 15"`
6. Success! 

---

## Test 04: Test the Store Data Tool

1. Click on **"store_data"** in the tools list
2. Fill in the parameters:
      - **key**: Enter `username`
      - **value**: Enter `Alice`
3. Click **"Run Tool"**
4. Result: `"Stored: username = Alice"`
5. Try storing another key-value pair to see it works!
6. Success!

---

## Test 05: Test the Retrieve Data Tool

1. Click on **"retrieve_data"** in the tools list
2. Fill in the parameter:
   - **key**: Enter `username`
3. Click **"Run Tool"**
4. Result: `"Retrieved: username = Alice"`
5. Try retrieving a non-existent key to see error handling!

---

## Test 06: Test the Echo Tool

1. Click on **"echo"** in the tools list
2. Fill in the parameter:
   - **text**: Enter `Hello, MCP World!`
3. Click **"Run Tool"**
4. Result: `"Echo: Hello, MCP World!"`

---

## Test 07: Test Resources

1. Click the **"Resources"** tab in the upper menu
2. Click **"List resources"** to see all available resources
3. You should see: `server-info`, `data-store`, `welcome`
4. If you added the `server-author` resource, you should see that too!

#### Test Resource: server-info

1. Click on **"resource://server-info"**
2. View the JSON response showing server metadata
3. Notice it shows 4 tools, 3 resources, 2 prompts

#### Test Resource: data-store

1. Click on **"resource://data-store"**
2. View the current contents of the data store
3. You should see the `username: Alice` you stored earlier!

#### Test Resource: welcome

1. Click on **"resource://welcome"**
2. View the welcome message explaining server capabilities
3. If you added the `server-author` resource, click on it to see your name displayed
4. Success!

---

## Test 08: Testing Your Prompts

1. Click the **"Prompts"** tab in the upper menu
2. Click **"List prompts"** to see all available prompts
3. You should see: `analyze-data`, `calculate-scenario`

#### Test Prompt: calculate-scenario

1. Click on **"calculate-scenario"**
2. Fill in the argument:
      - **operation**: Enter `multiply`
3. Click **"Get Prompt"**
4. View the generated prompt that explains how to use the calculate tool

#### Test Prompt: analyze-data

1. Click on **"analyze-data"**
2. Fill in the argument:
      - **key**: Enter `username`
3. Click **"Get Prompt"**
4. View the generated prompt that analyzes the stored data

---

### Understanding the Inspector Interface

**Left Panel: Navigation**

   * Tools, Resources, Prompts tabs
   * List and select items to test

**Right Panel: Details**

   * Shows selected item details
   * Input forms for parameters
   * Execute button
   * Results display

**Bottom Panel: JSON-RPC Messages**

   * Shows raw protocol messages
   * Useful for debugging
   * See requests and responses

**Connection Status**
   
   * Top right corner
   * Green = Connected
   * Red = Disconnected
   * Shows server name and version

---

## Advanced Experiments

* Now that you have a working server, try these challenges:

### Challenge 1: Modify the Calculate Tool

Add support for:
- `power` operation (a^b)
- `modulus` operation (a % b)

### Challenge 2: Add Roots

Add support for:
- Listing files in a directory (referencing client roots)
- Reading file contents (referencing client roots)

---

## Bonus Task: Hands-On Exercise

### Add Pagination Support for Listing Users

**Objective:** Implement a new tool called `list_all_users` that returns all users with pagination support.

**Requirements:**

1. **Tool Name:** `list_all_users`
2. **Parameters:**
   - `page` (optional, default: 1) - The page number to retrieve
   - `per_page` (optional, default: 10) - Number of users per page
3. **Functionality:**
   - Return users for the specified page
   - Include metadata: total users, total pages, current page
   - Handle edge cases (invalid page numbers, empty results)

**Your Task:**

1. Add the tool definition to `register_tools()` method
2. Implement the tool handler in `register_tool_handlers()` method
3. Test your implementation using MCP Inspector

**Hints:**
- Use Python's list slicing for pagination: `users[start:end]`
- Calculate start index: `(page - 1) * per_page`
- Calculate total pages: `math.ceil(len(users) / per_page)`
- Return both the user list and metadata

---

### Walkthrough Solution

#### Step 1: Add Tool Definition

<details>
<summary>Click here for the solution</summary>

Add this to your `register_tools()` method in the tools list:

  ```python
  Tool(
      name="list_all_users",
      description="List all users with pagination support",
      inputSchema={
          "type": "object",
          "properties": {
              "page": {
                  "type": "number",
                  "description": "Page number (default: 1)",
                  "default": 1
              },
              "per_page": {
                  "type": "number",
                  "description": "Number of users per page (default: 10)",
                  "default": 10
              }
          }
      }
  )
  ```
</details>

---

#### Step 2: Add Tool Handler

<details>
<summary>Click here for the solution</summary>

Add this to your `register_tool_handlers()` method in the `call_tool` function:

    ```python
    elif name == "list_all_users":
        import math
        
        # Get pagination parameters
        page = int(arguments.get("page", 1))
        per_page = int(arguments.get("per_page", 10))
        
        # Validate parameters
        if page < 1:
            page = 1
        if per_page < 1:
            per_page = 10
        if per_page > 100:  # Max limit
            per_page = 100
        
        # Calculate pagination
        total_users = len(users)
        total_pages = math.ceil(total_users / per_page) if total_users > 0 else 1
        
        # Ensure page doesn't exceed total pages
        if page > total_pages:
            page = total_pages
        
        # Calculate slice indices
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated users
        paginated_users = users[start_idx:end_idx]
        
        # Format output
        user_list = []
        for user in paginated_users:
            full_name = user.get('full_name', 'Unknown')
            age = user.get('age', 'N/A')
            city = user.get('city', 'Unknown')
            user_list.append(f"User {user.get('id')}: {full_name}, Age: {age}, City: {city}")
        
        # Build result with metadata
        metadata = f"Page {page} of {total_pages} | Total Users: {total_users} | Showing: {len(paginated_users)}"
        result = f"{metadata}\n\n" + "\n".join(user_list)
        
        return [TextContent(type="text", text=result)]
    ```
</details>

---

### Step 3: Test in MCP Inspector

1. Restart your MCP server
2. Open MCP Inspector
3. Go to the **Tools** tab
4. Click on **"list_all_users"**
5. Test with different parameters:
   - Default (page: 1, per_page: 10)
   - Page 2 with 5 users per page
   - Page 5 with 20 users per page

**Expected Output Format:**
```
Page 1 of 10 | Total Users: 100 | Showing: 10

User 1: James Smith, Age: 24, City: New York
User 2: Maria Garcia, Age: 31, City: Los Angeles
...
```

</details>

---

## Congratulations! 🎉

You've successfully built a complete MCP server with:
- Multiple tools (calculate, data storage, echo, user filters, pagination)
- Resources (server info, data store, welcome message)
- Prompts (data analysis, calculation scenarios)
- RAG capabilities (user filtering and search)
- Pagination support (bonus feature)

Keep exploring and building more advanced MCP servers!


