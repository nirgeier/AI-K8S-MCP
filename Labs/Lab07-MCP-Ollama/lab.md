# Complete MCP Server with Ollama Integration - Hands-On Lab

## Lab Objective

- In this hands-on lab, you'll build a complete MCP (Model Context Protocol) server from scratch with Ollama integration.
- You'll learn how each component works by implementing it yourself, understanding why each piece is necessary, and seeing the complete architecture come together.
- You'll implement advanced tools: Weather information with Ollama, File Operations, and Database Query, along with best practices for error handling, async operations, and tool composition.

---

## Prerequisites

- Python 3.10 or higher installed
- Ollama installed and running locally
- Basic understanding of Python programming
- Terminal/command line access
- Text editor or IDE

---

## Getting Started


1. Create a new file called `mcp_ollama.py` as your project file.
2. Open it in your favorite text editor.
3. Don't worry, during this lab, we'll build this server step by step!

---

## Step 01: Adding Imports

- Before we write any code, we need to understand what libraries we'll be using, and why.

### `asyncio` - Asynchronous I/O

!!! question "asyncio"
    **Definition:** A library for writing concurrent code using the async/await syntax.  
    **Why:** Enables non-blocking I/O operations, crucial for handling multiple client requests simultaneously without freezing the server.  
    **Usage:** Used for async functions, event loops, and coordinating concurrent tasks in the MCP server.

### `json` - JavaScript Object Notation

!!! question "json"
    **Definition:** A module for parsing and generating JSON data.  
    **Why:** MCP uses JSON-RPC for communication between clients and servers.  
    **Usage:** Serializing/deserializing data sent over stdio transport.

### `typing` - Type Hints

!!! question "typing"
    **Definition:** Provides runtime support for type hints.  
    **Why:** Improves code readability, enables better IDE support, and catches type-related errors early.  
    **Usage:** Defining function signatures and data structures with proper types.

### `mcp.server` - Core MCP Server

!!! question "mcp.server"
    **Definition:** The main server class for implementing MCP servers.  
    **Why:** Provides the framework for registering tools, resources, and prompts, and handling client requests.  
    **Usage:** Creating the server instance and setting up request handlers.

### `mcp.server.stdio` - Standard I/O Transport

!!! question "mcp.server.stdio"
    **Definition:** Transport layer for communication via standard input/output streams.  
    **Why:** Enables MCP servers to communicate with clients through stdin/stdout, making them easily integrable with various applications.  
    **Usage:** Establishing the communication channel for the server.

### `mcp.types` - Protocol Types

!!! question "mcp.types"
    **Definition:** Type definitions for MCP protocol messages and data structures.  
    **Why:** Ensures type safety and consistency when working with MCP messages.  
    **Usage:** Defining request/response schemas and content types.

    **Key Types Used:**

    - **`Resource`**: Defines a resource (readable data/content) with URI, name, description, and MIME type
    - **`Tool`**: Defines a tool (executable function) with name, description, and input schema
    - **`TextContent`**, **`ImageContent`**: Content types for tool/resource responses
    - **`Prompt`**: Defines a prompt template with name, description, and required arguments
    - **`GetPromptResult`**: Result structure when retrieving a prompt
    - **`CallToolResult`**: Result structure when calling a tool
    - **`ListResourcesResult`**, **`ListToolsResult`**, **`ListPromptsResult`**: Results when listing available resources/tools/prompts
    - **`ReadResourceResult`**: Result structure when reading a resource

### `sys` - System Functions

!!! question "sys"
    **Definition:** Provides access to system-specific parameters and functions.  
    **Why:** Needed for handling command-line arguments and system-level operations.  
    **Usage:** Accessing stdin/stdout streams and handling program exit.

### `requests` - HTTP Library

!!! question "requests"
    **Definition:** A simple HTTP library for making web requests.  
    **Why:** Used for interacting with external APIs and services.  
    **Usage:** Making HTTP calls to fetch data from web services.

### `sqlite3` - SQLite Database

!!! question "sqlite3"
    **Definition:** Python's built-in SQLite database module.  
    **Why:** Provides a lightweight, file-based database for data storage and querying.  
    **Usage:** Executing SQL queries and managing database operations.

### `ollama` - Ollama Client

