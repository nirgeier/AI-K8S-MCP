<a href="https://github.com/CodeWizard-IL/Kagent/actions/workflows/003-typescript-server.yaml" target="_blank">
  <img src="https://github.com/CodeWizard-IL/Kagent/actions/workflows/003-typescript-server.yaml/badge.svg" alt="Lab 003-typescript-server">
</a>

---

# Lab 003 - TypeScript MCP Server

In this lab, you'll build your own Model Context Protocol server using TypeScript. You'll create custom tools, define input schemas, and implement tool handlers from scratch.

**What you'll learn:**
- Create a TypeScript MCP server project
- Define custom tools with JSON Schema
- Implement tool handlers
- Test your MCP server

**Estimated time:** 15 minutes

---

## Pre-Requirements

- Completed [Lab 001 - MCP Basics](../001-mcp-basics/)
- Understanding of TypeScript basics
- K-Agent labs environment running

---

## 01. Project Structure

A TypeScript MCP server project typically has this structure:

```
my-mcp-server/
├── package.json          # Project dependencies
├── tsconfig.json         # TypeScript configuration
├── src/
│   └── index.ts         # Main server code
└── build/               # Compiled JavaScript (generated)
```

---

## 02. Initialize Project

Let's create a new MCP server from scratch.

```bash
# Connect to container
docker exec -it kagent-controller bash

# Create project directory
mkdir -p /labs-scripts/my-mcp-server
cd /labs-scripts/my-mcp-server

# Initialize npm project
npm init -y

# Install dependencies
npm install @modelcontextprotocol/sdk

# Install dev dependencies
npm install --save-dev typescript @types/node ts-node
```

---

## 03. Configure TypeScript

Create `tsconfig.json`:

```bash
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./build",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "build"]
}
EOF
```

---

## 04. Create MCP Server

