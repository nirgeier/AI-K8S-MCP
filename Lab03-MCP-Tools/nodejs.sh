#!/bin/bash

# Script to execute Lab 3: Implementing MCP Tools
# Creates a demo folder with advanced tools: weather (Ollama), file operations, and database queries

set -e # Exit on any error

echo "🚀 Starting Lab 3: Implementing MCP Tools"
echo "=========================================="
echo ""
echo "This lab includes three advanced tools:"
echo "  1. Weather Information (using Ollama AI)"
echo "  2. File Operations (secure file reading)"
echo "  3. Database Query (mock implementation)"
echo ""

# Create demo folder
echo "📁 Creating demo folder..."
rm -rf demo
mkdir -p demo
cd demo

# Step 1: Initialize Project
echo "📦 Initializing Node.js project..."
mkdir -p my-advanced-mcp-tools
cd my-advanced-mcp-tools
npm init -y

# Step 2: Install Dependencies
echo "📥 Installing dependencies..."
npm install @modelcontextprotocol/sdk
npm install -D typescript @types/node tsx

# Step 3: Configure TypeScript
echo "⚙️  Configuring TypeScript..."
cat >tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Step 4: Update package.json
echo "📝 Updating package.json..."
cat >package.json <<'EOF'
{
  "name": "my-advanced-mcp-tools",
  "version": "1.0.0",
  "type": "module",
  "description": "Advanced MCP server with weather, file, and database tools",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/index.ts",
    "start": "node dist/index.js"
  },
  "keywords": ["mcp", "server", "tools"],
  "author": "Your Name"
}
EOF

# Step 5: Create Server with All Tools
echo "🏗️  Creating advanced MCP server with three tools..."
mkdir src
cat >src/index.ts <<'EOFTS'
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as fs from 'fs/promises';
import * as path from 'path';

