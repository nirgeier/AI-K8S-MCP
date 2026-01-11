#!/bin/bash

# Script to execute Lab 2: Building Your First MCP Server
# Creates a demo folder, sets up the project, and tests with MCP Inspector

set -e # Exit on any error

echo "🚀 Starting Lab 2: Building Your First MCP Server"
echo "=================================================="

# Create demo folder
echo "📁 Creating demo folder..."
rm -rf demo
mkdir -p demo
cd demo

# Step 1: Initialize Project
echo "📦 Initializing Node.js project..."
mkdir -p my-first-mcp-server
cd my-first-mcp-server
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
  "name": "my-first-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "description": "My first MCP server",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/index.ts",
    "start": "node dist/index.js"
  },
  "keywords": ["mcp", "server"],
  "author": "Your Name"
}
EOF

# Step 5: Create Server Structure
echo "🏗️  Creating server structure..."
mkdir src
cat >src/index.ts <<'EOF'
#!/usr/bin/env node

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
EOF

# Build the project
echo "🔨 Building the project..."
npm run build

# Install MCP Inspector
echo "🔍 Installing MCP Inspector..."
npm install -g @modelcontextprotocol/inspector

# Test with MCP Inspector
echo "🧪 Testing with MCP Inspector..."
echo "Note: This will open a browser window with the MCP Inspector interface."
echo "You can test the hello_world tool there."
echo ""
echo "To stop the server, press Ctrl+C in this terminal."
echo ""

npx @modelcontextprotocol/inspector --transport stdio tsx src/index.ts
