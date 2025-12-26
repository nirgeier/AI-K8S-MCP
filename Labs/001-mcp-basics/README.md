
# Lab 001 - MCP Basics

In this lab, you'll learn about the Model Context Protocol (MCP), the communication standard that enables AI assistants to interact with external tools and services. You'll explore MCP concepts, test simple tools, and understand the protocol structure.

**What you'll learn:**

- Understanding Model Context Protocol (MCP) architecture
- MCP server and client communication
- Tool definitions and JSON schemas
- Testing MCP tools with stdio transport

**Estimated time:** 10-12 minutes

---

## Pre-Requirements

- Completed [Lab 000 - Environment Setup](../000-setup/)
- K-Agent labs environment container running

---

## 01. What is MCP?

The **Model Context Protocol (MCP)** is an open protocol that standardizes how AI applications interact with external data sources and tools. It enables:

- **Standardized Communication**: AI assistants can work with any MCP-compatible tool
- **Tool Discovery**: Clients can discover available tools from servers
- **Structured Interaction**: Well-defined input/output schemas using JSON
- **Multiple Transports**: Supports stdio, HTTP, and WebSocket communication

### Architecture

<div style="text-align: center; margin: 2em 0;">
  <svg width="700" height="300" xmlns="http://www.w3.org/2000/svg">
    <!-- AI Assistant/Client -->
    <rect x="10" y="125" width="150" height="50" fill="#e1f5ff" stroke="#333" stroke-width="2" rx="5"/>
    <text x="85" y="155" text-anchor="middle" font-family="Arial" font-size="14">AI Assistant/Client</text>
    
    <!-- MCP Server -->
    <rect x="275" y="125" width="150" height="50" fill="#fff4e1" stroke="#333" stroke-width="2" rx="5"/>
    <text x="350" y="155" text-anchor="middle" font-family="Arial" font-size="14">MCP Server</text>
    
    <!-- External Services -->
    <rect x="540" y="20" width="150" height="40" fill="#f0f0f0" stroke="#333" stroke-width="2" rx="5"/>
    <text x="615" y="45" text-anchor="middle" font-family="Arial" font-size="13">External Services</text>
    
    <!-- Databases -->
    <rect x="540" y="75" width="150" height="40" fill="#f0f0f0" stroke="#333" stroke-width="2" rx="5"/>
    <text x="615" y="100" text-anchor="middle" font-family="Arial" font-size="13">Databases</text>
    
    <!-- APIs -->
    <rect x="540" y="130" width="150" height="40" fill="#f0f0f0" stroke="#333" stroke-width="2" rx="5"/>
    <text x="615" y="155" text-anchor="middle" font-family="Arial" font-size="13">APIs</text>
    
    <!-- Kubernetes -->
    <rect x="540" y="185" width="150" height="40" fill="#f0f0f0" stroke="#333" stroke-width="2" rx="5"/>
    <text x="615" y="210" text-anchor="middle" font-family="Arial" font-size="13">Kubernetes</text>
    
    <!-- Arrow from AI to MCP -->
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
        <polygon points="0 0, 10 3, 0 6" fill="#333" />
      </marker>
    </defs>
    <line x1="160" y1="150" x2="270" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
    <text x="215" y="145" text-anchor="middle" font-family="Arial" font-size="11">MCP Protocol</text>
    
    <!-- Arrows from MCP to services -->
    <line x1="425" y1="135" x2="535" y2="50" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
    <text x="480" y="80" text-anchor="middle" font-family="Arial" font-size="11">Tool Calls</text>
    
    <line x1="425" y1="140" x2="535" y2="95" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
    <text x="480" y="110" text-anchor="middle" font-family="Arial" font-size="11">Tool Calls</text>
    
    <line x1="425" y1="150" x2="535" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
    <text x="480" y="145" text-anchor="middle" font-family="Arial" font-size="11">Tool Calls</text>
    
    <line x1="425" y1="160" x2="535" y2="205" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
    <text x="480" y="190" text-anchor="middle" font-family="Arial" font-size="11">Tool Calls</text>
  </svg>
</div>

---

## 02. MCP Components

### MCP Server

An MCP server:

- Exposes tools/resources to clients
- Defines tool schemas (inputs/outputs)
- Handles tool execution
- Communicates via transport layer (stdio, HTTP, WebSocket)

### MCP Client

An MCP client:

- Discovers available tools from servers
- Sends tool call requests
- Receives and processes tool responses
- Typically embedded in remote AI assistants (Claude, ChatGPT, etc.) or local models (Ollama, etc.)