!!! question "ollama"
    **Definition:** Python client for interacting with Ollama, a tool for running large language models locally.  
    **Why:** Enables integration with local AI models for generating content and responses.  
    **Usage:** Generating AI-powered weather information and other content.

### `os` - Operating System Interface

!!! question "os"
    **Definition:** Provides a way to interact with the operating system.  
    **Why:** Needed for file system operations and path handling.  
    **Usage:** Checking file existence, reading files, and managing file paths.

### `pathlib` - Object-oriented Filesystem Paths

!!! question "pathlib"
    **Definition:** Provides classes for filesystem paths with semantic operations.  
    **Why:** Offers a more intuitive and cross-platform way to handle file paths.  
    **Usage:** Constructing and manipulating file paths safely.

---

### Code for Step 01: Imports

Set the following imports inside the `mcp_ollama.py` file:

```python
import asyncio
import json
import os
import sqlite3
import sys  # Not used in this MCP server scenario - stdio handled by mcp.server.stdio
from pathlib import Path
from typing import Any, Dict, List, Optional

import ollama
import requests
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    ResourceContent,
    Prompt,
    GetPromptResult,
    CallToolResult,
    ListResourcesResult,
    ListToolsResult,
    ReadResourceResult,
    ListPromptsResult,
)
```

Create a file named `requirements.txt` with the following content:

```
mcp>=0.1.0
ollama>=0.1.0
requests>=2.25.0
```

Install the dependenciesby running the following from the same directory as your `requirements.txt` file:

```bash
pip install -r requirements.txt
```

---

## Step 02: Skeleton Code - Class

### Class Definition

- Add this class definition after the imports in your `mcp_ollama.py` file:

```python
class CompleteOllamaMCPServer:
    def __init__(self):
        self.server = Server("complete-ollama-mcp-server")
        self.data_store = {}
        self.db_path = "data.db"
        self._setup_handlers()

    def _setup_handlers(self):
        # Will be implemented in subsequent steps
        pass
```

---

## Step 03: Constructor

### Method `__init__` (Constructor)

**Capabilities:**

- Initializes the MCP server with a name
- Sets up data structures for tools, resources, and prompts
- Prepares database connection
- Initializes Ollama client

**Why This Runs First:**

- Establishes the foundation for all server operations
- Sets up the basic state of the server
- Ensures all dependencies are ready before registering components

---

- Add this class definition after inside your `CompleteOllamaMCPServer` class:

```python
    def __init__(self):
        self.server = Server("complete-ollama-mcp-server")
        self.data_store = {}
        self.db_path = "data.db"
        self.ollama_client = ollama.Client()
        self._setup_handlers()
```

---

## Step 04: Register Tools

### Method `register_tools`

**Capabilities:**
- Registers tool definitions for discovery
- Defines tool schemas and capabilities
- Makes tools available to clients

**Why This Runs Second:**
- Tools must be registered before they can be called
- Defines the capabilities clients can invoke

**What is a Tool?**
- A tool is an executable function that clients can invoke.
- Tools have names, descriptions, and input parameters.
- Clients can discover and call these tools to perform operations.

---

- Add this method to your class:

```python
@self.server.list_tools()
async def list_tools() -> List[Tool]:
    return [
        Tool(
            name="weather_with_ollama",
            description="Get weather information for a city using Ollama AI",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "The city name to get weather for"
                    },
                    "temp_unit": {
                        "type": "string",
                        "enum": ["C", "F"],
                        "default": "C",
                        "description": "Temperature unit (Celsius or Fahrenheit)"
                    }
                },
                "required": ["city"]
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
```

---

## Step 05: Tool Handlers

### Method `register_tool_handlers`

**Capabilities:**
- Implements the logic for each tool
- Handles tool execution and error management
- Returns formatted results

**Why This Runs Third:**
- Connects tool schemas to actual functionality
- Makes tools operational

---

- Add this method to your class:

