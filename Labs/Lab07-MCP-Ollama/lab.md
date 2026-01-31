# Complete MCP Server with Ollama Integration - Hands-On Lab

## Lab Objective

- In this hands-on lab, you'll build a complete MCP (Model Context Protocol) server from scratch with Ollama integration.
- You'll learn how each component works by implementing it yourself, understanding why each piece is necessary, and seeing the complete architecture come together.
- You'll implement advanced tools: Country Information with RAG (Retrieval-Augmented Generation) using separate CSV-based databases for different information types covering all 193 UN member states, File Operations, and Database Query, along with best practices for error handling, async operations, and tool composition.

!!! warning "Important Instructions"

    - This lab is designed to be followed step-by-step.
    - Each code block builds upon the previous ones.
    - Do not copy all code blocks at once, as this may lead to duplicate methods or incorrect structure.
    - Follow the instructions sequentially, updating existing code as indicated.

---

## Prerequisites

- `Python 3.10` or higher installed
- `Ollama` installed and running locally with models available (e.g., llama3.2)
- Basic knowledge of `MCP` concepts
- Basic understanding of `REST APIs` and `JSON`
- Familiarity with `CSV` files and data handling
- Basic understanding of `Python` programming
- Terminal / command line (`CLI`) access
- Text editor or IDE (`VS Code` is recommended)

---

## Step 00: Getting Started

1.  Create a new file called `mcp_ollama.py` as your project file, inside the lab's directory.
2.  Open it in your chosen text editor.
3.  See the following CSV files, containing data of all 193 UN member states, have been created for you in the lab's directory (you can open these files in VSCode etc.):

| File                  | Columns                      | Description                          |
| --------------------- | ---------------------------- | ------------------------------------ |
| `capitals.csv`        | `country`, `capital`         | Capital cities of countries          |
| `population.csv`      | `country`, `population`      | Population data                      |
| `height.csv`          | `country`, `height`          | Average topographic height in meters |
| `foundation_year.csv` | `country`, `foundation_year` | Year the country was founded         |

4.  **Important:** Ensure all CSV files are in the same directory as your `mcp_ollama.py` file, as the code loads them from the current working directory.
5.  Create a file named `requirements.txt` with the following content, inside the lab’s directory:

```
mcp>=0.1.0
ollama>=0.1.0
pandas>=1.3.0
requests>=2.25.0
```

6.  Install the dependencies by running the following from the same directory as your `requirements.txt` file, inside the lab’s directory:

```bash
pip install -r requirements.txt
```

---

## Step 01: Adding Imports

- Before we write any code, we need to understand which Python libraries we'll be using, and why.

### `asyncio` - Asynchronous I/O

!!! question "asyncio"

#### Definition:

    - A library for writing concurrent code using the async/await syntax.

#### Why:

    - Enables non-blocking I/O operations, crucial for handling multiple client requests simultaneously without freezing the server.

#### Usage:

    - Used for async functions, event loops, and coordinating concurrent tasks in the MCP server.

---

### `json` - JavaScript Object Notation

!!! question "json"

#### Definition:

    - A module for parsing and generating JSON data.

#### Why:

    - MCP uses JSON-RPC for communication between clients and servers.

#### Usage:

    - Serializing/deserializing data sent over stdio transport.

---

### `typing` - Type Hints

!!! question "typing"

#### Definition:

    - Provides runtime support for type hints.

#### Why:

    - Improves code readability, enables better IDE support, and catches type-related errors early.

#### Usage:

    - Defining function signatures and data structures with proper types.

---

### `mcp.server` - Core MCP Server

!!! question "mcp.server"

#### Definition:

    - The main server class for implementing MCP servers.

#### Why:

    - Provides the framework for registering tools, resources, and prompts, and handling client requests.

#### Usage:

    - Creating the server instance and setting up request handlers.

---

### `mcp.server.stdio` - Standard I/O Transport

!!! question "mcp.server.stdio"

#### Definition:

    - Transport layer for communication via standard input/output streams.

#### Why:

    - Enables MCP servers to communicate with clients through stdin/stdout, making them easily integrable with various applications.

#### Usage:

    - Establishing the communication channel for the server.

---

### `mcp.types` - Protocol Types