Create `src/index.ts` with custom tools:

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// Create server instance
const server = new Server(
  {
    name: "my-custom-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "calculate",
        description: "Performs basic mathematical operations",
        inputSchema: {
          type: "object",
          properties: {
            operation: {
              type: "string",
              enum: ["add", "subtract", "multiply", "divide"],
              description: "Mathematical operation to perform",
            },
            a: {
              type: "number",
              description: "First number",
            },
            b: {
              type: "number",
              description: "Second number",
            },
          },
          required: ["operation", "a", "b"],
        },
      },
      {
        name: "reverse_string",
        description: "Reverses a string",
        inputSchema: {
          type: "object",
          properties: {
            text: {
              type: "string",
              description: "Text to reverse",
            },
          },
          required: ["text"],
        },
      },
      {
        name: "get_timestamp",
        description: "Returns current timestamp in ISO format",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "calculate": {
      const { operation, a, b } = args as {
        operation: string;
        a: number;
        b: number;
      };

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
          if (b === 0) {
            throw new Error("Division by zero");
          }
          result = a / b;
          break;
        default:
          throw new Error(`Unknown operation: ${operation}`);
      }

      return {
        content: [
          {
            type: "text",
            text: `Result: ${a} ${operation} ${b} = ${result}`,
          },
        ],
      };
    }

    case "reverse_string": {
      const { text } = args as { text: string };
      const reversed = text.split("").reverse().join("");
      return {
        content: [
          {
            type: "text",
            text: `Original: "${text}"\nReversed: "${reversed}"`,
          },
        ],
      };
    }

    case "get_timestamp": {
      const timestamp = new Date().toISOString();
      return {
        content: [
          {
            type: "text",
            text: `Current timestamp: ${timestamp}`,
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
  console.error("Custom MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
```

---

## 05. Update package.json

Add build and start scripts:

```bash
cat > package.json << 'EOF'
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "description": "Custom MCP Server",
  "main": "build/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node build/index.js",
    "dev": "ts-node src/index.ts"
  },
  "keywords": ["mcp", "model-context-protocol"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "ts-node": "^10.9.2",
    "typescript": "^5.3.3"
  }
}
EOF
```

---

## 06. Build the Server

```bash
# Install dependencies
npm install

# Compile TypeScript
npm run build

# Verify build
ls -la build/
```

You should see `index.js` in the `build/` directory.

---

## 07. Test the Server

Create a test script:

```bash
cat > test-server.js << 'EOF'
const { spawn } = require('child_process');

console.log("Testing Custom MCP Server\n");

// Start the server
const server = spawn('node', ['build/index.js']);

server.stderr.on('data', (data) => {
  console.log('[Server]', data.toString().trim());
});

// Test 1: List tools
console.log("Test 1: Listing tools...\n");
const listRequest = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/list"
};

server.stdin.write(JSON.stringify(listRequest) + '\n');

// Test 2: Calculate (add)
setTimeout(() => {
  console.log("\nTest 2: Calculate 15 + 27...\n");
  const calculateRequest = {
    jsonrpc: "2.0",
    id: 2,
    method: "tools/call",
    params: {
      name: "calculate",
      arguments: {
        operation: "add",
        a: 15,
        b: 27
      }
    }
  };
  server.stdin.write(JSON.stringify(calculateRequest) + '\n');
}, 500);

// Test 3: Reverse string
setTimeout(() => {
  console.log("\nTest 3: Reverse string 'Hello K-Agent'...\n");
  const reverseRequest = {
    jsonrpc: "2.0",
    id: 3,
    method: "tools/call",
    params: {
      name: "reverse_string",
      arguments: {
        text: "Hello K-Agent"
      }
    }
  };
  server.stdin.write(JSON.stringify(reverseRequest) + '\n');
}, 1000);

// Test 4: Get timestamp
setTimeout(() => {
  console.log("\nTest 4: Get current timestamp...\n");
  const timestampRequest = {
    jsonrpc: "2.0",
    id: 4,
    method: "tools/call",
    params: {
      name: "get_timestamp",
      arguments: {}
    }
  };
  server.stdin.write(JSON.stringify(timestampRequest) + '\n');
}, 1500);

// Capture responses
server.stdout.on('data', (data) => {
  console.log('[Response]', data.toString());
});

// Cleanup
setTimeout(() => {
  server.kill();
  console.log("\n✓ All tests completed!");
  process.exit(0);
}, 3000);
EOF

# Run tests
node test-server.js
```

---

## 08. Hands-on Exercise

### Exercise 1: Add a New Tool

Add a `to_uppercase` tool that converts text to uppercase.

**Steps:**

1. Add tool definition in `ListToolsRequestSchema` handler:

```typescript
{
  name: "to_uppercase",
  description: "Converts text to uppercase",
  inputSchema: {
    type: "object",
    properties: {
      text: {
        type: "string",
        description: "Text to convert"
      }
    },
    required: ["text"]
  }
}
```

2. Add tool handler in `CallToolRequestSchema`:

```typescript
case "to_uppercase": {
  const { text } = args as { text: string };
  const upper = text.toUpperCase();
  return {
    content: [
      {
        type: "text",
        text: `Uppercase: ${upper}`
      }
    ]
  };
}
```

3. Rebuild and test:

```bash
npm run build
# Test with your test script
```

### Exercise 2: Add Input Validation

Enhance the `calculate` tool to validate inputs:

```typescript
case "calculate": {
  const { operation, a, b } = args as {
    operation: string;
    a: number;
    b: number;
  };

  // Validate inputs
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new Error("Invalid input: a and b must be numbers");
  }

  if (!['add', 'subtract', 'multiply', 'divide'].includes(operation)) {
    throw new Error(`Invalid operation: ${operation}`);
  }

  // ... rest of the code
}
```

### Exercise 3: Add Error Handling

Create a test that triggers an error (division by zero):

```bash
cat > test-error.js << 'EOF'
const { spawn } = require('child_process');

const server = spawn('node', ['build/index.js']);

// Test division by zero
const request = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/call",
  params: {
    name: "calculate",
    arguments: {
      operation: "divide",
      a: 10,
      b: 0
    }
  }
};

server.stdin.write(JSON.stringify(request) + '\n');

server.stdout.on('data', (data) => {
  console.log('Response:', data.toString());
});

setTimeout(() => {
  server.kill();
  process.exit(0);
}, 1000);
EOF

node test-error.js
```

**Expected:** Error message about division by zero.

---

## 09. Key Takeaways

!!! success "What You Learned"
    - ✓ Created a TypeScript MCP server from scratch
    - ✓ Defined custom tools with JSON Schema validation
    - ✓ Implemented tool handlers with logic
    - ✓ Built and tested the server
    - ✓ Added error handling and validation

!!! tip "Best Practices"
    - Always validate tool inputs
    - Provide clear error messages
    - Use TypeScript for type safety
    - Test each tool thoroughly
    - Document tool descriptions clearly

---

## 10. Next Steps

Now that you can build TypeScript MCP servers, you'll learn about deploying MCP servers to Kubernetes.

**What's next:**
- [Lab 004 - K8s Deploy](../004-k8s-deploy/) - Deploy MCP servers to Kubernetes
- Containerizing MCP applications
- Kubernetes service discovery

---

<!-- Navigation Links -->
[Previous: Lab 002 - Python MCP Server](../002-python-server/) | [Next: Lab 004 - K8s Deploy](../004-k8s-deploy/)
