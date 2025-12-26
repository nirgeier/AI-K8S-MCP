#!/bin/bash

# =============================================================================
# Lab 001 - MCP Basics Demo Script
# =============================================================================

set -e

# Get the root folder
ROOT_FOLDER=$(git rev-parse --show-toplevel)/

# Load common utilities
source "$ROOT_FOLDER/_utils/common.sh"

# =============================================================================
# Main Demo
# =============================================================================

print_header "Lab 001 - MCP Basics"

# Ensure labs environment is running
print_step "Checking labs environment..."
cd "$ROOT_FOLDER/labs-environment"

if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_success "Labs environment is running"

# Step 1: View MCP server code
print_step "Step 1: Examining MCP Server Code..."
print_info "Displaying MCP server implementation:"
echo ""
docker exec kagent-controller bash -c "head -50 /app/src/index.ts"
echo ""

# Step 2: Check if server is built
print_step "Step 2: Verifying MCP Server Build..."
if docker exec kagent-controller test -f /app/build/index.js; then
    print_success "MCP server is built"
else
    print_info "Building MCP server..."
    docker exec kagent-controller bash -c "cd /app && npm install && npm run build"
    print_success "MCP server built successfully"
fi

# Step 3: Create test scripts
print_step "Step 3: Creating Test Scripts..."

# Create simple tool test
docker exec kagent-controller bash -c 'cat > /labs-scripts/test-tools.js << '\''EOF'\''
console.log("=================================================");
console.log("K-Agent MCP Server - Tool Definitions");
console.log("=================================================");
console.log("");

const tools = [
  {
    name: "hello",
    description: "Returns a greeting message",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "Name to greet" }
      },
      required: ["name"]
    }
  },
  {
    name: "add",
    description: "Adds two numbers together",
    inputSchema: {
      type: "object",
      properties: {
        a: { type: "number", description: "First number" },
        b: { type: "number", description: "Second number" }
      },
      required: ["a", "b"]
    }
  }
];

tools.forEach(tool => {
  console.log(`Tool: ${tool.name}`);
  console.log(`Description: ${tool.description}`);
  console.log(`Input Schema:`, JSON.stringify(tool.inputSchema, null, 2));
  console.log("");
});

console.log("=================================================");
console.log("Testing Tools:");
console.log("=================================================");
console.log("");
console.log("Test 1: hello({ name: \"K-Agent User\" })");
console.log("Expected: Hello, K-Agent User! Welcome to K-Agent Labs.");
console.log("");
console.log("Test 2: add({ a: 5, b: 3 })");
console.log("Expected: The sum of 5 and 3 is 8");
console.log("");
console.log("=================================================");
EOF'

print_success "Test scripts created"

# Step 4: Run tests
print_step "Step 4: Running MCP Tool Tests..."
docker exec kagent-controller node /labs-scripts/test-tools.js

# Step 5: Demonstrate JSON-RPC format
print_step "Step 5: JSON-RPC Request/Response Examples..."

docker exec kagent-controller bash -c 'cat > /labs-scripts/jsonrpc-example.js << '\''EOF'\''
console.log("");
console.log("=================================================");
console.log("MCP JSON-RPC Communication Format");
console.log("=================================================");
console.log("");

console.log("1. ListTools Request:");
console.log("---------------------");
const listRequest = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/list",
  params: {}
};
console.log(JSON.stringify(listRequest, null, 2));
console.log("");

console.log("2. Tool Call Request (hello):");
console.log("-----------------------------");
const callRequest = {
  jsonrpc: "2.0",
  id: 2,
  method: "tools/call",
  params: {
    name: "hello",
    arguments: {
      name: "Alice"
    }
  }
};
console.log(JSON.stringify(callRequest, null, 2));
console.log("");

console.log("3. Expected Response:");
console.log("--------------------");
const response = {
  jsonrpc: "2.0",
  id: 2,
  result: {
    content: [
      {
        type: "text",
        text: "Hello, Alice! Welcome to K-Agent Labs."
      }
    ]
  }
};
console.log(JSON.stringify(response, null, 2));
console.log("");
console.log("=================================================");
EOF

node /labs-scripts/jsonrpc-example.js'

# Summary
print_header "Lab 001 Complete!"
echo ""
print_success "✓ Examined MCP server architecture"
print_success "✓ Understood tool definitions"
print_success "✓ Learned JSON-RPC protocol format"
print_success "✓ Tested MCP concepts"
echo ""
print_info "Key Concepts:"
print_info "  • MCP standardizes AI-tool communication"
print_info "  • Tools have names, descriptions, and JSON schemas"
print_info "  • JSON-RPC 2.0 is used for requests/responses"
print_info "  • Transport can be stdio, HTTP, or WebSocket"
echo ""
print_info "Next: Lab 002 - Build a TypeScript MCP Server"
echo ""