!!! question "mcp.types"

#### Definition:

    - Type definitions for MCP protocol messages and data structures.

#### Why:

    - Ensures type safety and consistency when working with MCP messages.

#### Usage:

    - Defining request/response schemas and content types.

**Key Types Used:**

- **`Resource`**: Defines a resource (readable data/content) with URI, name, description, and MIME type
- **`Tool`**: Defines a tool (executable function) with name, description, and input schema
- **`TextContent`**, **`ImageContent`**: Content types for tool/resource responses
- **`Prompt`**: Defines a prompt template with name, description, and required arguments
- **`GetPromptResult`**: Result structure when retrieving a prompt
- **`CallToolResult`**: Result structure when calling a tool
- **`ListResourcesResult`**, **`ListToolsResult`**, **`ListPromptsResult`**: Results when listing available resources/tools/prompts
- **`ReadResourceResult`**: Result structure when reading a resource

---

### `sys` - System Functions

!!! question "sys"

#### Definition:

    - Provides access to system-specific parameters and functions.

#### Why:

    - Needed for handling command-line arguments and system-level operations.

#### Usage:

    - Accessing stdin/stdout streams and handling program exit.

---

### `requests` - HTTP Library

!!! question "requests"

#### Definition:

    - A simple HTTP library for making web requests.

#### Why:

    - Used for interacting with external APIs and services.

#### Usage:

    - Making HTTP calls to fetch data from web services.

---

### `sqlite3` - SQLite Database

!!! question "sqlite3"

#### Definition:

    - Python's built-in SQLite database module.

#### Why:

    - Provides a lightweight, file-based database for data storage and querying.

#### Usage:

    - Executing SQL queries and managing database operations.

---

### `pandas` - Data Analysis Library

!!! question "pandas"

#### Definition:

    - A powerful data manipulation and analysis library.

#### Why:

    - Used for reading CSV files and managing structured data.

#### Usage:

    - Loading country data from CSV files for RAG retrieval.

---

Paste the following imports code inside the `mcp_ollama.py` file:

```python
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
```

---

## Step 02: Skeleton Code - Class

### Class Definition

Append this class definition code after the imports in your `mcp_ollama.py` file:

