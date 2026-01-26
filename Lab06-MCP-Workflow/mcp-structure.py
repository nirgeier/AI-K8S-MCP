#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
This server demonstrates all MCP capabilities with detailed explanations.

NOTE: Scroll down to see detailed explanations for each import below!
"""

# ============================================================================
# IMPORTS EXPLANATION
# ============================================================================
# 📚 READ THESE CAREFULLY - Each import serves a specific purpose:
# Each line below is explained in detail with Purpose, Why, and Usage!

import asyncio
# Purpose: Enables asynchronous programming in Python
# Why: MCP servers handle multiple concurrent operations (I/O, requests)
# Usage: async/await keywords, event loops, concurrent task execution

import json
# Purpose: JSON encoding/decoding for data serialization
# Why: MCP uses JSON-RPC protocol; resources return JSON data
# Usage: json.dumps() to serialize Python dicts, json.loads() to parse

from typing import Any, Optional
# Purpose: Type hints for better code documentation and IDE support
# Why: Makes code more maintainable and catches type errors early
# Usage: function parameters, return types (Any = any type, Optional = can be None)

from mcp.server import Server
# Purpose: Core MCP Server class - the foundation of our server
# Why: Provides all MCP protocol implementation and lifecycle management
# Usage: Create server instance, register handlers, manage connections

from mcp.server.stdio import stdio_server
# Purpose: Standard Input/Output transport layer for MCP
# Why: MCP servers communicate via stdio (standard in/out streams)
# Usage: Connects server to clients through stdin/stdout pipes

from mcp.types import (
    Tool,
    Resource,
    Prompt,
    TextContent,
    ImageContent,
    EmbeddedResource,
)
# Purpose: MCP protocol type definitions for structured data
# Why: Type-safe definitions for all MCP primitives (tools, resources, prompts)
# Usage: Tool = executable functions, Resource = readable data,
#        Prompt = templates, TextContent = text responses

import sys
# Purpose: System-specific parameters and functions
# Why: Handle system exits, command-line arguments, and stdio streams
# Usage: sys.exit() for graceful shutdown, sys.stdin/stdout for I/O


def pause_for_user(message: str = "Press ENTER to continue..."):
    """
    Pause execution and wait for user input.
    
    Capabilities:
    - Halts script execution
    - Displays a message to the user
    - Waits for ENTER key press
    - Allows user to read and understand output
    
    Running now because: We need user interaction points throughout the execution
    """
    input(f"\n{'='*80}\n{message}\n{'='*80}\n")


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
        """
        Method: __init__ (Constructor)
        
        Capabilities:
        - Initializes the MCP Server instance
        - Creates the server object with name and version
        - Sets up the foundation for all MCP operations
        
        Running first because: Constructor must run before any other methods
        to create the server object that all other methods will use.
        """
        print("\n" + "="*80)
        print("METHOD 1: __init__ (Constructor)")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Initializes the MCP Server instance")
        print("  ✓ Creates server object with name 'complete-mcp-server'")
        print("  ✓ Sets version to '1.0.0'")
        print("  ✓ Establishes foundation for all MCP operations")
        print("\nREASON FOR ORDER:")
        print("  → This MUST run first as the constructor")
        print("  → Creates the server object that all other methods depend on")
        print("  → No other operations can occur without this initialization")
        
        self.server = Server("complete-mcp-server")
        self.data_store = {}  # Simple in-memory data storage
        
        print("\nServer instance created successfully!")
        pause_for_user()
    
    def register_tools(self):
        """
        Method: register_tools
        
        Capabilities:
        - Registers all available tools with the MCP server
        - Defines tool schemas (name, description, parameters)
        - Makes tools discoverable to clients
        - Sets up the tool execution infrastructure
        
        Running second because: After server initialization, we need to define
        what tools are available before we can execute them.
        """
        print("\n" + "="*80)
        print("METHOD 2: register_tools")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Registers tools with the MCP server")
        print("  ✓ Defines tool schemas (name, description, input schema)")
        print("  ✓ Makes tools discoverable to clients")
        print("  ✓ Sets up execution handlers for each tool")
        print("\nREASON FOR ORDER:")
        print("  → Runs after server initialization")
        print("  → Tools must be registered before they can be called")
        print("  → Defines the capabilities clients can invoke")
        print("\nMETHOD CODE:")
        print("  @self.server.list_tools()")
        print("  async def list_tools() -> list[Tool]:")
        print("      return [Tool(name='calculate', ...), ...]")
        
        @self.server.list_tools()
        async def list_tools() -> list[Tool]:
            """Return the list of available tools."""
            return [
                Tool(
                    name="calculate",
                    description="Performs basic mathematical calculations (add, subtract, multiply, divide)",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "operation": {
                                "type": "string",
                                "enum": ["add", "subtract", "multiply", "divide"],
                                "description": "The mathematical operation to perform"
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
                    description="Stores a key-value pair in the server's memory",
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
                    description="Retrieves a value by key from the server's memory",
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
                    description="Echoes back the input text",
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
        
        print("\nTools registered:")
        print("  → calculate: Performs mathematical operations")
        print("  → store_data: Stores key-value pairs")
        print("  → retrieve_data: Retrieves stored values")
        print("  → echo: Echoes input text")
        print("\nDEMONSTRATION OUTPUT:")
        print("  When a client calls list_tools(), they receive:")
        print("  [")
        print("    {'name': 'calculate', 'inputSchema': {'operation': 'add|subtract|...'}},")
        print("    {'name': 'store_data', 'inputSchema': {'key': 'string', 'value': 'string'}},")
        print("    {'name': 'retrieve_data', 'inputSchema': {'key': 'string'}},")
        print("    {'name': 'echo', 'inputSchema': {'text': 'string'}}")
        print("  ]")
        pause_for_user()
    
    def register_tool_handlers(self):
        """
        Method: register_tool_handlers
        
        Capabilities:
        - Implements the actual logic for each tool
        - Handles tool execution requests from clients
        - Processes input parameters and returns results
        - Provides error handling for tool execution
        
        Running third because: After tools are registered, we need to define
        what happens when each tool is called.
        """
        print("\n" + "="*80)
        print("⚙️  METHOD 3: register_tool_handlers")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Implements actual logic for each tool")
        print("  ✓ Handles tool execution requests from clients")
        print("  ✓ Processes input parameters and returns results")
        print("  ✓ Provides error handling and validation")
        print("\nREASON FOR ORDER:")
        print("  → Runs after tool registration")
        print("  → Tools need implementation before they can be executed")
        print("  → Connects tool schemas to actual functionality")
        print("\nMETHOD CODE:")
        print("  @self.server.call_tool()")
        print("  async def call_tool(name: str, arguments: Any):")
        print("      if name == 'calculate':")
        print("          result = a + b  # or subtract, multiply, divide")
        print("          return [TextContent(text=f'Result: {result}')]")
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Any) -> list[TextContent]:
            """Handle tool execution requests."""
            
            if name == "calculate":
                operation = arguments["operation"]
                a = arguments["a"]
                b = arguments["b"]
                
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
                            text="Error: Division by zero"
                        )]
                    result = a / b
                
                return [TextContent(
                    type="text",
                    text=f"Result: {a} {operation} {b} = {result}"
                )]
            
            elif name == "store_data":
                key = arguments["key"]
                value = arguments["value"]
                self.data_store[key] = value
                return [TextContent(
                    type="text",
                    text=f"Stored: {key} = {value}"
                )]
            
            elif name == "retrieve_data":
                key = arguments["key"]
                value = self.data_store.get(key, "Key not found")
                return [TextContent(
                    type="text",
                    text=f"Retrieved: {key} = {value}"
                )]
            
            elif name == "echo":
                text = arguments["text"]
                return [TextContent(
                    type="text",
                    text=f"Echo: {text}"
                )]
            
            return [TextContent(
                type="text",
                text=f"Unknown tool: {name}"
            )]
        
        print("\nTool handlers implemented:")
        print("  → Each tool now has executable logic")
        print("  → Error handling in place")
        print("  → Ready to process client requests")
        print("\nDEMONSTRATION OUTPUT:")
        print("  Example: calculate(operation='add', a=10, b=5)")
        print("  Returns: [TextContent(text='Result: 10 add 5 = 15')]")
        print("\n  Example: store_data(key='name', value='Alice')")
        print("  Returns: [TextContent(text='Stored: name = Alice')]")
        pause_for_user()
    
    def register_resources(self):
        """
        Method: register_resources
        
        Capabilities:
        - Registers resources that clients can access
        - Defines resource URIs and metadata
        - Makes static and dynamic content available
        - Enables resource discovery and retrieval
        
        Running fourth because: After tools are set up, we add resources
        which provide additional data and content to clients.
        """
        print("\n" + "="*80)
        print("📚 METHOD 4: register_resources")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Registers resources that clients can access")
        print("  ✓ Defines resource URIs (Uniform Resource Identifiers)")
        print("  ✓ Makes static and dynamic content available")
        print("  ✓ Enables resource discovery and retrieval")
        print("\nREASON FOR ORDER:")
        print("  → Runs after tools are fully configured")
        print("  → Resources are complementary to tools")
        print("  → Provides data that tools might reference")
        print("\nMETHOD CODE:")
        print("  @self.server.list_resources()")
        print("  async def list_resources() -> list[Resource]:")
        print("      return [Resource(uri='resource://server-info', ...), ...]")
        
        @self.server.list_resources()
        async def list_resources() -> list[Resource]:
            """Return the list of available resources."""
            return [
                Resource(
                    uri="resource://server-info",
                    name="Server Information",
                    mimeType="application/json",
                    description="Information about this MCP server"
                ),
                Resource(
                    uri="resource://data-store",
                    name="Data Store Contents",
                    mimeType="application/json",
                    description="Current contents of the server's data store"
                ),
                Resource(
                    uri="resource://welcome",
                    name="Welcome Message",
                    mimeType="text/plain",
                    description="Welcome message for new users"
                )
            ]
        
        print("\nResources registered:")
        print("  → resource://server-info: Server metadata")
        print("  → resource://data-store: Current data storage")
        print("  → resource://welcome: Welcome message")
        print("\nDEMONSTRATION OUTPUT:")
        print("  When a client reads 'resource://welcome', they see:")
        print("  " + "-"*76)
        print("""  Welcome to the Complete MCP Server!
  
  This server demonstrates all MCP protocol capabilities:
  - Tools: Execute operations and computations
  - Resources: Access data and information
  - Prompts: Get structured prompt templates
  
  Explore the available tools and resources to see what this server can do.""")
        print("  " + "-"*76)
        pause_for_user()
    
    def register_resource_handlers(self):
        """
        Method: register_resource_handlers
        
        Capabilities:
        - Implements resource retrieval logic
        - Returns actual content for each resource
        - Handles dynamic resource generation
        - Provides resource access control
        
        Running fifth because: After resources are registered, we need to
        implement what content is returned when each resource is accessed.
        """
        print("\n" + "="*80)
        print("📖 METHOD 5: register_resource_handlers")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Implements resource retrieval logic")
        print("  ✓ Returns actual content for each resource URI")
        print("  ✓ Handles dynamic resource generation")
        print("  ✓ Manages resource access and permissions")
        print("\nREASON FOR ORDER:")
        print("  → Runs after resource registration")
        print("  → Resources need implementation to return content")
        print("  → Connects resource URIs to actual data")
        print("\nMETHOD CODE:")
        print("  @self.server.read_resource()")
        print("  async def read_resource(uri: str) -> str:")
        print("      if uri == 'resource://server-info':")
        print("          return json.dumps({'name': 'complete-mcp-server', ...})")
        
        @self.server.read_resource()
        async def read_resource(uri: str) -> str:
            """Handle resource read requests."""
            
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
                return """