```python
@self.server.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    if name == "weather_with_ollama":
        city = arguments.get("city", "")
        temp_unit = arguments.get("temp_unit", "C")
        
        if not city:
            raise ValueError("City name is required")
        
        try:
            # Use Ollama to generate weather information
            prompt = f"Generate realistic weather information for {city}. Include temperature, conditions, humidity, and wind speed. Format as a weather report."
            
            response = self.ollama_client.generate(
                model='llama2',  # or your preferred model
                prompt=prompt,
                options={'temperature': 0.7, 'max_tokens': 200}
            )
            
            weather_info = response['response'].strip()
            
            result = f"Weather in {city}:\n{weather_info}\n\n*Generated by Ollama AI*"
            
            return [TextContent(type="text", text=result)]
            
        except Exception as e:
            return [TextContent(type="text", text=f"Error getting weather: {str(e)}")]
    
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
        
        file_size = path.stat().st_size
        if file_size > max_size:
            raise ValueError(f"File too large: {file_size} bytes (max: {max_size})")
        
        try:
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
```

---

## Step 06: Register Resources

### Method `register_resources`

**Capabilities:**
- Registers resource definitions for discovery
- Provides additional data for clients

**Why This Runs Fourth:**
- Resources enhance the server's functionality

**What is a Resource?**
- A resource is readable data or content.
- Resources have URIs and metadata.

---

- Add this method to your class:

```python
@self.server.list_resources()
async def list_resources() -> List[Resource]:
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
```

---

## Step 07: Resource Handlers

### Method `register_resource_handlers`

**Capabilities:**
- Implements resource reading logic

**Why This Runs Fifth:**
- Connects resource URIs to actual content

---

- Add this method to your class:

```python
@self.server.read_resource()
async def read_resource(uri: str) -> str:
    if uri == "resource://server-info":
        info = {
            "name": "Complete Ollama MCP Server",
            "version": "1.0.0",
            "capabilities": ["tools", "resources", "ollama-integration"],
            "tools": ["weather_with_ollama", "read_file", "query_database"]
        }
        return json.dumps(info, indent=2)
    
    elif uri == "resource://ollama-models":
        try:
            models = self.ollama_client.list()
            return json.dumps(models, indent=2)
        except Exception as e:
            return json.dumps({"error": str(e)}, indent=2)
    
    else:
        raise ValueError(f"Unknown resource: {uri}")
```

---

## Step 08: Register Prompts

### Method `register_prompts`

**Capabilities:**
- Registers prompt templates

**Why This Runs Sixth:**
- Provides structured prompts for AI interactions

**What is a Prompt?**
- A prompt is a template that guides AI assistants.

---

- Add this method to your class:

```python
@self.server.list_prompts()
async def list_prompts() -> List[Prompt]:
    return [
        Prompt(
            name="analyze-weather-data",
            description="Analyze weather data and provide insights",
            arguments=[
                {
                    "name": "city",
                    "description": "City to analyze weather for",
                    "required": True
                }
            ]
        )
    ]
```

---

## Step 09: Prompt Handlers

### Method `register_prompt_handlers`

**Capabilities:**
- Generates prompt content

**Why This Runs Seventh:**
- Connects prompt templates to actual content

---

- Add this method to your class:

```python
@self.server.get_prompt()
async def get_prompt(name: str, arguments: Dict[str, Any]) -> GetPromptResult:
    if name == "analyze-weather-data":
        city = arguments.get("city", "Unknown City")
        prompt_text = f"""Analyze the weather data for {city} and provide insights:

1. Use the weather_with_ollama tool to get current weather information
2. Analyze the temperature, conditions, and other factors
3. Provide recommendations based on the weather
4. Consider seasonal patterns and typical conditions

Please provide a comprehensive weather analysis."""
        
        return GetPromptResult(
            description=f"Weather analysis prompt for {city}",
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
```

---

## Step 10: Lifecycle Handlers

### Method `setup_lifecycle_handlers`

**Capabilities:**
- Handles server initialization and shutdown

**Why This Runs Eighth:**
- Ensures proper server lifecycle management

---

- Add this method to your class:

```python
def _setup_handlers(self):
    # Register all handlers
    self.register_tools()
    self.register_tool_handlers()
    self.register_resources()
    self.register_resource_handlers()
    self.register_prompts()
    self.register_prompt_handlers()
    self.setup_lifecycle_handlers()
```

---

## Step 11: Run the Server

### Method `run`

**Capabilities:**
- Starts the MCP server

**Why This Runs Last:**
- Initiates the server operation

---

- Add this method to your class:

```python
async def run(self):
    async with stdio_server() as (read_stream, write_stream):
        await self.server.run(read_stream, write_stream, self.server.create_initialization_options())
```