```python
class CompleteOllamaMCPServer:
  def __init__(self):
    self.server = Server("complete-ollama-mcp-server")
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
- Loads country data from Excel files for RAG retrieval

**Why This Runs First:**

- Establishes the foundation for all server operations
- Sets up the basic state of the server
- Ensures all dependencies are ready before registering components

---

**Update the `__init__` method** inside your `CompleteOllamaMCPServer` class to include the full initialization:

```python
  def __init__(self):
    self.server = Server("complete-ollama-mcp-server")
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
```

---

## Step 04: Register Tools

### Method `list_tools`

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

Add this method to your class:

```python
@self.server.list_tools()
async def list_tools() -> List[Tool]:
  return [
    Tool(
      name="country_info",
      description="Get country information using RAG from CSV databases",
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
```

---

## Step 05: Tool Handlers

### Method `call_tool`

**Capabilities:**

- Implements the logic for each tool
- Handles tool execution and error management
- Returns formatted results

**Why This Runs Third:**

- Connects tool schemas to actual functionality
- Makes tools operational

---

Add this method to your class:

```python
@self.server.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
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

### Method `list_resources`

**Capabilities:**

- Registers resource definitions for discovery
- Provides additional data for clients

**Why This Runs Fourth:**

- Resources enhance the server's functionality
- Allows clients to access static or dynamic data

**What is a Resource?**

- A resource is readable data or content.
- Resources have URIs and metadata.

---

Add this method to your class:

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
- Handles resource requests and returns content

**Why This Runs Fifth:**

- Connects resource URIs to actual content
- Makes resources accessible to clients

---

Add this method to your class:

```python
@self.server.read_resource()
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
```

---

## Step 08: Register Prompts

### Method `list_prompts`

**Capabilities:**

- Registers prompt templates
- Defines structured prompts for AI interactions

**Why This Runs Sixth:**

- Provides structured prompts for AI interactions
- Enables clients to request specific prompt templates

**What is a Prompt?**

- A prompt is a template that guides AI assistants.
- Prompts have names, descriptions, and required arguments.

---

Add this method to your class:

```python
@self.server.list_prompts()
async def list_prompts() -> List[Prompt]:
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
```

---

## Step 09: Prompt Handlers

### Method `get_prompt`

**Capabilities:**

- Generates prompt content.
- Handles prompt requests and returns structured messages.

**Why This Runs Seventh:**

- Connects prompt templates to actual content.
- Makes prompts usable by clients.

---

Add this method to your class:

```python
@self.server.get_prompt()
async def get_prompt(name: str, arguments: Dict[str, Any]) -> GetPromptResult:
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
```

---

## Step 10: Setup Handlers

### Method `_setup_handlers`

**Capabilities:**

- Placeholder for handler setup (decorators handle registration automatically).
- Adds structure for future setup logic.

**Why This Runs:**

- Ensures the initialization completes properly.
- Maintains structure for potential future setup logic.

---

Update the `_setup_handlers` method in your class (it should already exist from Step 02):

```python
def _setup_handlers(self):
  # Handlers are registered automatically via decorators
  pass
```

---

## Step 11: Run the Server

### Method `run`

**Capabilities:**

- Starts the MCP server.
- Handles stdio communication.
- Manages server lifecycle.

**Why This Runs Last:**

- Initiates the server operation.
- Begins listening for client requests.

---

Add this method to your class:

```python
async def run(self):
  async with stdio_server() as (read_stream, write_stream):
    await self.server.run(read_stream, write_stream, self.server.create_initialization_options())
```

---

## Step 12: Main / Entry Point

**What is the Main Entry Point?**

- The starting point of the script.
- Initializes and runs the MCP server.
- Ensures the server starts when the script is executed.
- Uses `asyncio.run()` to manage the event loop for async operations.

**Why this runs at the end:**

- Ensures all class definitions and methods are in place before starting the server.
- Provides a clear entry point for execution.
- Manages the asynchronous nature of the server.

---

Add this code at the end of your `mcp_ollama.py` file:

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
if not country:
  raise ValueError("Country name is required")
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
  # Attempt to generate AI response with Ollama
  response = self.ollama_client.generate(model='llama3.2', prompt=prompt)
  result = response['response'].strip()
  return [TextContent(type="text", text=result)]
except Exception as e:
  # Return partial results with raw data
  return [TextContent(type="text", text=f"Error getting AI response: {str(e)}\n\nRaw Data: {retrieved_info}")]
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
  print(f"Internal error loading country data: {str(e)}", file=sys.stderr)
  return [TextContent(type="text", text="An error occurred while processing country information. Please try again.")]
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
async def analyze_country_data(country: str):
  print(f"Starting analysis for {country}...", file=sys.stderr)
  # Simulate data processing
  await asyncio.sleep(2)
  print("Analysis completed.", file=sys.stderr)
  return f"Analysis result for {country}"
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
async def get_cached_country_info(country: str):
  if country in cache and time.time() - cache[country]['timestamp'] < 3600:  # 1 hour
    return cache[country]['data']
  # Fetch fresh data
  result = await fetch_country_data(country)
  cache[country] = {'data': result, 'timestamp': time.time()}
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
# Tool 1: Get country info
# Tool 2: Analyze data
# Tool 3: Generate report
# LLM can chain: country_info -> analyze -> report
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
# 1. Use country_info to get country data
# 2. Use read_file to get historical data file
# 3. Use query_database to store analysis results

async def analyze_country_trends(country: str):
  """LLM can automatically chain these calls"""

  # Step 1: Get country information
  country_result = await call_tool("country_info", {
    "country": country,
    "info_types": ["capital", "population", "height", "foundation_year"]
  })

  # Step 2: Read historical data file
  historical_data = await call_tool("read_file", {
    "filepath": f"data/{country}_history.txt"
  })

  # Step 3: Store analysis in database
  analysis_query = f"""
  INSERT INTO country_analysis (country, info, historical_data, timestamp)
  VALUES ('{country}', '{country_result[0].text}', '{historical_data[0].text}', datetime('now'))
  """

  db_result = await call_tool("query_database", {"query": analysis_query})

  return {
    "country_info": country_result[0].text,
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
