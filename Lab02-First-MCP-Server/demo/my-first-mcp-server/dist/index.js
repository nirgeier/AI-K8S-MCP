#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema, } from "@modelcontextprotocol/sdk/types.js";
/**
* Create an MCP server with core capabilities
*/
class MyFirstMCPServer {
    server;
    constructor() {
        this.server = new Server({
            name: "my-first-mcp-server",
            version: "1.0.0",
        }, {
            capabilities: {
                tools: {},
            },
        });
        this.setupHandlers();
        this.setupErrorHandling();
    }
    /**
    * Set up request handlers
    */
    setupHandlers() {
        // Handler for listing available tools
        this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
            tools: [
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
        }));
        // Handler for calling tools
        this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
            const { name, arguments: args } = request.params;
            if (name === "hello_world") {
                const userName = args?.name;
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
        });
    }
    /**
    * Set up error handling
    */
    setupErrorHandling() {
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
    async start() {
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