---

## Step 12: Main / Entry Point

**What is the Main Entry Point?**
- The starting point of the script

---

```python
async def main():
    server = CompleteOllamaMCPServer()
    await server.run()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Error Handling Patterns

### Pattern 1: Input Validation

!!! question "Input Validation"
    **Definition:** Ensures tool arguments meet requirements before processing.  
    **Why:** Prevents runtime errors and provides clear feedback.  
    **Usage:** Validate inputs early in tool handlers.

```python
if not city:
    raise ValueError("City name is required")
```

**When to use -** For all tool inputs and external data:

  - User-provided parameters and arguments
  - File paths and resource identifiers
  - Network requests and API parameters
  - Database queries and data inputs
  - Any data that could be malformed or malicious

**Why it matters:** Prevents crashes, security vulnerabilities, and unexpected behavior by catching invalid inputs early with clear error messages.

### Pattern 2: Graceful Degradation

!!! question "Graceful Degradation"
    **Definition:** Provides partial functionality when full operation isn't possible.  
    **Why:** Users get some value even when systems fail partially.  
    **Usage:** Return useful information or fallbacks.

```python
try:
    # Attempt full operation
    pass
except Exception as e:
    # Return partial results or error message
    return [TextContent(type="text", text=f"Partial result: {str(e)}")]
```

**When to use -** For external dependencies that might be unreliable:

  - API calls that could timeout or fail
  - Network-dependent operations
  - Services with occasional downtime
  - When partial results are better than no results

**Why it matters:** Users get some value even when systems are partially broken, improving overall reliability and user experience.

### Pattern 3: Detailed Error Context

!!! question "Detailed Error Context"
    **Definition:** Provides comprehensive debugging information.  
    **Why:** Enables effective troubleshooting while keeping user messages clean.  
    **Usage:** Log details internally, expose safe messages to users.

```python
except Exception as e:
    print(f"Internal error: {str(e)}", file=sys.stderr)
    return [TextContent(type="text", text="An error occurred. Please try again.")]
```

**When to use -** For complex operations where debugging might be needed:

  - Multi-step processes with potential failure points
  - Operations involving external systems
  - When you need to track error patterns over time
  - Production environments where detailed logging is crucial

**Why it matters:** Developers can diagnose issues effectively while users get clear, non-technical error messages.

---

## Async Operations and Performance

### Long-Running Operations

!!! question "Long-Running Operations"
    **Definition:** Operations that take significant time to complete.  
    **Why:** Prevents timeouts and provides feedback.  
    **Usage:** Use async/await and provide progress updates.

```python
async def long_operation():
    print("Starting long operation...", file=sys.stderr)
    await asyncio.sleep(5)  # Simulate work
    print("Operation completed.", file=sys.stderr)
    return result
```

**When to use -** For operations that take more than a few seconds:

  - Large file processing or analysis
  - Complex computations
  - External API calls with potential delays
  - Batch operations on multiple items

**Why it matters:** Prevents timeouts, provides user feedback, enables monitoring and debugging of slow operations.

### Caching Results

!!! question "Caching Results"
    **Definition:** Stores results of expensive operations.  
    **Why:** Improves response times for repeated requests.  
    **Usage:** Implement a simple cache with expiration.

```python
cache = {}
async def cached_operation(key):
    if key in cache and time.time() - cache[key]['timestamp'] < 300:  # 5 min
        return cache[key]['data']
    # Compute result
    result = await expensive_operation()
    cache[key] = {'data': result, 'timestamp': time.time()}
    return result
```

**When to use -** For expensive operations that return consistent results:

  - API calls to external services
  - Complex calculations or data processing
  - Database queries with static data
  - File analysis that doesn't change frequently

**Why it matters:** Dramatically improves response times, reduces resource usage, and provides better user experience for repeated requests.

---

## Tool Composition

### Example: Multi-Step Analysis

!!! question "Multi-Step Analysis"
    **Definition:** Combining simple tools for complex workflows.  
    **Why:** Enables sophisticated operations through tool chaining.  
    **Usage:** Design tools that work well together.

```python
# Tool 1: Get weather
# Tool 2: Analyze data
# Tool 3: Generate report
# LLM can chain: weather -> analyze -> report
```

**When to use -** For workflows that require multiple processing steps:

  - Data analysis pipelines
  - File processing workflows
  - Multi-stage computations
  - Complex research tasks

**Why it matters:** Breaks down complex problems into manageable, reusable components that can be combined in flexible ways.

### LLM Tool Chaining

!!! question "LLM Tool Chaining"
    **Definition:** AI automatically sequences tool calls.  
    **Why:** Enables complex reasoning without explicit programming.  
    **Usage:** Design tool outputs as inputs for other tools.

```python
# Example of how an LLM might chain tools:
# 1. Use weather_with_ollama to get weather data
# 2. Use read_file to get historical weather patterns
# 3. Use query_database to store analysis results