### Transport Layer

MCP supports multiple transport mechanisms:

- **stdio**: Standard input/output (used in K-Agent)
- **HTTP**: RESTful API communication
- **WebSocket**: Real-time bidirectional communication

---

## 03. MCP Tool Structure

An MCP tool consists of:

1. **Name**: Unique identifier
2. **Description**: What the tool does
3. **Input Schema**: JSON Schema for parameters
4. **Handler**: Function that executes the tool logic

**Example Tool Definition:**

```typescript
{
  name: "hello",
  description: "Returns a greeting message",
  inputSchema: {
    type: "object",
    properties: {
      name: {
        type: "string",
        description: "Name to greet"
      }
    },
    required: ["name"]
  }
}
```

**Tool Handler:**

```typescript
async function handleHello(args: { name: string }) {
  return {
    content: [
      {
        type: "text",
        text: `Hello, ${args.name}!`
      }
    ]
  };
}
```

---

## 04. Exploring the K-Agent MCP Server

Let's examine the MCP server included in the labs environment.

```bash
# Connect to container
docker exec -it kagent-controller bash

# View the MCP server code
cat /app/src/index.ts
```

The server implements two simple tools:

1. **hello**: Greets a user by name
2. **add**: Adds two numbers

---

## 05. Testing MCP Tools

### Using MCP Inspector

MCP Inspector is a tool for testing MCP servers interactively.

```bash
# Inside the container, install mcp-inspector (if not already installed)
npm install -g @modelcontextprotocol/inspector

# Start the MCP Inspector
npx @modelcontextprotocol/inspector node /app/build/index.js
```

!!! info "MCP Inspector UI"
    MCP Inspector will start a web interface at `http://localhost:6274`
    
    You can also test tools programmatically using the examples below.

**Step-by-step MCP Inspector Testing:**

1. Get the Authentication Token  
   When you start MCP Inspector, the terminal displays:
   
    ```
    🔑 Session token: [long-token-string]
    
    🔗 Open inspector with token pre-filled:
        http://localhost:6274/?MCP_PROXY_AUTH_TOKEN=[token]
    ```

2. Copy the Authentication URL  
   Copy the complete URL with the token (the second line starting with `http://`)

3. Open MCP Inspector in Your Browser  
   Paste the complete URL from step 2 into your browser. You'll be authenticated immediately.

4. Configure the Server Connection  
   In the MCP Inspector interface:
   
      - Verify the **"Transport"** is set to **`stdio`** (NOT http or streamable-http)
      - You'll see a **"Command"** field - it should already show: `node`
      - look for the **"Argument"** field - it should show: `/app/build/index.js`
      - Click the **"Connect"** button
      - Wait for the status to show **"Connected"** with a green indicator

5. Explore Available Tools:
  
      - Once connected, click on the **"Tools"** tab at the top of the interface, and the on **"List Tools"** button
      - You'll see a list of available tools from your MCP server:
        - `hello`: Returns a friendly greeting message
        - `add`: Adds two numbers together

6. Test the Hello Tool 
 
      - Click the `hello` tool from the list
      - You'll see an input form for the tool's parameters
      - In the **name** field, enter: `K-Agent User`
      - Click **"Run Tool"**
      - **Expected Result** - You should see:
        - **Tool Result: Success**
        - **Message**: `Hello, K-Agent User! Welcome to K-Agent Labs.`

7. Test the Add Tool  

      - In the Tools tab, find and click the `add` tool
      - You'll see input fields for two parameters:
        - **a**: Enter `5`
        - **b**: Enter `3`
      - Click **"Run Tool"**
      - **Expected Result**: You should see:
        - **Tool Result: Success**
        - **Message**: `The sum of 5 and 3 is 8`

!!! warning "Authentication Required"
    The MCP Inspector requires authentication by default. Always use the URL with the token (shown in the terminal when you start the inspector), or manually enter the token in the Configuration settings. If you lose the token, restart the MCP Inspector to generate a new one.

!!! tip "Disabling Authentication (Development Only)"
    You can disable authentication by setting the `DANGEROUSLY_OMIT_AUTH=true` environment variable:
    ```bash
    DANGEROUSLY_OMIT_AUTH=true npx @modelcontextprotocol/inspector node /app/build/index.js
    ```
    **⚠️ WARNING**: This is dangerous and should ONLY be used in isolated development environments, never in production or when exposed to the internet.

!!! warning "Keep MCP Inspector Running"
    Make sure the MCP Inspector command (`npx @modelcontextprotocol/inspector node /app/build/index.js`) is still running in your terminal. If the connection fails or you see errors, restart the command in the container.

