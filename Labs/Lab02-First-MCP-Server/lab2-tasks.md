# MCP Lab Tasks - Lab 2


Welcome to the MCP Lab Tasks section! 

This comprehensive collection of hands-on exercises will help you master the Model Context Protocol through practical implementation.

Each lab has 15 exercises designed to build your skills progressively. Try to solve each exercise on your own before clicking the solution dropdown.


---


### Exercise 2.1: Basic Server Structure

Create the basic file structure for a new MCP server project.

??? "Solution"
    ```
    my-mcp-server/
    ├── package.json
    ├── tsconfig.json
    ├── src/
    │   └── index.ts
    └── README.md
    ```

### Exercise 2.2: Package.json Dependencies

What are the essential dependencies for an MCP server?

??? "Solution"
    ```json
    {
      "dependencies": {
        "@modelcontextprotocol/sdk": "^0.5.0"
      },
      "devDependencies": {
        "@types/node": "^20.0.0",
        "typescript": "^5.0.0"
      }
    }
    ```

### Exercise 2.3: Server Initialization

Write the basic server initialization code.

??? "Solution"
    ```typescript
    import { Server } from "@modelcontextprotocol/sdk/server/index.js";
    import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

    const server = new Server(
      {
        name: "my-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    const transport = new StdioServerTransport();
    await server.connect(transport);
    ```

### Exercise 2.4: Tool Registration

How do you register a tool with the MCP server?

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/list", async () => {
      return {
        tools: [
          {
            name: "example_tool",
            description: "An example tool",
            inputSchema: {
              type: "object",
              properties: {
                message: { type: "string" }
              }
            }
          }
        ]
      };
    });
    ```

### Exercise 2.5: Tool Implementation

Implement a simple tool that echoes back the input message.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "echo") {
        return {
          content: [
            {
              type: "text",
              text: `Echo: ${args.message}`
            }
          ]
        };
      }

      throw new Error(`Unknown tool: ${name}`);
    });
    ```

### Exercise 2.6: Error Handling

Add proper error handling to the tool implementation.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      try {
        const { name, arguments: args } = request.params;

        if (name === "echo") {
          if (!args || !args.message) {
            throw new Error("Message parameter is required");
          }

          return {
            content: [
              {
                type: "text",
                text: `Echo: ${args.message}`
              }
            ]
          };
        }

        throw new Error(`Unknown tool: ${name}`);
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error: ${error.message}`
            }
          ],
          isError: true
        };
      }
    });
    ```

### Exercise 2.7: Server Logging

Add logging to track server operations.

??? "Solution"
    ```typescript
    import { Server } from "@modelcontextprotocol/sdk/server/index.js";

    const server = new Server(
      {
        name: "my-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    server.setRequestHandler("tools/list", async () => {
      console.log("Listing available tools");
      return { tools: [] };
    });
    ```

### Exercise 2.8: TypeScript Configuration

Create a proper tsconfig.json for an MCP server.

??? "Solution"
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

### Exercise 2.9: Build Script

Add build and start scripts to package.json.

??? "Solution"
    ```json
    {
      "scripts": {
        "build": "tsc",
        "start": "node dist/index.js",
        "dev": "tsx src/index.ts"
      }
    }
    ```

### Exercise 2.10: Input Validation

Implement input validation for tool parameters.

??? "Solution"
    ```typescript
    function validateEchoInput(args: any): { message: string } {
      if (!args || typeof args.message !== 'string') {
        throw new Error("message parameter must be a string");
      }
      if (args.message.length > 1000) {
        throw new Error("message too long (max 1000 characters)");
      }
      return args;
    }
    ```

### Exercise 2.11: Server Capabilities

Configure server capabilities in the initialization.

??? "Solution"
    ```typescript
    const server = new Server(
      {
        name: "my-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
          prompts: {}
        },
      }
    );
    ```

### Exercise 2.12: Graceful Shutdown

Implement graceful shutdown handling.

??? "Solution"
    ```typescript
    process.on('SIGINT', async () => {
      console.log('Shutting down MCP server...');
      await server.close();
      process.exit(0);
    });
    ```

### Exercise 2.13: Environment Variables

Use environment variables for server configuration.

??? "Solution"
    ```typescript
    const PORT = process.env.PORT || 3000;
    const API_KEY = process.env.API_KEY;

    if (!API_KEY) {
      throw new Error("API_KEY environment variable is required");
    }
    ```

### Exercise 2.14: Testing Setup

Create a basic test structure for the MCP server.

??? "Solution"
    ```typescript
    // test/server.test.ts
    import { Server } from "@modelcontextprotocol/sdk/server/index.js";

    describe("MCP Server", () => {
      let server: Server;

      beforeEach(() => {
        server = new Server(
          { name: "test-server", version: "1.0.0" },
          { capabilities: { tools: {} } }
        );
      });

      it("should initialize correctly", () => {
        expect(server).toBeDefined();
      });
    });
    ```

### Exercise 2.15: Documentation

Create a README.md for the MCP server project.

??? "Solution"
    ```markdown
    # My MCP Server

    A Model Context Protocol server that provides useful tools.

    ## Installation

    ```bash
    npm install
    npm run build
    ```

    Usage

    ```bash
    npm start
    ```

    Configuration

    Set the following environment variables:
    - `API_KEY`: Your API key
    - `PORT`: Server port (optional, defaults to 3000)
    ```