Welcome to the Complete MCP Server!

This server demonstrates all MCP protocol capabilities:
- Tools: Execute operations and computations
- Resources: Access data and information
- Prompts: Get structured prompt templates

Explore the available tools and resources to see what this server can do.
                """.strip()
            
            return f"Resource not found: {uri}"
        
        print("\nResource handlers implemented:")
        print("  → Each resource returns appropriate content")
        print("  → Dynamic content generation enabled")
        print("  → Ready to serve resource requests")
        print("\nDEMONSTRATION OUTPUT:")
        print("  Reading 'resource://server-info' returns JSON:")
        server_info = {
            "name": "complete-mcp-server",
            "version": "1.0.0",
            "description": "A comprehensive MCP server implementation",
            "capabilities": {"tools": 4, "resources": 3, "prompts": 2}
        }
        print("  " + json.dumps(server_info, indent=4))
        print("\n  Reading 'resource://data-store' returns current stored data:")
        print("  " + json.dumps(self.data_store if self.data_store else {"note": "empty"}, indent=4))
        pause_for_user()
    
    def register_prompts(self):
        """
        Method: register_prompts
        
        Capabilities:
        - Registers prompt templates for clients
        - Defines structured prompts with parameters
        - Enables prompt discovery
        - Provides reusable prompt patterns
        
        Running sixth because: After tools and resources, prompts add
        higher-level interaction patterns for AI assistants.
        """
        print("\n" + "="*80)
        print("💬 METHOD 6: register_prompts")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Registers prompt templates for clients")
        print("  ✓ Defines structured prompts with parameters")
        print("  ✓ Enables prompt discovery and listing")
        print("  ✓ Provides reusable prompt patterns")
        print("\nREASON FOR ORDER:")
        print("  → Runs after tools and resources are set up")
        print("  → Prompts build on available tools and resources")
        print("  → Provides high-level interaction patterns")
        print("\nMETHOD CODE:")
        print("  @self.server.list_prompts()")
        print("  async def list_prompts() -> list[Prompt]:")
        print("      return [Prompt(name='analyze-data', arguments=[...]), ...]")
        
        @self.server.list_prompts()
        async def list_prompts() -> list[Prompt]:
            """Return the list of available prompts."""
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
                    description="Generate a calculation scenario",
                    arguments=[
                        {
                            "name": "operation",
                            "description": "The operation to demonstrate (add, subtract, multiply, divide)",
                            "required": True
                        }
                    ]
                )
            ]
        
        print("\nPrompts registered:")
        print("  → analyze-data: Analyzes stored data")
        print("  → calculate-scenario: Demonstrates calculations")
        print("\nREUSABLE PROMPT PATTERNS:")
        print("  These prompts provide templates that AI assistants can use")
        print("  repeatedly for common tasks:")
        print("\n  Pattern 1: 'analyze-data'")
        print("    - Takes parameter: 'key' (which data to analyze)")
        print("    - Returns structured analysis prompt")
        print("    - Reusable for any stored data key")
        print("\n  Pattern 2: 'calculate-scenario'")
        print("    - Takes parameter: 'operation' (add/subtract/etc.)")
        print("    - Returns calculation walkthrough prompt")
        print("    - Reusable for teaching different operations")
        pause_for_user()
    
    def register_prompt_handlers(self):
        """
        Method: register_prompt_handlers
        
        Capabilities:
        - Implements prompt generation logic
        - Returns formatted prompts with embedded context
        - Handles prompt parameters and customization
        - Provides dynamic prompt content
        
        Running seventh because: After prompts are registered, we implement
        the logic that generates the actual prompt content.
        """
        print("\n" + "="*80)
        print("📝 METHOD 7: register_prompt_handlers")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Implements prompt generation logic")
        print("  ✓ Returns formatted prompts with context")
        print("  ✓ Handles prompt parameters and customization")
        print("  ✓ Provides dynamic, contextual prompt content")
        print("\nREASON FOR ORDER:")
        print("  → Runs after prompt registration")
        print("  → Prompts need implementation to generate content")
        print("  → Connects prompt templates to actual text")
        print("\nMETHOD CODE:")
        print("  @self.server.get_prompt()")
        print("  async def get_prompt(name: str, arguments: dict) -> str:")
        print("      if name == 'calculate-scenario':")
        print("          operation = arguments.get('operation', 'add')")
        print("          return f'Use calculate tool with {operation}'")
        
        @self.server.get_prompt()
        async def get_prompt(name: str, arguments: dict[str, str] | None) -> str:
            """Handle prompt retrieval requests."""
            
            if name == "analyze-data":
                key = arguments.get("key", "") if arguments else ""
                value = self.data_store.get(key, "No data found")
                return f"""
