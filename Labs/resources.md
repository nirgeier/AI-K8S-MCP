# MCP Server Examples

This section provides complete, working examples of MCP servers in both TypeScript and Python. These examples demonstrate the core concepts of MCP server development and can be used as starting points for your own implementations.

## TypeScript MCP Server Example

### Complete MCP Server with Tools, Resources, and Prompts

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { readFileSync } from "fs";
import fetch from "node-fetch";

class MCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "example-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
          prompts: {},
        },
      }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    // Tools handlers
    this.server.setRequestHandler("tools/list", async () => {
      return {
        tools: [
          {
            name: "calculate",
            description: "Perform basic arithmetic operations",
            inputSchema: {
              type: "object",
              properties: {
                operation: {
                  type: "string",
                  enum: ["add", "subtract", "multiply", "divide"]
                },
                a: { type: "number" },
                b: { type: "number" }
              },
              required: ["operation", "a", "b"]
            }
          },
          {
            name: "get_weather",
            description: "Get current weather for a city",
            inputSchema: {
              type: "object",
              properties: {
                city: { type: "string" }
              },
              required: ["city"]
            }
          },
          {
            name: "read_file",
            description: "Read contents of a file",
            inputSchema: {
              type: "object",
              properties: {
                path: { type: "string" }
              },
              required: ["path"]
            }
          }
        ]
      };
    });

    this.server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case "calculate":
          return this.handleCalculate(args);
        case "get_weather":
          return this.handleWeather(args);
        case "read_file":
          return this.handleReadFile(args);
        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });

    // Resources handlers
    this.server.setRequestHandler("resources/list", async () => {
      return {
        resources: [
          {
            uri: "file://server-info",
            name: "Server Information",
            description: "Information about this MCP server",
            mimeType: "application/json"
          },
          {
            uri: "file://system-status",
            name: "System Status",
            description: "Current system status and metrics",
            mimeType: "application/json"
          }
        ]
      };
    });

    this.server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      switch (uri) {
        case "file://server-info":
          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify({
                name: "Example MCP Server",
                version: "1.0.0",
                capabilities: ["tools", "resources", "prompts"],
                uptime: process.uptime()
              }, null, 2)
            }]
          };
        case "file://system-status":
          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify({
                platform: process.platform,
                nodeVersion: process.version,
                memory: process.memoryUsage(),
                cpuUsage: process.cpuUsage()
              }, null, 2)
            }]
          };
        default:
          throw new Error(`Resource not found: ${uri}`);
      }
    });

    // Prompts handlers
    this.server.setRequestHandler("prompts/list", async () => {
      return {
        prompts: [
          {
            name: "code_review",
            description: "Review code for best practices and improvements",
            arguments: [
              {
                name: "code",
                description: "The code to review",
                required: true
              },
              {
                name: "language",
                description: "Programming language",
                required: false
              }
            ]
          },
          {
            name: "debug_help",
            description: "Get help debugging an issue",
            arguments: [
              {
                name: "problem",
                description: "Description of the problem",
                required: true
              },
              {
                name: "code",
                description: "Relevant code snippet",
                required: false
              }
            ]
          }
        ]
      };
    });

    this.server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case "code_review":
          return {
            description: "Code Review Assistant",
            messages: [
              {
                role: "user",
                content: {
                  type: "text",
                  text: `Please review the following ${args.language || 'code'} for best practices, potential bugs, and improvements:\n\n${args.code}\n\nPlease provide:\n1. Code quality assessment\n2. Potential issues or bugs\n3. Suggestions for improvement\n4. Best practices recommendations`
                }
              }
            ]
          };
        case "debug_help":
          return {
            description: "Debugging Assistant",
            messages: [
              {
                role: "user",
                content: {
                  type: "text",
                  text: `I'm experiencing this problem: ${args.problem}\n\n${args.code ? `Here's the relevant code:\n${args.code}\n` : ''}\n\nPlease help me:\n1. Understand what might be causing this issue\n2. Suggest debugging steps\n3. Provide potential solutions\n4. Recommend best practices to avoid similar issues`
                }
              }
            ]
          };
        default:
          throw new Error(`Unknown prompt: ${name}`);
      }
    });
  }

  private handleCalculate(args: any) {
    const { operation, a, b } = args;
    let result: number;

    switch (operation) {
      case "add":
        result = a + b;
        break;
      case "subtract":
        result = a - b;
        break;
      case "multiply":
        result = a * b;
        break;
      case "divide":
        if (b === 0) throw new Error("Division by zero");
        result = a / b;
        break;
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }

    return {
      content: [{
        type: "text",
        text: `Result: ${result}`
      }]
    };
  }

  private async handleWeather(args: any) {
    const { city } = args;
    const apiKey = process.env.WEATHER_API_KEY;

    if (!apiKey) {
      throw new Error("Weather API key not configured");
    }

    try {
      const response = await fetch(
        `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`
      );

      if (!response.ok) {
        throw new Error(`Weather API error: ${response.status}`);
      }

      const data = await response.json();

      return {
        content: [{
          type: "text",
          text: `Weather in ${city}: ${data.weather[0].description}, ${data.main.temp}°C`
        }]
      };
    } catch (error) {
      throw new Error(`Weather fetch failed: ${error.message}`);
    }
  }

  private handleReadFile(args: any) {
    const { path } = args;

    try {
      const content = readFileSync(path, "utf-8");
      return {
        content: [{
          type: "text",
          text: content
        }]
      };
    } catch (error) {
      throw new Error(`Failed to read file: ${error.message}`);
    }
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("MCP Server started");
  }
}

