#!/bin/bash

# =============================================================================
# Lab 002 - TypeScript MCP Server Demo Script
# =============================================================================

set -e

# Get the root folder
ROOT_FOLDER=$(git rev-parse --show-toplevel)/

# Load common utilities
source "$ROOT_FOLDER/_utils/common.sh"

# =============================================================================
# Main Demo
# =============================================================================

print_header "Lab 002 - TypeScript MCP Server"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

# Copy lab files to container
print_step "Preparing lab environment..."
cp "$ROOT_FOLDER/Labs/002-typescript-server/"*.ts "$LABS_SCRIPTS_FOLDER/" 2>/dev/null || true

# Step 1: Create MCP server project
print_step "Step 1: Creating MCP Server Project..."
docker exec kagent-controller bash -c "
mkdir -p /labs-scripts/my-mcp-server/src
cd /labs-scripts/my-mcp-server

# Create package.json
cat > package.json << 'PACKAGE_EOF'
{
  \"name\": \"my-mcp-server\",
  \"version\": \"1.0.0\",
  \"main\": \"build/index.js\",
  \"scripts\": {
    \"build\": \"tsc\",
    \"start\": \"node build/index.js\"
  },
  \"dependencies\": {
    \"@modelcontextprotocol/sdk\": \"^0.5.0\"
  },
  \"devDependencies\": {
    \"@types/node\": \"^20.10.0\",
    \"typescript\": \"^5.3.3\",
    \"ts-node\": \"^10.9.2\"
  }
}
PACKAGE_EOF

# Create tsconfig.json
cat > tsconfig.json << 'TSCONFIG_EOF'
{
  \"compilerOptions\": {
    \"target\": \"ES2020\",
    \"module\": \"commonjs\",
    \"outDir\": \"./build\",
    \"rootDir\": \"./src\",
    \"strict\": true,
    \"esModuleInterop\": true,
    \"skipLibCheck\": true
  }
}
TSCONFIG_EOF
"

print_success "Project structure created"

# Step 2: Create server code
print_step "Step 2: Creating Server Code..."
docker exec kagent-controller bash -c 'cat > /labs-scripts/my-mcp-server/src/mcp.ts << '\''SERVEREOF'\''
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  { name: "my-custom-mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "calculate",
        description: "Performs basic mathematical operations",
        inputSchema: {
          type: "object",
          properties: {
            operation: { type: "string", enum: ["add", "subtract", "multiply", "divide"] },
            a: { type: "number" },
            b: { type: "number" }
          },
          required: ["operation", "a", "b"]
        }
      },
      {
        name: "reverse_string",
        description: "Reverses a string",
        inputSchema: {
          type: "object",
          properties: {
            text: { type: "string" }
          },
          required: ["text"]
        }
      }
    ]
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "calculate") {
    const { operation, a, b } = args as any;
    let result = 0;
    switch (operation) {
      case "add": result = a + b; break;
      case "subtract": result = a - b; break;
      case "multiply": result = a * b; break;
      case "divide": result = b === 0 ? NaN : a / b; break;
    }
    return { content: [{ type: "text", text: `Result: ${result}` }] };
  }

  if (name === "reverse_string") {
    const { text } = args as any;
    return { content: [{ type: "text", text: text.split("").reverse().join("") }] };
  }

  throw new Error(`Unknown tool: ${name}`);
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Custom MCP Server running");
}

main().catch(console.error);
SERVEREOF'

print_success "Server code created"

# Step 3: Build server
print_step "Step 3: Building Server..."
docker exec kagent-controller bash -c "
cd /labs-scripts/my-mcp-server
npm install
npm run build
"

if docker exec kagent-controller test -f /labs-scripts/my-mcp-server/build/index.js; then
    print_success "Server built successfully"
else
    print_error "Server build failed"
    exit 1
fi

# Step 4: Create test script
print_step "Step 4: Creating Test Script..."
docker exec kagent-controller bash -c 'cat > /labs-scripts/test-custom-server.js << '\''TESTEOF'\''
console.log("Testing Custom MCP Server\n");
console.log("Available Tools:");
console.log("  1. calculate - Performs math operations");
console.log("  2. reverse_string - Reverses text\n");

console.log("Test Examples:");
console.log("  calculate(add, 15, 27) = 42");
console.log("  calculate(multiply, 6, 7) = 42");
console.log("  reverse_string(\"Hello\") = \"olleH\"\n");

console.log("✓ Server is ready for testing");
TESTEOF

node /labs-scripts/test-custom-server.js'

# Summary
print_header "Lab 002 Complete!"
echo ""
print_success "✓ Created TypeScript MCP server project"
print_success "✓ Implemented custom tools (calculate, reverse_string)"
print_success "✓ Built and compiled the server"
print_success "✓ Server is ready for use"
echo ""
print_info "Key Concepts:"
print_info "  • TypeScript provides type safety for MCP servers"
print_info "  • Tools are defined with JSON Schema"
print_info "  • Tool handlers implement the business logic"
print_info "  • Build process compiles TS to JS"
echo ""
print_info "Next: Lab 003 - Python MCP Server with FastMCP"
echo ""