async def analyze_weather_trends(city: str):
    """LLM can automatically chain these calls"""
    
    # Step 1: Get current weather
    weather_result = await call_tool("weather_with_ollama", {"city": city})
    
    # Step 2: Read historical data file
    historical_data = await call_tool("read_file", {
        "filepath": f"data/{city}_weather_history.txt"
    })
    
    # Step 3: Store analysis in database
    analysis_query = f"""
    INSERT INTO weather_analysis (city, current_weather, historical_data, timestamp)
    VALUES ('{city}', '{weather_result[0].text}', '{historical_data[0].text}', datetime('now'))
    """
    
    db_result = await call_tool("query_database", {"query": analysis_query})
    
    return {
        "current": weather_result[0].text,
        "historical": historical_data[0].text,
        "stored": db_result[0].text
    }
```

**When to use -** When tasks naturally break down into sequential steps:

  - Research and analysis workflows
  - Data processing pipelines
  - Content generation chains
  - Problem-solving sequences

**Why it matters:** Enables complex, multi-step reasoning and problem-solving that would be difficult to implement in single tools.

---

## Hands-On Exercises



!!! question "Exercise 1: Text Processing Tool"
    **Definition:** A tool for analyzing and processing text content.  
    **Why:** Enables text manipulation and analysis operations.  
    **Usage:** Process text for counting, patterns, and metrics.

    **Task:** Create a new MCP tool called `process_text` that analyzes and processes text content. The tool should support multiple operations: counting words/characters/lines, finding regex patterns, and calculating reading time. Add this tool to your `CompleteOllamaMCPServer` class by updating the `list_tools()` method and `call_tool()` handler.



<details>
<summary>💡 Complete Exercise 1 Solution</summary>

<h4>Step 1: Add Tool Definition</h4>

Add to `list_tools()`:

```python
Tool(
    name="process_text",
    description="Analyze and process text content",
    inputSchema={
        "type": "object",
        "properties": {
            "text": {"type": "string", "description": "Text to process"},
            "operations": {
                "type": "array",
                "items": {"type": "string", "enum": ["count", "find_pattern", "reading_time"]},
                "description": "Operations to perform"
            },
            "pattern": {"type": "string", "description": "Regex pattern for find_pattern"}
        },
        "required": ["text", "operations"]
    }
)
```

<h4>Step 2: Add Handler Logic</h4>

Add to `call_tool()`:

```python
elif name == "process_text":
    text = arguments.get("text", "")
    operations = arguments.get("operations", [])
    pattern = arguments.get("pattern", "")
    
    result = ""
    if "count" in operations:
        words = len(text.split())
        chars = len(text)
        lines = len(text.split('\n'))
        result += f"Words: {words}, Characters: {chars}, Lines: {lines}\n"
    
    if "find_pattern" in operations and pattern:
        import re
        matches = re.findall(pattern, text)
        result += f"Pattern matches: {matches}\n"
    
    if "reading_time" in operations:
        words_per_minute = 200
        minutes = len(text.split()) / words_per_minute
        result += f"Estimated reading time: {minutes:.1f} minutes\n"
    
    return [TextContent(type="text", text=result)]