!!! tip "Interactive Testing"
    The MCP Inspector provides a user-friendly web interface to test your MCP server without writing code. This is perfect for debugging and understanding how MCP tools work before integrating them with AI assistants.
    
    **Note**: The Inspector displays tool results in a readable format. Internally, MCP uses JSON-RPC 2.0 protocol with structured responses, but the UI shows you the human-readable content. For JSON view, see the "History" section below the UI

### Testing Tools via Command Line

Let's test the MCP tools using a simple Node.js script.

!!! info "Running Multiple Sessions"
    You can run this command-line test **while keeping the MCP Inspector running**. The script creates its own MCP server process, so it won't interfere with the Inspector.

**Create test script:**

```bash
# Open a new terminal and connect to the container
docker exec -it kagent-controller bash

# Inside the container, create and run the test script
cat > /labs-scripts/test-mcp.js << 'EOF'
const { spawn } = require('child_process');

// Start MCP server process
const mcpServer = spawn('node', ['/app/build/index.js']);

let responseData = '';

// Send ListTools request
const listToolsRequest = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/list",
  params: {}
};

// Send request to server
mcpServer.stdin.write(JSON.stringify(listToolsRequest) + '\n');

// Collect response
mcpServer.stdout.on('data', (data) => {
  responseData += data.toString();
  console.log('Server response:', data.toString());
});

// Wait and send tool call
setTimeout(() => {
  const toolCallRequest = {
    jsonrpc: "2.0",
    id: 2,
    method: "tools/call",
    params: {
      name: "hello",
      arguments: {
        name: "K-Agent User"
      }
    }
  };
  
  mcpServer.stdin.write(JSON.stringify(toolCallRequest) + '\n');
}, 1000);

// Cleanup after 3 seconds
setTimeout(() => {
  mcpServer.kill();
  process.exit(0);
}, 3000);
EOF

# Run the test
node /labs-scripts/test-mcp.js
```

!!! tip "Expected Output"
    When you run this script, you should see JSON-RPC responses from the MCP server, showing the raw protocol communication that happens behind the scenes in MCP Inspector.

---

## 06. Understanding JSON-RPC Protocol

MCP uses JSON-RPC 2.0 for communication. Every request/response follows this structure:

### Request Format

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "hello",
    "arguments": {
      "name": "Alice"
    }
  }
}
```

### Response Format

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Hello, Alice!"
      }
    ]
  }
}
```

---

## 07. Hands-on Exercise

!!! info "Hands-on JSON-RPC Testing"
    These exercises provide direct interaction with the MCP server using JSON-RPC protocol over stdio. This gives you a deeper understanding of how MCP communication works at the protocol level.

### Exercise 1: List Available Tools

Test listing tools from the MCP server using direct JSON-RPC communication:

```bash
# Connect to container
docker exec -it kagent-controller bash

# Inside the container, create a test script
cat > /labs-scripts/test-list-tools.js << 'EOF'
const { spawn } = require("child_process");

console.log("Starting MCP server test...");

try {
  // Start MCP server
  const server = spawn("node", ["/app/build/index.js"], {
    stdio: ["pipe", "pipe", "pipe"]
  });

  console.log("Server spawned, PID:", server.pid);

  server.stdout.on("data", (data) => {
    console.log("RESPONSE:", data.toString().trim());
  });

  server.stderr.on("data", (data) => {
    console.log("SERVER:", data.toString().trim());
  });

  // Send tools/list request
  const listRequest = {
    jsonrpc: "2.0",
    id: 1,
    method: "tools/list",
    params: {}
  };

  setTimeout(() => {
    console.log("Sending:", JSON.stringify(listRequest));
    server.stdin.write(JSON.stringify(listRequest) + "\n");
  }, 1000);

  // Exit after 5 seconds
  setTimeout(() => {
    server.kill();
    process.exit(0);
  }, 5000);

} catch (error) {
  console.error("Error:", error.message);
}
EOF

# Run the test
node /labs-scripts/test-list-tools.js
```

**Expected Output:**
```
Starting MCP server test...
Server spawned, PID: 18211
SERVER: K-Agent MCP Server running on stdio
Sending: {"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}
RESPONSE: {"result":{"tools":[{"name":"hello","description":"Returns a friendly greeting message","inputSchema":{"type":"object","properties":{"name":{"type":"string","description":"Name to greet"}},"required":["name"]}},{"name":"add","description":"Adds two numbers together","inputSchema":{"type":"object","properties":{"a":{"type":"number","description":"First number"},"b":{"type":"number","description":"Second number"}},"required":["a","b"]}}]},"jsonrpc":"2.0","id":1}
```

