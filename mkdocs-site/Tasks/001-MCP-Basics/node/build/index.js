#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
/**
 * K-Agent MCP Server
 * A simple Model Context Protocol server with example tools
 */
// Create server instance
const server = new index_js_1.Server({
    name: "kagent-mcp-server",
    version: "1.0.0",
}, {
    capabilities: {
        tools: {},
    },
});
// List available tools
server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => {
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
server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    switch (name) {
        case "hello": {
            const nameArg = args?.name;
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
            const a = args?.a;
            const b = args?.b;
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
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
    console.error("K-Agent MCP Server running on stdio");
}
main().catch((error) => {
    console.error("Server error:", error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map