```

<h4>Step 3: Test the Tool</h4>

Test with various inputs to verify functionality.

</details>

---



!!! question "Exercise 2: JSON Validator Tool"
    **Definition:** A tool for validating and processing JSON data.  
    **Why:** Ensures data integrity and provides JSON utilities.  
    **Usage:** Validate, format, and compare JSON structures.

    **Task:** Create a new MCP tool called `validate_json` that validates and processes JSON data. The tool should support four operations: validating JSON syntax, formatting/pretty-printing JSON, validating against a JSON schema, and comparing two JSON objects. You'll need to install the `jsonschema` package and add the necessary imports. Update your server class to include this tool in the `list_tools()` method and `call_tool()` handler.



<details>
<summary>💡 Complete Exercise 2 Solution</summary>

<h4>Step 1: Install Dependencies</h4>

```bash
pip install jsonschema
```

<h4>Step 2: Add Imports</h4>

```python
import jsonschema
```

<h4>Step 3: Add Tool Definition</h4>

Add to `list_tools()`:

```python
Tool(
    name="validate_json",
    description="Validate and process JSON data",
    inputSchema={
        "type": "object",
        "properties": {
            "json": {"type": "string", "description": "JSON string to validate"},
            "operation": {"type": "string", "enum": ["validate", "format", "schema_validate", "compare"]},
            "schema": {"type": "string", "description": "JSON schema for validation"},
            "json2": {"type": "string", "description": "Second JSON for comparison"}
        },
        "required": ["json", "operation"]
    }
)
```

<h4>Step 4: Add Handler Logic</h4>

Add to `call_tool()`:

```python
elif name == "validate_json":
    json_str = arguments.get("json", "")
    operation = arguments.get("operation", "validate")
    schema_str = arguments.get("schema", "")
    json2_str = arguments.get("json2", "")
    
    try:
        data = json.loads(json_str)
        
        if operation == "validate":
            result = "JSON is valid"
        elif operation == "format":
            result = json.dumps(data, indent=2)
        elif operation == "schema_validate" and schema_str:
            schema = json.loads(schema_str)
            jsonschema.validate(data, schema)
            result = "JSON validates against schema"
        elif operation == "compare" and json2_str:
            data2 = json.loads(json2_str)
            if data == data2:
                result = "JSON objects are identical"
            else:
                result = "JSON objects differ"
        
        return [TextContent(type="text", text=result)]
    except Exception as e:
        return [TextContent(type="text", text=f"Error: {str(e)}")]
```

<h4>Step 5: Test the Tool</h4>

Test validation, formatting, and comparison operations.

</details>


---



!!! question "Exercise 3: Web Scraper Tool"
    **Definition:** A tool for extracting content from web pages.  
    **Why:** Enables data collection from web sources.  
    **Usage:** Fetch and parse web content safely.

    **Task:** Create a new MCP tool called `scrape_web` that extracts content from web pages. The tool should fetch web pages, extract specific elements using CSS selectors, return clean text content, and handle errors gracefully. You'll need to install the `beautifulsoup4` and `lxml` packages and add the necessary imports. Update your server class to include this tool in the `list_tools()` method and `call_tool()` handler.



<details>
<summary>💡 Complete Exercise 3 Solution</summary>

<h4>Step 1: Install Dependencies</h4>

```bash
pip install beautifulsoup4 lxml
```

<h4>Step 2: Add Imports</h4>

```python
from bs4 import BeautifulSoup
```

<h4>Step 3: Add Tool Definition</h4>

Add to `list_tools()`:

```python
Tool(
    name="scrape_web",
    description="Extract content from web pages",
    inputSchema={
        "type": "object",
        "properties": {
            "url": {"type": "string", "description": "URL to scrape"},
            "selector": {"type": "string", "description": "CSS selector for content"},
            "include_html": {"type": "boolean", "default": False, "description": "Include HTML tags"}
        },
        "required": ["url"]
    }
)
```

<h4>Step 4: Add Handler Logic</h4>

Add to `call_tool()`:

```python
elif name == "scrape_web":
    url = arguments.get("url", "")
    selector = arguments.get("selector", "")
    include_html = arguments.get("include_html", False)
    
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'lxml')
        
        if selector:
            elements = soup.select(selector)
            if include_html:
                content = '\n'.join(str(el) for el in elements)
            else:
                content = '\n'.join(el.get_text() for el in elements)
        else:
            content = soup.get_text() if not include_html else str(soup)
        
        return [TextContent(type="text", text=content)]
    except Exception as e:
        return [TextContent(type="text", text=f"Error scraping web: {str(e)}")]
```

<h4>Step 5: Test the Tool</h4>

Test with different URLs and selectors, handling errors gracefully.

</details>