### Exercise 2: Call the Hello Tool

Test calling the hello tool using direct JSON-RPC communication:

```bash
# Connect to container
docker exec -it kagent-controller bash

# Inside the container, create a test script
cat > /labs-scripts/test-hello-tool.js << 'EOF'
const { spawn } = require("child_process");

console.log("Testing hello tool...");

try {
  const server = spawn("node", ["/app/build/index.js"], {
    stdio: ["pipe", "pipe", "pipe"]
  });

  console.log("Server spawned, PID:", server.pid);

  server.stdout.on("data", (data) => {
    console.log("RESPONSE:", data.toString().trim());
  });

  server.stderr.on("data", (data) => {
    console.log("SERVER:", data.toString().trim());
  });

  const helloRequest = {
    jsonrpc: "2.0",
    id: 2,
    method: "tools/call",
    params: {
      name: "hello",
      arguments: {
        name: "K-Agent Lab User"
      }
    }
  };

  setTimeout(() => {
    console.log("Sending:", JSON.stringify(helloRequest));
    server.stdin.write(JSON.stringify(helloRequest) + "\n");
  }, 1000);

  setTimeout(() => {
    server.kill();
    process.exit(0);
  }, 5000);

} catch (error) {
  console.error("Error:", error.message);
}
EOF

# Run the test
node /labs-scripts/test-hello-tool.js
```

**Expected Output:**
```
Testing hello tool...
Server spawned, PID: 18237
SERVER: K-Agent MCP Server running on stdio
Sending: {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"hello","arguments":{"name":"K-Agent Lab User"}}}
RESPONSE: {"result":{"content":[{"type":"text","text":"Hello, K-Agent Lab User! Welcome to K-Agent Labs."}]},"jsonrpc":"2.0","id":2}
```

### Exercise 3: Call the Add Tool

Test calling the add tool using direct JSON-RPC communication:

```bash
# Connect to container
docker exec -it kagent-controller bash

# Inside the container, create a test script
cat > /labs-scripts/test-add-tool.js << 'EOF'
const { spawn } = require("child_process");

console.log("Testing add tool...");

try {
  const server = spawn("node", ["/app/build/index.js"], {
    stdio: ["pipe", "pipe", "pipe"]
  });

  console.log("Server spawned, PID:", server.pid);

  server.stdout.on("data", (data) => {
    console.log("RESPONSE:", data.toString().trim());
  });

  server.stderr.on("data", (data) => {
    console.log("SERVER:", data.toString().trim());
  });

  const addRequest = {
    jsonrpc: "2.0",
    id: 3,
    method: "tools/call",
    params: {
      name: "add",
      arguments: {
        a: 5,
        b: 3
      }
    }
  };

  setTimeout(() => {
    console.log("Sending:", JSON.stringify(addRequest));
    server.stdin.write(JSON.stringify(addRequest) + "\n");
  }, 1000);

  setTimeout(() => {
    server.kill();
    process.exit(0);
  }, 5000);

} catch (error) {
  console.error("Error:", error.message);
}
EOF

# Run the test
node /labs-scripts/test-add-tool.js
```

**Expected Output:**
```
Testing add tool...
Server spawned, PID: 18263
SERVER: K-Agent MCP Server running on stdio
Sending: {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"add","arguments":{"a":5,"b":3}}}
RESPONSE: {"result":{"content":[{"type":"text","text":"The sum of 5 and 3 is 8"}]},"jsonrpc":"2.0","id":3}
```

---

## 08. Key Takeaways

!!! success "What You Learned"
    - ✓ MCP is a standardized protocol for AI-tool communication
    - ✓ MCP servers expose tools with defined schemas
    - ✓ Tools have names, descriptions, input schemas, and handlers
    - ✓ JSON-RPC 2.0 is the communication format
    - ✓ Transport can be stdio, HTTP, or WebSocket

!!! info "MCP in Practice"
    MCP servers are typically used by AI assistants like Claude, ChatGPT with plugins, or custom AI applications. The stdio transport allows them to run as local processes.

---

## 09. Additional Resources

- [MCP Specification](https://modelcontextprotocol.io/docs)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol/sdk)
- [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification)

---

## 10. Next Steps

Now that you understand MCP basics, you'll learn how to build your own MCP server with Python.

**What's next:**

- [Lab 002 - Python MCP Server](../002-python-server/) - Build a custom MCP server
- Creating custom tools with Python
- Implementing tool handlers