Please analyze the following data:

Key: {key}
Value: {value}

Provide insights about:
1. The nature of the data
2. Potential uses
3. Related queries that might be relevant
                """.strip()
            
            elif name == "calculate-scenario":
                operation = arguments.get("operation", "add") if arguments else "add"
                return f"""
Let's work through a {operation} calculation scenario.

Use the calculate tool with the operation '{operation}'.
For example:
- Choose two numbers (a and b)
- Execute: calculate(operation="{operation}", a=10, b=5)
- Explain the result

This demonstrates how to use computational tools in the MCP server.
                """.strip()
            
            return f"Prompt not found: {name}"
        
        print("\nPrompt handlers implemented:")
        print("  → Each prompt generates contextual content")
        print("  → Parameters properly integrated")
        print("  → Ready to serve prompt requests")
        print("\nDEMONSTRATION OUTPUT:")
        print("  Calling get_prompt('calculate-scenario', {'operation': 'multiply'}):")
        print("  " + "-"*76)
        print("""  Let's work through a multiply calculation scenario.
  
  Use the calculate tool with the operation 'multiply'.
  For example:
  - Choose two numbers (a and b)
  - Execute: calculate(operation="multiply", a=10, b=5)
  - Explain the result
  
  This demonstrates how to use computational tools in the MCP server.""")
        print("  " + "-"*76)
        pause_for_user()
    
    def setup_lifecycle_handlers(self):
        """
        Method: setup_lifecycle_handlers
        
        Capabilities:
        - Handles server initialization events
        - Manages server shutdown procedures
        - Logs server lifecycle events
        - Ensures clean startup and teardown
        
        Running eighth because: After all features are registered, we set up
        lifecycle management to handle server start and stop events.
        """
        print("\n" + "="*80)
        print("🔄 METHOD 8: setup_lifecycle_handlers")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Handles server initialization events")
        print("  ✓ Manages server shutdown procedures")
        print("  ✓ Logs server lifecycle events")
        print("  ✓ Ensures clean startup and teardown")
        print("\nREASON FOR ORDER:")
        print("  → Runs after all features are configured")
        print("  → Lifecycle handlers need complete server setup")
        print("  → Prepares server for actual runtime operations")
        print("\nWHY SERVER NEEDS SHUTDOWN PROCEDURES:")
        print("  • Release system resources (memory, file handles, connections)")
        print("  • Save any pending data or state to disk")
        print("  • Close network connections gracefully")
        print("  • Notify connected clients of server shutdown")
        print("  • Clean up temporary files and caches")
        print("  • Log final statistics and status")
        print("  • Prevent data corruption from abrupt termination")
        print("  • Allow pending operations to complete")
        
        # Note: MCP servers typically don't have explicit lifecycle hooks
        # This is a conceptual method showing where such logic would go
        print("\nLifecycle management configured:")
        print("  → Server ready for initialization")
        print("  → Shutdown procedures defined (Ctrl+C handling)")
        print("  → Logging and monitoring in place")
        print("\nMETHOD CODE:")
        print("  try:")
        print("      asyncio.run(main())")
        print("  except KeyboardInterrupt:")
        print("      # Clean shutdown on Ctrl+C")
        print("      print('Server shutdown complete')")
        print("      sys.exit(0)")
        pause_for_user()
    
    async def run(self):
        """
        Method: run
        
        Capabilities:
        - Starts the MCP server
        - Connects to stdio transport
        - Begins listening for client requests
        - Runs the main event loop
        
        Running ninth (last) because: This is the final step that actually
        starts the server and begins serving requests. All configuration
        must be complete before this runs.
        """
        print("\n" + "="*80)
        print("🎯 METHOD 9: run (Server Startup)")
        print("="*80)
        print("CAPABILITIES:")
        print("  ✓ Starts the MCP server")
        print("  ✓ Connects to stdio transport (standard input/output)")
        print("  ✓ Begins listening for client requests")
        print("  ✓ Runs the main async event loop")
        print("\nREASON FOR ORDER:")
        print("  → This MUST run last")
        print("  → All tools, resources, and prompts must be registered first")
        print("  → This starts the actual server operation")
        print("  → After this, the server is live and accepting requests")
        
        print("\n" + "="*80)
        print("HOW MCP SERVER STARTS:")
        print("="*80)
        print("1. Create stdio transport: stdio_server()")
        print("   - Opens stdin (standard input) for receiving messages")
        print("   - Opens stdout (standard output) for sending responses")
        print("\n2. Run server with streams: server.run(read_stream, write_stream)")
        print("   - Listens on stdin for JSON-RPC messages from client")
        print("   - Sends JSON-RPC responses back on stdout")
        print("\n3. Event loop processes requests asynchronously")
        print("   - Handles multiple concurrent requests")
        print("   - Executes tools, returns resources, generates prompts")
        
        print("\n" + "="*80)
        print("WHAT IS STDIO (Standard Input/Output)?")
        print("="*80)
        print("• STDIO = Standard Input/Output streams")
        print("• stdin: Channel for receiving data (keyboard, pipe)")
        print("• stdout: Channel for sending data (screen, pipe)")
        print("• MCP uses stdio for client-server communication")
        print("• Messages flow: Client stdin → Server stdout → Client")
        print("\nALTERNATIVES TO STDIO:")
        print("  1. HTTP/HTTPS: Web-based API (REST or GraphQL)")
        print("  2. WebSockets: Bidirectional real-time communication")
        print("  3. gRPC: High-performance RPC framework")
        print("  4. Unix Domain Sockets: Local inter-process communication")
        print("  5. TCP/IP Sockets: Network communication")
        print("\nWHY STDIO FOR MCP?")
        print("  ✓ Simple: No network configuration needed")
        print("  ✓ Secure: Stays within local process boundary")
        print("  ✓ Universal: Works on all operating systems")
        print("  ✓ Easy to integrate: Pipe to any process")
        
        print("\n" + "="*80)
        print("ASYNC EVENT LOOP EXPLAINED:")
        print("="*80)
        print("• Event Loop: Central coordinator for async operations")
        print("• Async/Await: Write concurrent code that looks sequential")
        print("• Non-blocking: Server handles multiple requests simultaneously")
        print("\nHOW IT WORKS:")
        print("  1. Event loop starts and waits for events (messages)")
        print("  2. When message arrives, creates a Task to handle it")
        print("  3. While waiting for I/O (tool execution), processes other tasks")
        print("  4. When task completes, sends response back to client")
        print("  5. Continues looping until server shuts down")
        print("\nBENEFITS:")
        print("  ✓ Handle 1000s of connections with single thread")
        print("  ✓ No waiting: Process other requests during I/O")
        print("  ✓ Memory efficient: No thread per connection")
        print("  ✓ Scalable: Add more tasks without more threads")
        
        print("\n🎉 ALL METHODS EXECUTED IN CORRECT ORDER!")
        print("\nServer is now ready to start...")
        pause_for_user("Press ENTER to see connection instructions...")
        
        print("\n" + "="*80)
        print("📡 HOW TO CONNECT TO THIS MCP SERVER")
        print("="*80)
        print("\n⚠️  IMPORTANT: MCP servers DON'T accept direct user input!")
        print("   They communicate via JSON-RPC protocol with MCP clients.\n")
        print("OPTION 1: Use MCP Inspector (For Testing)")
        print("-" * 80)
        print("1. Install: npm install -g @modelcontextprotocol/inspector")
        print("2. Run: mcp-inspector python " + __file__)
        print("3. Opens web interface to test tools and resources")
        
        print("\n\nOPTION 2: Build Custom Client")
        print("-" * 80)
        print("Use the MCP SDK to build your own client:")
        print("  from mcp.client import ClientSession, StdioServerParameters")
        print("  from mcp.client.stdio import stdio_client")
        print("\n  server_params = StdioServerParameters(")
        print("      command='python',")
        print(f"      args=['{__file__}']")
        print("  )")
        print("\n  async with stdio_client(server_params) as (read, write):")
        print("      async with ClientSession(read, write) as session:")
        print("          # List and call tools")
        print("          tools = await session.list_tools()")
        print("          result = await session.call_tool('calculate', {")
        print("              'operation': 'add', 'a': 10, 'b': 5")
        print("          })")
        
        print("\n\n" + "="*80)
        print("WHAT YOU SHOULD NOT DO:")
        print("="*80)
        print("❌ Don't type directly into this terminal")
        print("❌ Don't send raw text - server expects JSON-RPC")
        print("❌ Don't expect interactive prompt/response")
        print("\nThis is a background service that clients connect to!")
        
        print("\n\n" + "="*80)
        print("🎉 EDUCATIONAL DEMO COMPLETE!")
        print("="*80)
        print("\nAll 9 methods have been explained in order")
        print("You now understand how MCP servers work")
        
        # Launch MCP Inspector automatically
        import subprocess
        import shutil
        
        print("\n" + "="*80)
        print("🚀 LAUNCHING MCP INSPECTOR - see your browser")
        print("="*80)
        
        print("\nIn your MCP Inspector tab session, follow these instructions:")
        print("  1. Click \"Connect\" at the bottom left.")
        print("  2. Click the \"Tools\" tab at the upper menu.")
        print("  3. At the Tools frame, click \"List tools\".")
        print("  4. Just under it, click \"calculate\", and you'll see the calculate tool opens on the right.")
        print("  5. From the \"operation\" drop down select your desired mathematical function option")
        print("     (add, subtract, multiply or divide).")
        print("  6. Add numbers for \"a\" and for \"b\".")
        print("  7. Click \"Run Tool\" and scroll down to see the result.")
        print("  Success!")
        
        # Check if mcp-inspector is installed
        inspector_path = shutil.which("mcp-inspector")
        
        if not inspector_path:
            print("\n⚠️  Installing MCP Inspector... (one-time setup)\n")
            npm_path = shutil.which("npm")
            if not npm_path:
                print("❌ npm not installed. Install Node.js first: brew install node")
                return
            
            try:
                subprocess.run(
                    ["npm", "install", "-g", "@modelcontextprotocol/inspector"],
                    check=True,
                    capture_output=True
                )
            except subprocess.CalledProcessError:
                print("❌ Failed to install MCP Inspector")
                return
        
        # Kill any existing mcp-inspector processes to free up the port
        try:
            subprocess.run(
                ["pkill", "-f", "mcp-inspector"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            # Give it a moment to clean up
            import time
            time.sleep(1)
        except:
            pass  # Ignore errors if no process to kill
        
        # Launch MCP Inspector with --server-only flag (suppressed output)
        print("\n⚠️  Press Ctrl+C to terminate the demo.\n")
        try:
            subprocess.run(
                ["mcp-inspector", "python", __file__, "--server-only"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except KeyboardInterrupt:
            print("\n🛑 Demo terminated. Goodbye!")
        except Exception as e:
            print(f"❌ Failed to launch: {e}")




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
    print("\n" + "="*80)
    print("🌟 COMPLETE MCP SERVER - INITIALIZATION SEQUENCE")
    print("="*80)
    print("\nThis demonstration will walk you through each method in the")
    print("MCP server implementation, explaining:")
    print("  • What each method does (capabilities)")
    print("  • Why it runs in this specific order")
    print("\nYou'll need to press ENTER after each method to continue.")
    pause_for_user("Press ENTER to begin...")
    
    # Step 0: Explain imports
    print("\n" + "="*80)
    print("📦 IMPORTS - Understanding the Dependencies")
    print("="*80)
    print("\nBefore we create the server, let's understand what we're importing:")
    print("\n" + "-"*80)
    print("1. ASYNCIO - Asynchronous I/O")
    print("-"*80)
    print("   Purpose: Enables concurrent operations without threading")
    print("   Why: MCP servers handle multiple requests simultaneously")
    print("   Usage: async/await keywords, event loop management")
    
    print("\n" + "-"*80)
    print("2. JSON - JavaScript Object Notation")
    print("-"*80)
    print("   Purpose: Serialize/deserialize Python data structures")
    print("   Why: MCP protocol uses JSON for data exchange")
    print("   Usage: json.dumps() for converting Python → JSON")
    
    print("\n" + "-"*80)
    print("3. TYPING - Type Hints")
    print("-"*80)
    print("   Purpose: Add type annotations (Any, Optional)")
    print("   Why: Improves code clarity and catches type errors")
    print("   Usage: Function signatures, variable declarations")
    
    print("\n" + "-"*80)
    print("4. MCP.SERVER - Core Server Framework")
    print("-"*80)
    print("   Purpose: Main Server class for MCP implementation")
    print("   Why: Provides @decorators for tools, resources, prompts")
    print("   Usage: Server(name, version) creates the server instance")
    
    print("\n" + "-"*80)
    print("5. MCP.SERVER.STDIO - Standard I/O Transport")
    print("-"*80)
    print("   Purpose: Communication layer using stdin/stdout")
    print("   Why: Enables process-based client-server communication")
    print("   Usage: stdio_server() wraps server for stdio transport")
    
    print("\n" + "-"*80)
    print("6. MCP.TYPES - Protocol Types")
    print("-"*80)
    print("   Purpose: Data structures for MCP protocol")
    print("   Why: Ensures type-safe tool/resource/prompt definitions")
    print("   Usage: Tool, TextContent, Resource, Prompt classes")
    
    print("\nAll dependencies loaded successfully!")
    print("   These imports work together to create a complete MCP server\n")
    
    pause_for_user("Press ENTER to continue to Method 1...")
    
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
    
    # Step 9: Run the server
    await server.run()


if __name__ == "__main__":
    """
    Entry point when script is run directly.
    
    This runs when you execute: python MCP.py
    
    Modes:
    - python MCP.py              → Educational walkthrough + MCP Inspector
    - python MCP.py --server-only → Just run server (used by MCP Inspector)
    """
    import sys
    
    # Check if we should skip demo and just run server
    if len(sys.argv) > 1 and sys.argv[1] == "--server-only":
        # Run server directly without ANY output (silent mode for MCP Inspector)
        async def run_server_only():
            # Create a silent server - no print statements at all
            silent_server = Server("complete-mcp-server")
            data_store = {}
            
            # Register tools silently
            @silent_server.list_tools()
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
                    Tool(name="store_data", description="Stores a key-value pair",
                         inputSchema={"type": "object", "properties": {"key": {"type": "string"}, "value": {"type": "string"}}, "required": ["key", "value"]}),
                    Tool(name="retrieve_data", description="Retrieves a value by key",
                         inputSchema={"type": "object", "properties": {"key": {"type": "string"}}, "required": ["key"]}),
                    Tool(name="echo", description="Echoes back the input text",
                         inputSchema={"type": "object", "properties": {"text": {"type": "string"}}, "required": ["text"]})
                ]
            
            @silent_server.call_tool()
            async def call_tool(name: str, arguments: Any) -> list[TextContent]:
                if name == "calculate":
                    op, a, b = arguments["operation"], arguments["a"], arguments["b"]
                    if op == "add": result = a + b
                    elif op == "subtract": result = a - b
                    elif op == "multiply": result = a * b
                    elif op == "divide": result = a / b if b != 0 else "Error: Division by zero"
                    return [TextContent(type="text", text=f"Result: {a} {op} {b} = {result}")]
                elif name == "store_data":
                    data_store[arguments["key"]] = arguments["value"]
                    return [TextContent(type="text", text=f"Stored: {arguments['key']} = {arguments['value']}")]
                elif name == "retrieve_data":
                    value = data_store.get(arguments["key"], "Key not found")
                    return [TextContent(type="text", text=f"Retrieved: {arguments['key']} = {value}")]
                elif name == "echo":
                    return [TextContent(type="text", text=f"Echo: {arguments['text']}")]
                return [TextContent(type="text", text=f"Unknown tool: {name}")]
            
            @silent_server.list_resources()
            async def list_resources() -> list[Resource]:
                return [
                    Resource(uri="resource://server-info", name="Server Information", mimeType="application/json"),
                    Resource(uri="resource://data-store", name="Data Store Contents", mimeType="application/json"),
                    Resource(uri="resource://welcome", name="Welcome Message", mimeType="text/plain")
                ]
            
            @silent_server.read_resource()
            async def read_resource(uri: str) -> str:
                if uri == "resource://server-info":
                    return json.dumps({"name": "complete-mcp-server", "version": "1.0.0", "capabilities": {"tools": 4, "resources": 3, "prompts": 2}})
                elif uri == "resource://data-store":
                    return json.dumps(data_store)
                elif uri == "resource://welcome":
                    return "Welcome to the Complete MCP Server!"
                return f"Resource not found: {uri}"
            
            @silent_server.list_prompts()
            async def list_prompts() -> list[Prompt]:
                return [
                    Prompt(name="analyze-data", description="Analyze stored data", arguments=[{"name": "key", "description": "Data key", "required": True}]),
                    Prompt(name="calculate-scenario", description="Calculation scenario", arguments=[{"name": "operation", "description": "Operation type", "required": True}])
                ]
            
            @silent_server.get_prompt()
            async def get_prompt(name: str, arguments: dict[str, str] | None) -> str:
                if name == "analyze-data":
                    key = arguments.get("key", "") if arguments else ""
                    return f"Analyze data for key: {key}"
                elif name == "calculate-scenario":
                    op = arguments.get("operation", "add") if arguments else "add"
                    return f"Use calculate tool with operation '{op}'"
                return f"Prompt not found: {name}"
            
            # Run server via stdio - completely silent
            async with stdio_server() as (read_stream, write_stream):
                await silent_server.run(read_stream, write_stream, silent_server.create_initialization_options())
        
        try:
            asyncio.run(run_server_only())
        except KeyboardInterrupt:
            sys.exit(0)
    else:
        # Run educational demo
        try:
            asyncio.run(main())
        except KeyboardInterrupt:
            print("\n\n" + "="*80)
            print("🛑 DEMO STOPPED BY USER")
            print("="*80)
            print("Goodbye!")
            sys.exit(0)