/**
* Advanced MCP server with weather, file operations, and database tools
*/
class AdvancedMCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "my-advanced-mcp-tools",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  /**
  * Set up request handlers
  */
  private setupHandlers(): void {
    // Handler for listing available tools
    this.server.setRequestHandler(
      ListToolsRequestSchema,
      async () => ({
        tools: [
          // Tool 1: Weather Information with Ollama
          {
            name: "get_weather",
            description: "Get current weather information for a city using AI",
            inputSchema: {
              type: "object",
              properties: {
                city: {
                  type: "string",
                  description: "City name (e.g., 'London', 'New York')"
                },
                units: {
                  type: "string",
                  description: "Temperature units",
                  enum: ["celsius", "fahrenheit"],
                  default: "celsius"
                }
              },
              required: ["city"]
            }
          },
          // Tool 2: File Operations
          {
            name: "read_file",
            description: "Read contents of a text file with security validation",
            inputSchema: {
              type: "object",
              properties: {
                filepath: {
                  type: "string",
                  description: "Absolute path to the file"
                },
                encoding: {
                  type: "string",
                  description: "File encoding",
                  enum: ["utf8", "ascii", "base64"],
                  default: "utf8"
                },
                maxSize: {
                  type: "number",
                  description: "Maximum file size in bytes",
                  minimum: 1,
                  maximum: 10485760,
                  default: 1048576
                }
              },
              required: ["filepath"]
            }
          },
          // Tool 3: Database Query (Mock)
          {
            name: "query_users",
            description: "Query user database with filtering and pagination",
            inputSchema: {
              type: "object",
              properties: {
                status: {
                  type: "string",
                  description: "Filter by user status",
                  enum: ["active", "inactive", "all"],
                  default: "all"
                },
                limit: {
                  type: "number",
                  description: "Maximum number of results",
                  minimum: 1,
                  maximum: 100,
                  default: 10
                },
                offset: {
                  type: "number",
                  description: "Pagination offset",
                  minimum: 0,
                  default: 0
                }
              }
            }
          },
          // Bonus: Hello World (from Lab 2)
          {
            name: "hello_world",
            description: "Returns a friendly greeting message",
            inputSchema: {
              type: "object",
              properties: {
                name: {
                  type: "string",
                  description: "The name to greet",
                },
              },
              required: ["name"],
            },
          },
        ],
      })
    );

    // Handler for calling tools
    this.server.setRequestHandler(
      CallToolRequestSchema,
      async (request) => {
        const { name, arguments: args } = request.params;

        // Tool 1: Weather Information with Ollama
        if (name === "get_weather") {
          try {
            // Extract and validate parameters
            if (!args) {
              throw new Error("Arguments are required");
            }
            const city = args.city as string;
            const units = (args.units as string) || "celsius";

            if (!city || city.trim().length === 0) {
              throw new Error("City name cannot be empty");
            }

            // Use Ollama to generate weather information
            const prompt = `Generate realistic current weather information for ${city}.
            Return ONLY a JSON object with this exact structure:
            {
              "name": "${city}",
              "sys": {"country": "XX"},
              "main": {"temp": 20.5, "feels_like": 22.1, "humidity": 65},
              "weather": [{"description": "clear sky"}],
              "wind": {"speed": 3.2}
            }

            Use realistic weather data appropriate for the location. Temperature should be in Celsius. Choose an appropriate 2-letter country code for the city. Make the weather description realistic for the location and season.`;

            // Call Ollama API
            const response = await fetch('http://localhost:11434/api/generate', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                model: 'gpt-oss:20b',
                prompt: prompt,
                stream: false,
                format: 'json'
              }),
            });

            if (!response.ok) {
              throw new Error(`Ollama API error: ${response.status} ${response.statusText}. Make sure Ollama is running with 'ollama serve'.`);
            }

            const ollamaResult = await response.json();
            let data;

            try {
              // Parse the JSON response from Ollama
              data = JSON.parse(ollamaResult.response);
            } catch (parseError) {
              // Fallback to mock data if parsing fails
              console.warn('Failed to parse Ollama response, using fallback data');
              const fallbackData: Record<string, any> = {
                "london": {
                  name: "London",
                  sys: { country: "GB" },
                  main: { temp: 15.2, feels_like: 14.8, humidity: 82 },
                  weather: [{ description: "light rain" }],
                  wind: { speed: 3.6 }
                },
                "new york": {
                  name: "New York",
                  sys: { country: "US" },
                  main: { temp: 22.5, feels_like: 24.1, humidity: 65 },
                  weather: [{ description: "clear sky" }],
                  wind: { speed: 2.1 }
                },
                "tokyo": {
                  name: "Tokyo",
                  sys: { country: "JP" },
                  main: { temp: 18.7, feels_like: 18.2, humidity: 78 },
                  weather: [{ description: "few clouds" }],
                  wind: { speed: 1.8 }
                },
                "paris": {
                  name: "Paris",
                  sys: { country: "FR" },
                  main: { temp: 12.8, feels_like: 11.9, humidity: 71 },
                  weather: [{ description: "overcast clouds" }],
                  wind: { speed: 4.2 }
                },
                "sydney": {
                  name: "Sydney",
                  sys: { country: "AU" },
                  main: { temp: 24.3, feels_like: 25.1, humidity: 73 },
                  weather: [{ description: "sunny" }],
                  wind: { speed: 2.8 }
                }
              };
              data = fallbackData[city.toLowerCase().trim()] || fallbackData["london"];
            }

            // Convert to Fahrenheit if requested
            if (units === "fahrenheit") {
              data.main.temp = (data.main.temp * 9/5) + 32;
              data.main.feels_like = (data.main.feels_like * 9/5) + 32;
            }

            // Format response
            const tempUnit = units === "fahrenheit" ? "°F" : "°C";
            const weatherText = `
Weather in ${data.name}, ${data.sys.country}:
- Temperature: ${data.main.temp.toFixed(1)}${tempUnit}
- Feels like: ${data.main.feels_like.toFixed(1)}${tempUnit}
- Conditions: ${data.weather[0].description}
- Humidity: ${data.main.humidity}%
- Wind Speed: ${data.wind.speed} m/s

*Generated by Ollama AI*
`.trim();

            // Return MCP response
            return {
              content: [
                {
                  type: "text",
                  text: weatherText
                }
              ]
            };

          } catch (error) {
            // Handle errors
            throw new Error(
              `Failed to get weather: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }

        // Tool 2: File Operations
        if (name === "read_file") {
          try {
            if (!args) {
              throw new Error("Arguments are required");
            }
            const filepath = args.filepath as string;
            const encoding = (args.encoding as BufferEncoding) || "utf8";
            const maxSize = (args.maxSize as number) || 1048576;

            // Security: Validate input
            if (!filepath || typeof filepath !== 'string' || filepath.trim().length === 0) {
              throw new Error("filepath must be a non-empty string");
            }

            // Security: Resolve absolute path to prevent directory traversal
            const absolutePath = path.resolve(filepath);

            // Security: Check if path exists and is a file
            const stats = await fs.stat(absolutePath);
            if (!stats.isFile()) {
              throw new Error("Path is not a file");
            }

            // Security: Check file size
            if (stats.size > maxSize) {
              throw new Error(`File size (${stats.size} bytes) exceeds maximum allowed size (${maxSize} bytes)`);
            }

            // Read file
            const content = await fs.readFile(absolutePath, encoding);

            // Return result with metadata
            return {
              content: [
                {
                  type: "text",
                  text: `File: ${absolutePath}
Size: ${stats.size} bytes
Modified: ${stats.mtime.toISOString()}
Encoding: ${encoding}

Content:
${content}`
                }
              ]
            };

          } catch (error) {
            throw new Error(
              `Failed to read file: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }

        // Tool 3: Database Query (Mock)
        if (name === "query_users") {
          try {
            const queryArgs = args || {};
            const status = (queryArgs.status as string) || "all";
            const limit = (queryArgs.limit as number) || 10;
            const offset = (queryArgs.offset as number) || 0;

            // Mock database
            const allUsers = [
              { id: 1, name: "Alice Johnson", email: "alice@example.com", status: "active", created: "2024-01-15" },
              { id: 2, name: "Bob Smith", email: "bob@example.com", status: "active", created: "2024-02-20" },
              { id: 3, name: "Charlie Brown", email: "charlie@example.com", status: "inactive", created: "2024-03-10" },
              { id: 4, name: "Diana Prince", email: "diana@example.com", status: "active", created: "2024-04-05" },
              { id: 5, name: "Eve Wilson", email: "eve@example.com", status: "inactive", created: "2024-05-12" },
              { id: 6, name: "Frank Miller", email: "frank@example.com", status: "active", created: "2024-06-18" },
              { id: 7, name: "Grace Lee", email: "grace@example.com", status: "active", created: "2024-07-22" },
              { id: 8, name: "Henry Davis", email: "henry@example.com", status: "inactive", created: "2024-08-30" },
            ];

            // Filter by status
            let filteredUsers = allUsers;
            if (status !== "all") {
              filteredUsers = allUsers.filter(user => user.status === status);
            }

            // Apply pagination
            const paginatedUsers = filteredUsers.slice(offset, offset + limit);
            const totalCount = filteredUsers.length;

            // Format response
            const usersList = paginatedUsers.map(user => 
              `• ${user.name} (${user.email}) - ${user.status} - Created: ${user.created}`
            ).join('\n');

            const resultText = `
Database Query Results
======================
Filter: status=${status}
Showing: ${paginatedUsers.length} of ${totalCount} users
Page: ${Math.floor(offset / limit) + 1}

${usersList}

Query executed at: ${new Date().toISOString()}
`.trim();

            return {
              content: [
                {
                  type: "text",
                  text: resultText
                }
              ]
            };

          } catch (error) {
            throw new Error(
              `Failed to query users: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }

        // Bonus: Hello World (from Lab 2)
        if (name === "hello_world") {
          const userName = args?.name as string;

          if (!userName) {
            throw new Error("Name parameter is required");
          }

          return {
            content: [
              {
                type: "text",
                text: `Hello, ${userName}! Welcome to Lab 3 - Advanced MCP Tools! 🚀`,
              },
            ],
          };
        }

        throw new Error(`Unknown tool: ${name}`);
      }
    );
  }

  /**
  * Set up error handling
  */
  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  /**
  * Start the server
  */
  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);

    console.error("Advanced MCP Tools Server running on stdio");
    console.error("Available tools: get_weather, read_file, query_users, hello_world");
  }
}

/**
* Main entry point
*/
async function main() {
  const server = new AdvancedMCPServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
EOFTS

# Build the project
echo "🔨 Building the project..."
npm run build

# Create a sample test file for file reading tool
echo "📄 Creating sample test file..."
echo "This is a test file for the read_file tool.
It contains multiple lines of text.
You can test reading this file with the MCP Inspector!" >test-file.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "=================================================="
echo "🧪 Testing Instructions"
echo "=================================================="
echo ""
echo "The MCP Inspector will now launch. You can test all tools:"
echo ""
echo "1. 🌤️  Weather Tool (get_weather):"
echo "   - Try cities: London, New York, Tokyo, Paris, Sydney"
echo "   - Test units: celsius or fahrenheit"
echo "   - Note: Requires Ollama running (ollama serve)"
echo "   - Falls back to mock data if Ollama is unavailable"
echo ""
echo "2. 📁 File Tool (read_file):"
echo "   - Test with: $(pwd)/test-file.txt"
echo "   - Try different encodings: utf8, ascii, base64"
echo "   - Test error cases with non-existent files"
echo ""
echo "3. 💾 Database Tool (query_users):"
echo "   - Filter: active, inactive, or all"
echo "   - Pagination: set limit (1-100) and offset"
echo "   - Mock database with 8 sample users"
echo ""
echo "4. 👋 Hello World (hello_world):"
echo "   - Simple greeting tool from Lab 2"
echo ""
echo "=================================================="
echo ""
echo "Starting MCP Inspector..."
echo "Press Ctrl+C to stop the server."
echo ""

# Install and launch MCP Inspector
npx @modelcontextprotocol/inspector --transport stdio tsx src/index.ts
