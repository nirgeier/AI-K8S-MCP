#!/usr/bin/env node

import * as fs from 'fs/promises';
import * as path from 'path';
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
* Create an MCP server with core capabilities
*/
class MyFirstMCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "my-first-mcp-server",
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
          {
            name: "query_database",
            description: "Execute SELECT queries on a SQLite database",
            inputSchema: {
              type: "object",
              properties: {
                query: {
                  type: "string",
                  description: "SQL SELECT query to execute"
                },
                parameters: {
                  type: "array",
                  description: "Query parameters for prepared statement",
                  items: {
                    type: ["string", "number", "boolean", "null"]
                  },
                  default: []
                },
                limit: {
                  type: "number",
                  description: "Maximum number of rows to return",
                  minimum: 1,
                  maximum: 1000,
                  default: 100
                }
              },
              required: ["query"]
            }
          }
          , {
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
          }, {
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

        if (name === "query_database") {
          try {
            const query = args.query as string;
            const parameters = (args.parameters as any[]) || [];
            const limit = (args.limit as number) || 100;

            // Security: Validate input
            if (!query || typeof query !== 'string' || query.trim().length === 0) {
              throw new Error("query must be a non-empty string");
            }

            // Security: Only allow SELECT queries
            const trimmedQuery = query.trim().toUpperCase();
            if (!trimmedQuery.startsWith('SELECT')) {
              throw new Error("Only SELECT queries are allowed for security");
            }

            // Check if database file exists
            const dbPath = './data.db';
            try {
              await fs.access(dbPath, fs.constants.R_OK);
            } catch {
              throw new Error("Database file 'data.db' not found in project root");
            }

            // Open database in read-only mode
            const db = new Database(dbPath, { readonly: true });

            try {
              // Prepare statement
              const stmt = db.prepare(query + ' LIMIT ?');

              // Execute query
              const rows = stmt.all(...parameters, limit);

              // Format results
              const resultText = rows.length > 0
                ? JSON.stringify(rows, null, 2)
                : "No results found";

              // Get query info
              const info = stmt.columns();
              const columnNames = info.map(col => col.name);

              return {
                content: [
                  {
                    type: "text",
                    text: `Query executed successfully.\nDatabase: ${dbPath}\nColumns: ${columnNames.join(', ')}\nRows returned: ${rows.length}\n\nResults:\n${resultText}`
                  }
                ]
              };

            } finally {
              db.close();
            }

          } catch (error) {
            throw new Error(
              `Database query failed: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }

        if (name === "read_file") {
          try {
            const filepath = args.filepath as string;
            const encoding = (args.encoding as BufferEncoding) || "utf8";
            const maxSize = (args.maxSize as number) || 1048576;

            // Security: Validate input
            if (!filepath || typeof filepath !== 'string' || filepath.trim().length === 0) {
              throw new Error("filepath must be a non-empty string");
            }

            // Security: Resolve and validate path
            const resolvedPath = path.resolve(filepath);

            // Prevent directory traversal attacks
            if (!resolvedPath.startsWith(process.cwd())) {
              throw new Error("Access denied: file path outside allowed directory");
            }

            // Check if file exists and is readable
            try {
              await fs.access(resolvedPath, fs.constants.R_OK);
            } catch {
              throw new Error(`File not found or not readable: ${filepath}`);
            }

            // Get file stats
            const stats = await fs.stat(resolvedPath);

            // Check if it's actually a file (not a directory)
            if (!stats.isFile()) {
              throw new Error(`Path is not a file: ${filepath}`);
            }

            // Check file size
            if (stats.size > maxSize) {
              throw new Error(
                `File too large: ${stats.size} bytes (max: ${maxSize})`
              );
            }

            // Read file content
            const content = await fs.readFile(resolvedPath, encoding);

            // Format response with metadata
            const fileInfo = {
              path: resolvedPath,
              size: stats.size,
              modified: stats.mtime.toISOString(),
              encoding: encoding
            };

            return {
              content: [
                {
                  type: "text",
                  text: `File Information:\n${JSON.stringify(fileInfo, null, 2)}\n\nContent:\n${content}`
                }
              ]
            };

          } catch (error) {
            throw new Error(
              `Failed to read file: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }
        if (name === "get_weather") {
          try {
            // Extract and validate parameters
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

            Use realistic weather data appropriate for the location. Temperature should be in Celsius. 
            Choose an appropriate 2-letter country code for the city. 
            Make the weather description realistic for the location and season.`;

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
                "London": {
                  name: "London",
                  sys: { country: "GB" },
                  main: { temp: 15.2, feels_like: 14.8, humidity: 82 },
                  weather: [{ description: "light rain" }],
                  wind: { speed: 3.6 }
                },
                "New York": {
                  name: "New York",
                  sys: { country: "US" },
                  main: { temp: 22.5, feels_like: 24.1, humidity: 65 },
                  weather: [{ description: "clear sky" }],
                  wind: { speed: 2.1 }
                },
                "Tokyo": {
                  name: "Tokyo",
                  sys: { country: "JP" },
                  main: { temp: 18.7, feels_like: 18.2, humidity: 78 },
                  weather: [{ description: "few clouds" }],
                  wind: { speed: 1.8 }
                },
                "Paris": {
                  name: "Paris",
                  sys: { country: "FR" },
                  main: { temp: 12.8, feels_like: 11.9, humidity: 71 },
                  weather: [{ description: "overcast clouds" }],
                  wind: { speed: 4.2 }
                },
                "Sydney": {
                  name: "Sydney",
                  sys: { country: "AU" },
                  main: { temp: 24.3, feels_like: 25.1, humidity: 73 },
                  weather: [{ description: "sunny" }],
                  wind: { speed: 2.8 }
                }
              };
              data = fallbackData[city.toLowerCase().trim()] || fallbackData["London"];
            }

            // Format response
            const tempUnit = units === "fahrenheit" ? "°F" : "°C";
            const weatherText = `
Weather in ${data.name}, ${data.sys.country}:
- Temperature: ${data.main.temp}${tempUnit}
- Feels like: ${data.main.feels_like}${tempUnit}
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

        if (name === "hello_world") {
          const userName = args?.name as string;

          if (!userName) {
            throw new Error("Name parameter is required");
          }

          return {
            content: [
              {
                type: "text",
                text: `Hello, ${userName}! Welcome to your first MCP server! 🎉`,
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

    console.error("My First MCP Server running on stdio");
  }
}

/**
* Main entry point
*/
async function main() {
  const server = new MyFirstMCPServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});