// Start the server
const server = new MCPServer();
server.start().catch(console.error);
```

### package.json for TypeScript MCP Server

```json
{
  "name": "example-mcp-server-ts",
  "version": "1.0.0",
  "description": "Example MCP server in TypeScript",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx src/index.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "node-fetch": "^3.3.2"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Python MCP Server Example

### Complete MCP Server with Tools, Resources, and Prompts

```python
#!/usr/bin/env python3

import asyncio
import json
import os
import sys
from typing import Any, Dict, List
import httpx
from mcp import Tool, types
from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("example-mcp-server")

@server.list_tools()
async def list_tools() -> List[Tool]:
    """List available tools."""
    return [
        Tool(
            name="calculate",
            description="Perform basic arithmetic operations",
            inputSchema={
                "type": "object",
                "properties": {
                    "operation": {
                        "type": "string",
                        "enum": ["add", "subtract", "multiply", "divide"]
                    },
                    "a": {"type": "number"},
                    "b": {"type": "number"}
                },
                "required": ["operation", "a", "b"]
            }
        ),
        Tool(
            name="get_weather",
            description="Get current weather for a city",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {"type": "string"}
                },
                "required": ["city"]
            }
        ),
        Tool(
            name="read_file",
            description="Read contents of a file",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string"}
                },
                "required": ["path"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[types.TextContent]:
    """Handle tool calls."""
    if name == "calculate":
        return await handle_calculate(arguments)
    elif name == "get_weather":
        return await handle_weather(arguments)
    elif name == "read_file":
        return await handle_read_file(arguments)
    else:
        raise ValueError(f"Unknown tool: {name}")

async def handle_calculate(args: Dict[str, Any]) -> List[types.TextContent]:
    """Handle calculator tool."""
    operation = args["operation"]
    a = args["a"]
    b = args["b"]

    if operation == "add":
        result = a + b
    elif operation == "subtract":
        result = a - b
    elif operation == "multiply":
        result = a * b
    elif operation == "divide":
        if b == 0:
            raise ValueError("Division by zero")
        result = a / b
    else:
        raise ValueError(f"Unknown operation: {operation}")

    return [types.TextContent(type="text", text=f"Result: {result}")]

async def handle_weather(args: Dict[str, Any]) -> List[types.TextContent]:
    """Handle weather tool."""
    city = args["city"]
    api_key = os.getenv("WEATHER_API_KEY")

    if not api_key:
        raise ValueError("Weather API key not configured")

    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
        )

        if response.status_code != 200:
            raise ValueError(f"Weather API error: {response.status_code}")

        data = response.json()
        weather_desc = data["weather"][0]["description"]
        temp = data["main"]["temp"]

        return [types.TextContent(
            type="text",
            text=f"Weather in {city}: {weather_desc}, {temp}°C"
        )]

async def handle_read_file(args: Dict[str, Any]) -> List[types.TextContent]:
    """Handle file reading tool."""
    path = args["path"]

    try:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        return [types.TextContent(type="text", text=content)]
    except Exception as e:
        raise ValueError(f"Failed to read file: {e}")

@server.list_resources()
async def list_resources() -> List[types.Resource]:
    """List available resources."""
    return [
        types.Resource(
            uri="file://server-info",
            name="Server Information",
            description="Information about this MCP server",
            mimeType="application/json"
        ),
        types.Resource(
            uri="file://system-status",
            name="System Status",
            description="Current system status and metrics",
            mimeType="application/json"
        )
    ]

@server.read_resource()
async def read_resource(uri: str) -> str:
    """Read resource content."""
    if uri == "file://server-info":
        import psutil
        import time

        info = {
            "name": "Example MCP Server",
            "version": "1.0.0",
            "capabilities": ["tools", "resources", "prompts"],
            "uptime": time.time() - psutil.boot_time()
        }
        return json.dumps(info, indent=2)

    elif uri == "file://system-status":
        import psutil

        status = {
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory": {
                "total": psutil.virtual_memory().total,
                "available": psutil.virtual_memory().available,
                "percent": psutil.virtual_memory().percent
            },
            "disk": {
                "total": psutil.disk_usage('/').total,
                "free": psutil.disk_usage('/').free,
                "percent": psutil.disk_usage('/').percent
            }
        }
        return json.dumps(status, indent=2)

    else:
        raise ValueError(f"Resource not found: {uri}")

@server.list_prompts()
async def list_prompts() -> List[types.Prompt]:
    """List available prompts."""
    return [
        types.Prompt(
            name="code_review",
            description="Review code for best practices and improvements",
            arguments=[
                types.PromptArgument(
                    name="code",
                    description="The code to review",
                    required=True
                ),
                types.PromptArgument(
                    name="language",
                    description="Programming language",
                    required=False
                )
            ]
        ),
        types.Prompt(
            name="debug_help",
            description="Get help debugging an issue",
            arguments=[
                types.PromptArgument(
                    name="problem",
                    description="Description of the problem",
                    required=True
                ),
                types.PromptArgument(
                    name="code",
                    description="Relevant code snippet",
                    required=False
                )
            ]
        )
    ]

@server.get_prompt()
async def get_prompt(name: str, arguments: Dict[str, Any]) -> types.GetPromptResult:
    """Get prompt content."""
    if name == "code_review":
        code = arguments.get("code", "")
        language = arguments.get("language", "")

        return types.GetPromptResult(
            description="Code Review Assistant",
            messages=[
                types.PromptMessage(
                    role="user",
                    content=types.TextContent(
                        type="text",
                        text=f"""Please review the following {language or 'code'} for best practices, potential bugs, and improvements:

{code}

Please provide:
1. Code quality assessment
2. Potential issues or bugs
3. Suggestions for improvement
4. Best practices recommendations"""
                    )
                )
            ]
        )

    elif name == "debug_help":
        problem = arguments.get("problem", "")
        code = arguments.get("code", "")

        content = f"I'm experiencing this problem: {problem}\n\n"
        if code:
            content += f"Here's the relevant code:\n{code}\n\n"

        content += """Please help me:
1. Understand what might be causing this issue
2. Suggest debugging steps
3. Provide potential solutions
4. Recommend best practices to avoid similar issues"""

        return types.GetPromptResult(
            description="Debugging Assistant",
            messages=[
                types.PromptMessage(
                    role="user",
                    content=types.TextContent(type="text", text=content)
                )
            ]
        )

    else:
        raise ValueError(f"Unknown prompt: {name}")

async def main():
    """Main server function."""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
```

### requirements.txt for Python MCP Server

```txt
mcp>=0.1.0
httpx>=0.25.0
psutil>=5.9.0
```

### pyproject.toml (Alternative to requirements.txt)

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "example-mcp-server-py"
version = "1.0.0"
description = "Example MCP server in Python"
dependencies = [
    "mcp>=0.1.0",
    "httpx>=0.25.0",
    "psutil>=5.9.0"
]

[project.scripts]
mcp-server = "main:main"

[tool.setuptools]
packages = ["."]
```

---

## Running the Examples

### TypeScript Server

```bash
# Install dependencies
npm install

# Build the server
npm run build

# Run the server
npm start
```

### Python Server

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python server.py
```

## Configuration for Roo Code

To use these servers with Roo Code, add them to your MCP configuration:

```json
{
  "mcpServers": {
    "typescript-server": {
      "command": "node",
      "args": ["/path/to/typescript-server/dist/index.js"]
    },
    "python-server": {
      "command": "python",
      "args": ["/path/to/python-server/server.py"]
    }
  }
}
```

---

## Key Differences: TypeScript vs Python

### TypeScript Advantages:
- Strong typing and compile-time error checking
- Rich ecosystem and tooling
- Better IDE support
- More mature MCP SDK

### Python Advantages:
- Simpler syntax and faster development
- Great for data processing and AI/ML integration
- Extensive scientific computing libraries
- Easier deployment in some environments

Both implementations provide the same MCP functionality and can be used interchangeably based on your project requirements and preferences.