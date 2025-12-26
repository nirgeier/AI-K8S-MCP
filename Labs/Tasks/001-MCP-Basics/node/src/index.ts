#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
 * K-Agent MCP Server
 * A simple Model Context Protocol server with example tools
 */

// Create server instance
const server = new Server(
  {
    name: "kagent-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "hello",
        description: "Returns a friendly greeting message",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Name to greet",
            },
          },
          required: ["name"],
        },
      },
      {
        name: "add",
        description: "Adds two numbers together",
        inputSchema: {
          type: "object",
          properties: {
            a: {
              type: "number",
              description: "First number",
            },
            b: {
              type: "number",
              description: "Second number",
            },
          },
          required: ["a", "b"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "hello": {
      const nameArg = args?.name as string;
      return {
        content: [
          {
            type: "text",
            text: `Hello, ${nameArg}! Welcome to K-Agent Labs.`,
          },
        ],
      };
    }

    case "add": {
      const a = args?.a as number;
      const b = args?.b as number;
      const result = a + b;
      return {
        content: [
          {
            type: "text",
            text: `The sum of ${a} and ${b} is ${result}`,
          },
        ],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("K-Agent MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
