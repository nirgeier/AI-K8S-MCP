# Welcome to the MCP Labs

**Here you'll Learn and Build Model Context Protocol (MCP) from Scratch**



<img src="../assets/images/mcp-feature-image.jpg" alt="MCP Feature" class="center" style="max-width:800; border-radius:20px;"/>

---


## Introduction

* Welcome to the MCP Labs - a comprehensive, hands-on guide to mastering the Model Context Protocol! 
* Whether you're new to MCP or looking to deepen your understanding, this learning series will take you from fundamentals to building production-ready MCP servers.

---

## What is MCP?

* The **Model Context Protocol (MCP)** is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). 
* Think of it as a universal adapter that allows AI applications to connect to various data sources, tools, and services in a consistent and scalable way.



---

## What You'll Learn

Through hands-on labs, you'll:

-  **Understand MCP Architecture** - Master the client-server model and protocol fundamentals
-  **Build MCP Servers** - Create servers from scratch using TypeScript and the official SDK
-  **Implement Tools** - Develop functions that LLMs can call to perform actions
-  **Expose Resources** - Provide contextual data that LLMs can read and reference
-  **Create Prompts** - Build reusable templates for common tasks
-  **Deploy to Production** - Apply best practices for real-world applications

---

## Learning Path

---

## Who Is This For?

This learning series is designed for:

- **Developers** building AI-powered applications
- **Engineers** integrating LLMs with existing systems
- **Technical Architects** designing AI infrastructure
- **DevOps Professionals** deploying and maintaining MCP servers
- **AI Enthusiasts** wanting to understand standardized AI application development
- **Anyone** curious about standardized AI application development

---

## Prerequisites

To get the most out of these labs, you should have:

- **Basic Programming Knowledge** - Familiarity with JavaScript/TypeScript
- **Node.js Experience** - Understanding of npm and basic Node.js concepts
- **Command Line Skills** - Comfortable with terminal/shell commands
- **Code Editor** - VS Code or similar IDEs (VS Code recommended)

---

### Required Software

Before starting, ensure you have installed:

- **Node.js** v18 or later ([download](https://nodejs.org/))
- **npm** or **yarn** package manager
- **Git** for version control
- A code editor (VS Code with TypeScript is support recommended)

---

## Tools You'll Use

Throughout the labs, you'll work with:

- **[@modelcontextprotocol/sdk](https://github.com/modelcontextprotocol/typescript-sdk)** - Official TypeScript SDK
- **[MCP Inspector](https://github.com/modelcontextprotocol/inspector)** - Essential testing tool
- **TypeScript** - Type-safe server development
- **JSON-RPC 2.0** - Communication protocol

---

## Learning Approach

Each lab includes:

-  **Clear Objectives** - Know what you'll learn before you start
-  **Detailed Explanations** - Understand the "why" behind the code
-  **Complete Code Examples** - Working, tested code you can run
-  **Hands-on Exercises** - Practice what you've learned
-  **Key Takeaways** - Reinforce important concepts
-  **Additional Resources** - Dive deeper on specific topics

In addition, you'll find a complete [Tasks](Lab01-MCP-Fundamentals/lab1-tasks.md/) section dedicated just to exercises and challenges to solidify your understanding.

---

## Getting Started

Ready to begin your MCP journey? 

Here's how to start:

1. **[Browse the Labs](index.md)** - See an overview of all available labs
2. **[Start with Lab 1](Lab01-MCP-Fundamentals/index.md)** - Begin with the fundamentals
3. **Complete the various labs in Order** - Each lab builds on previous knowledge
4. **Practice & Experiment** - Try variations and explore beyond examples in the **[Tasks](Lab01-MCP-Fundamentals/lab1-tasks.md/)** section

---

## Community & Support

Join the growing MCP community:

- **[MCP Discord](https://discord.gg/modelcontextprotocol)** - Ask questions, share projects
- **[GitHub Organization](https://github.com/modelcontextprotocol)** - Contribute to the ecosystem
- **[Official Documentation](https://modelcontextprotocol.io)** - Comprehensive reference
- **[MCP Specification](https://spec.modelcontextprotocol.io)** - Protocol details

---

## Why Learn MCP?

MCP is revolutionizing how we build AI applications:

- **Universal Connectivity** - One integration works across all MCP-compatible apps
- **Reusability** - Build once, use everywhere
- **Scalability** - Add new capabilities without rebuilding integrations
- **Standardization** - Consistent patterns and best practices
- **Growing Ecosystem** - Join a vibrant, expanding community


---

## After This Course

Upon completion, you'll be able to:

- Build custom MCP servers for your specific needs
- Integrate LLMs with your company's tools and data sources
- Contribute to the MCP open source ecosystem
- Create servers that others can use
- Help others learn and adopt MCP

---



# Explanations

This document provides detailed explanations of key concepts in the MCP (Model Context Protocol) server implementation, including endpoints, function calls, and RAGs (Retrieval-Augmented Generation).

---

## Endpoints

### General Meaning of Endpoints in This MCP Server

In the context of this MCP (Model Context Protocol) server, the "endpoints" refer to the API routes (URLs) that the server exposes for clients (like MCP inspectors, AI assistants, or other tools) to interact with it. 

These endpoints are part of the server's manifest, which is a metadata document that describes the server's capabilities, transport method (e.g., "streamable-http"), and available routes. 

The manifest is served at `/.well-known/mcp` and helps clients discover and connect to the server.

The endpoints follow RESTful conventions and support HTTP methods like GET, POST, and OPTIONS (for CORS preflight). They enable core MCP functionalities such as tool execution, resource access, prompt management, and server health checks. The server uses FastMCP (a framework for building MCP servers) and runs on port 8889 by default. 

Each endpoint is implemented as a custom route in the code, often with CORS headers for browser-based clients.

Below, you'll find explanations for each endpoint from the manifest, including its purpose, typical HTTP methods, and what it does based on the code implementation. 

They are grouped logically for clarity.

---

### Core Server and Discovery Endpoints
These handle basic server operations, discovery, and connection setup.

- **manifest** (`/.well-known/mcp`):  
  Serves the MCP manifest (metadata about the server, including capabilities and all endpoints). Clients use this to understand what the server supports. Handled by `mcp_manifest()` – returns JSON with server info, base URL, and endpoint list.

- **health** (`/health`):  
  Simple health check to confirm the server is running. Returns a plain text response like "MCP Server Running". Handled by `health_check()`.

- **ping** (`/ping`):  
  Connection health check with more details. Returns JSON with status ("ok"), timestamp, and server name. Handled by `ping()`.

- **root** (`/`):  
  Root endpoint for basic server status. Similar to health, returns "MCP Server Running". Handled by `root_health_check()`.

- **negotiate** (`/negotiate`):  
  Used for connection negotiation (e.g., transport setup and optional authentication via tokens). Clients send tokens here; the server responds with connection details. Handled by `negotiate()` – supports proxy tokens from headers or query params.

- **metadata** (`/metadata`):  
  Provides detailed server metadata, including protocol version and capabilities (e.g., support for tools, prompts). Handled by `metadata()` – returns JSON with server info and feature flags.

- **events** (`/mcp`):  
  The main MCP event stream endpoint for streamable HTTP transport. This is where real-time communication happens (e.g., tool calls, responses). It's the core mount path for the FastMCP server. Handled by the FastMCP framework's run method.

---

### Tool-Related Endpoints
These manage MCP tools (functions the server exposes, like "hello" or "add").

- **tools** (`/tools`):  
  Lists all available tools with metadata (names, descriptions, arguments). Clients use this to discover tools. Handled by `tools_list()` – returns JSON with tool details from the server's `list_tools()` method.

- **tools_execute** (`/tools/execute`):  
  Executes a single tool synchronously. Clients send the tool name and arguments; the server runs it and returns the result. Handled by `tool_execute()` – validates args, executes via `execute_tool()`, and tracks executions.

- **tools_batch** (`/tools/batch`):  
  Executes multiple tools in a batch (array of calls). Useful for efficiency. Handled by `tool_batch_execute()` – processes each call and returns results.

- **tools_stream** (`/tools/stream`):  
  Executes a tool with streaming responses (e.g., for long-running tasks). Returns NDJSON (newline-delimited JSON) events like "start", "result", and "end". Handled by `tool_stream_execute()`.

- **tools_history** (`/tools/history`):  
  Retrieves execution history for tools (recent runs, with optional limit). Handled by `tool_history()` – returns JSON with past executions from `TOOL_EXECUTIONS`.

---

### Prompt and Resource Endpoints
These handle reusable prompts and static resources.

- **prompts** (`/prompts`):  
  Lists available prompt templates (e.g., "code_review_prompt"). Clients can use these for structured interactions. Handled by `prompts_list()` – returns JSON with prompt metadata.

- **resources** (`/resources`):  
  Lists available resources (e.g., server source code or info). Handled by `resources_list()` – returns JSON with resource URIs and descriptions.

---

### Sampling and Roots Endpoints
These support advanced MCP features like LLM sampling and file system access.

- **sampling** (`/sampling`):  
  Provides LLM sampling (text generation) using Ollama. Clients send a prompt; the server generates a response. Handled by `sampling()` – integrates with Ollama API for completions.

- **roots** (`/roots`):  
  Lists file system roots (e.g., the current working directory). Used for file-based operations. Handled by `roots_list()` – returns JSON with root URIs.

---

### Custom/Ollama-Specific Endpoint

- **ollama_status** (`/ollama/status`):  
  Checks the status of the connected Ollama instance (local LLM server). Returns model info, connection status, and available models. Handled by `ollama_status()` – queries Ollama's `/api/tags` endpoint.

All endpoints include CORS headers for cross-origin requests and handle OPTIONS preflights. The server tracks tool executions globally for history/debugging.

---


## Function Calls

### What Are Function Calls?
In the context of MCP (Model Context Protocol) and AI systems, function calls (often referred to as "tools" in MCP terminology) are mechanisms that allow AI models or clients to invoke external functions or services dynamically. 

Instead of generating plain text responses, the AI can decide to call a predefined function with specific arguments, execute it on the server, and incorporate the results into its response. 

This enables more interactive, tool-augmented AI behaviors, such as performing calculations, querying databases, or interacting with APIs.

In this MCP server, tools are essentially function calls exposed via the `/tools` endpoints. For example, the `hello` tool is a function that takes a `name` argument and returns a greeting string.

---

### What Do They Do?
Function calls allow the AI to extend its capabilities beyond static knowledge. 

They enable:

- **Dynamic Execution**: The AI can perform real-time actions, like adding numbers or generating text via Ollama.
- **Structured Interactions**: Clients (e.g., an AI assistant) can call functions to retrieve data or perform tasks, then use the output in conversations.
- **Modularity**: Developers can add new functions without retraining the AI model.
- **Safety and Control**: Arguments are validated, and executions are tracked for auditing.

In MCP, tools are registered with decorators like `@mcp.tool()`, and clients discover them via the `/tools` endpoint.

---

### How to Set Them Up
1. **Define the Function**: Write a Python function with type hints and a docstring. For example:
   ```python
   @mcp.tool()
   def my_tool(arg1: str, arg2: int = 0) -> str:
       """Description of what the tool does."""
       # Implementation here
       return f"Result: {arg1} and {arg2}"
   ```
      - Use `@mcp.tool()` to register it with FastMCP.
      - Arguments should have types; defaults are optional.

2. **Validation and Execution**: The server automatically validates arguments against the function signature (via `validate_tool_arguments`) and executes it (via `execute_tool`). Results are tracked in `TOOL_EXECUTIONS`.

3. **Expose via Endpoints**: Tools are listed at `/tools`, executed at `/tools/execute`, etc. No additional setup needed beyond registration.

4. **Testing**: Use the `/tools/history` endpoint to debug executions. Ensure the function handles errors gracefully.

5. **Integration with AI**: Clients (e.g., via MCP inspectors) can call these functions. For LLM integration, the AI might be prompted to output function call JSON, which the client then executes.

Function calls are asynchronous if the function is a coroutine (`async def`).


---

## RAGs (Retrieval-Augmented Generation)

### What Are RAGs?

RAGs stand for Retrieval-Augmented Generation, a technique in AI where an LLM (Large Language Model) retrieves relevant information from external data sources before generating a response. 

This improves accuracy, reduces hallucinations, and allows the model to access up-to-date or domain-specific knowledge not in its training data. 

Instead of relying solely on pre-trained knowledge, RAGs "augment" generation with retrieved context.

In this MCP server context, RAGs can be implemented using resources (static data) or sampling (dynamic retrieval via Ollama). 

For example, retrieving code snippets or server info to inform responses.

---

### How Do They Work?

   1. **Retrieval Phase**: When a query is made, the system searches a knowledge base (e.g., documents, databases) for relevant chunks of data.
   2. **Augmentation**: Retrieved data is fed into the LLM's prompt as context.
   3. **Generation**: The LLM generates a response based on both the query and retrieved data.

<br>

- Key components:

     - **Data Sources**: Could be files, APIs, or databases.
     - **Retriever**: Searches and ranks relevant data (e.g., via embeddings or keywords).
     - **Generator**: The LLM that produces the final output.

In MCP, resources at `/resources` can serve as static data sources, while sampling at `/sampling` can generate augmented responses.

---

### How to Set Them Up
1. **Define Data Sources**: Use MCP resources for static data. For example:
   ```python
   @mcp.resource("mcp://my-data")
   def get_data() -> str:
       """Returns relevant data."""
       return "Retrieved information here."
   ```

      - Resources are listed at `/resources` and can be queried by URI.

2. **Implement Retrieval**: For dynamic retrieval, integrate with tools or sampling. For instance, use a tool to query a database or API, then pass results to Ollama via `/sampling`.

3. **Augment with Sampling**: At `/sampling`, send a prompt that includes retrieved context:
   ```json
   {
     "prompt": "Using this data: [retrieved info]. Answer: [query]",
     "model": "llama3.2:latest"
   }
   ```

      - Ollama generates the response with augmentation.


4. **Full RAG Pipeline**:
  
      - Client queries the server.
      - Server retrieves data (e.g., via a tool or resource).
      - Data is injected into a prompt.
      - Sampling generates the augmented response.

5. **Tools for RAG**: Add tools like `search_documents` that retrieve data. Combine with prompts for structured queries.

6. **Best Practices**: Use embeddings (e.g., via Ollama or external services) for semantic search. Cache retrieved data for efficiency. Ensure data sources are secure and up-to-date.

RAGs enhance MCP servers by making them knowledge-aware, useful for applications like chatbots with custom data or code assistants.


---

## Additional MCP Inspector Tabs and Configuration

The MCP Inspector provides various tabs that correspond to different capabilities and endpoints in your MCP server. 

These tabs allow you to test and interact with the server's features. Below, you'll find explanations for each tab mentioned (resources, prompts, tools, ping, sampling, elicitations, roots, auth, metadata) and how to configure them in the JSON manifest within `mcp02.py`.

The manifest is defined in the `mcp_manifest()` function. It includes a `"capabilities"` object (boolean flags indicating support) and an `"endpoints"` object (URL paths). To enable or configure a feature, update these sections accordingly.

---

### Resources Tab
- **Purpose**: Displays static data sources (e.g., files, server info) that clients can access.
- **Configuration**: 
    - Set `"resources": true` in `"capabilities"`.
    - Add `"resources": "/resources"` in `"endpoints"`.
    - Implement the `/resources` endpoint to list available resources (e.g., URIs like `mcp://code`).
    - Register resources with `@mcp.resource("uri")` decorators.
- **Example**: In `mcp02.py`, resources like `get_code()` and `get_server_info()` are registered and listed via `/resources`.

---

### Prompts Tab
- **Purpose**: Shows reusable prompt templates for structured interactions (e.g., code review prompts).
- **Configuration**:
      - Set `"prompts": true` in `"capabilities"`.
      - Add `"prompts": "/prompts"` in `"endpoints"`.
      - Implement the `/prompts` endpoint to return a list of prompt metadata.
      - Register prompts with `@mcp.prompt()` decorators.
- **Example**: Prompts like `code_review_prompt()` are defined and exposed via `/prompts`.

---

### Tools Tab
- **Purpose**: Lists executable functions (tools) that clients can invoke (e.g., `hello`, `add`).
- **Configuration**:
      - Set `"tools": true` in `"capabilities"`.
      - Add `"tools": "/tools"` in `"endpoints"`.
      - Implement `/tools` to return tool metadata from `mcp.list_tools()`.
      - Register tools with `@mcp.tool()` decorators.
- **Example**: Tools like `hello()` and `add()` are registered and discoverable via `/tools`.


---


### Ping Tab
- **Purpose**: Tests server connectivity and health with a simple ping.
- **Configuration**:
      - Add `"ping": "/ping"` in `"endpoints"`.
      - Implement the `/ping` endpoint to return JSON with status, timestamp, and server name.
- **Example**: The `ping()` function returns `{"status": "ok", ...}`.


---

### Sampling Tab
- **Purpose**: Allows LLM text generation (e.g., via Ollama) for completions.
- **Configuration**:
      - Set `"sampling": true` in `"capabilities"`.
      - Add `"sampling": "/sampling"` in `"endpoints"`.
      - Implement `/sampling` to accept prompts and return generated text.
- **Example**: Uses Ollama API to generate responses based on input prompts.

---


### Elicitations Tab
- **Purpose**: Likely refers to logging or event elicitation (capturing server events/logs). In MCP, this may map to `"logging"` capability for debugging.
- **Configuration**:
      - Set `"logging": true` in `"capabilities"`.
      - No specific endpoint needed, but ensure logging is enabled in the server framework.
- **Note**: If this refers to "events," use the `/mcp` endpoint for streamable HTTP events.

---


### Roots Tab
- **Purpose**: Lists file system roots for file-based operations.
- **Configuration**:
      - Set `"roots": true` in `"capabilities"`.
      - Add `"roots": "/roots"` in `"endpoints"`.
      - Implement `/roots` to return root URIs (e.g., current directory).
- **Example**: Returns `[{"uri": "file://current/dir", "name": "Current Directory"}]`.

---

### Auth Tab
- **Purpose**: Handles authentication (e.g., token-based access).
- **Configuration**:
      - Use the `/negotiate` endpoint for auth negotiation.
      - Accept tokens via headers (e.g., `Authorization: Bearer <token>`).
      - In the manifest, no direct flag, but ensure `/negotiate` supports auth.
- **Example**: The `negotiate()` function checks for tokens and includes them in responses.

---

### Metadata Tab
- **Purpose**: Provides server metadata (version, capabilities, protocol info).
- **Configuration**:
      - Add `"metadata": "/metadata"` in `"endpoints"`.
      - Implement `/metadata` to return detailed server info.
- **Example**: Returns JSON with `serverInfo` and `capabilities`.

To update the manifest in `mcp02.py`, edit the `manifest` dictionary in `mcp_manifest()`. For instance, to add a new capability, include it in `"capabilities"` and its endpoint in `"endpoints"`. Restart the server after changes.

---

## Creating a Personal Custom RAG

Retrieval-Augmented Generation (RAG) allows you to build a custom knowledge system by combining data retrieval with LLM generation. 

Here's how to create one in your MCP server context:

### Step 1: Define Data Sources
- **Static Data**: Use MCP resources for fixed content (e.g., documents, code).
      - Register with `@mcp.resource("mcp://my-data")`.
      - Store data in files, databases, or variables.
- **Dynamic Data**: Integrate APIs or databases for real-time retrieval.
      - Create tools to query external sources (e.g., a tool that searches a vector database).

### Step 2: Implement Retrieval
- **Simple Retrieval**: Use keyword search or basic queries.
      - Example: A tool that reads from a JSON file or API.
- **Advanced Retrieval**: Use embeddings for semantic search.
      - Install libraries like `sentence-transformers` or `faiss`.
      - Embed your data and queries, then find similar vectors.
      - Example: Store document chunks in a vector DB, retrieve top matches for a query.

### Step 3: Augment with LLM
- **Integration**: Pass retrieved data into prompts.
      - Use the `/sampling` endpoint or a tool like `ollama_generate()`.
      - Example Prompt: `"Using this data: {retrieved_info}. Answer: {user_query}"`.
- **Pipeline**:
      1. User queries the server.
      2. Retrieve relevant data (via tool or resource).
      3. Inject data into LLM prompt.
      4. Generate response via sampling.

### Step 4: Set Up in MCP Server
- **Add Tools/Resources**: Register retrieval functions as tools (e.g., `@mcp.tool() def search_docs(query: str)`).
- **Configure Endpoints**: Ensure `/resources`, `/tools`, and `/sampling` are enabled.
- **Testing**: Use the Inspector to test retrieval and generation.

---

### Best Practices
- **Data Management**: Keep data secure and up-to-date.
- **Performance**: Cache embeddings; use efficient search.
- **Scalability**: For large datasets, use external vector DBs like Pinecone or Weaviate.
- **Example Code Snippet**:

      ```python
      @mcp.tool()
      def rag_query(query: str) -> str:
          # Retrieve data (simplified)
          retrieved = "Relevant info from your data source."
          # Augment and generate
          prompt = f"Data: {retrieved}. Query: {query}"
          return ollama_generate(prompt)
      ```

This creates a personal RAG tailored to your data, enhancing AI responses with custom knowledge.

---

## Adding Clients (Internal LLM)

To integrate an internal Large Language Model (LLM) as a client with your MCP server, you need to set up a client that can connect to the MCP server, discover its capabilities, and invoke tools, resources, or prompts. 

This allows the LLM to augment its responses using the server's functionalities, such as executing custom tools or retrieving data.

### Prerequisites
- **MCP Server Running**: Ensure your MCP server is running and accessible (e.g., at `http://localhost:8889`).

- **Client Library**: Use an MCP-compatible client library. For Python, you can use libraries like `mcp-client` or integrate with frameworks like LangChain or LlamaIndex that support MCP. For other languages, check for MCP SDKs (e.g., Node.js MCP clients).

- **LLM Setup**: Have an internal LLM ready, such as Ollama running locally, or another model that supports tool calling (e.g., via function calling APIs).

- **Information Needed**:

    - **Server Base URL**: The full URL where the MCP server is hosted (e.g., `http://localhost:8889`).
    - **Manifest URL**: The URL to the manifest endpoint (e.g., `http://localhost:8889/.well-known/mcp`). This provides metadata about the server's capabilities and endpoints.
    - **Authentication Token** (optional): If the server requires authentication, obtain a token (e.g., via the `/negotiate` endpoint). Pass it in headers like `Authorization: Bearer <token>`.
    - **Transport Method**: Confirm the server uses "streamable-http" transport, as indicated in the manifest.

---

### Step-by-Step Instructions

1. **Install Required Libraries**:

      - For Python: Install the MCP client library if available (e.g., `pip install mcp-client` or similar). If using LangChain, install `langchain` and MCP integrations.
      - For other setups: Ensure your LLM framework supports MCP (e.g., LlamaIndex has MCP connectors).

2. **Fetch the Server Manifest**:

      - Make a GET request to the manifest URL to retrieve the server's metadata.
      - Example (using curl): `curl http://localhost:8889/.well-known/mcp`
      - Parse the JSON response to understand available endpoints (e.g., `/tools`, `/resources`, `/sampling`) and capabilities (e.g., `tools: true`).

3. **Initialize the MCP Client**:

      - In your client code, create an MCP client instance and connect to the server.
      - Provide the base URL and any authentication details.
      - Example in Python (pseudo-code):
     
        ```python
        from mcp_client import MCPClient  # Assuming a library exists

        client = MCPClient(base_url="http://localhost:8889", auth_token="your_token_if_needed")
        client.connect()
        ```

4. **Discover Capabilities**:

      - Use the client to list available tools, resources, or prompts.
      - Example: Call `client.list_tools()` to get tool metadata, which includes names, descriptions, and argument schemas.

5. **Integrate with the Internal LLM**:

      - Configure the LLM to use the MCP client for tool calling.
      - For LLMs that support function calling (e.g., GPT models or local models via libraries), map MCP tools to callable functions.
      - Example workflow:
        - When the LLM generates a response, check if it needs to call a tool (e.g., based on a prompt or decision).
        - Use the MCP client to execute the tool: `result = client.call_tool("tool_name", args={"arg1": "value"})`.
        - Feed the result back into the LLM's context for the final response.
      - For Ollama or similar local LLMs, you may need a wrapper script that handles the tool calling logic.

6. **Handle Sampling or Generation**:

      - If the LLM needs to generate text augmented by the server, use the `/sampling` endpoint via the client.
      - Example: `response = client.sample(prompt="Your prompt here", model="llama3.2:latest")`.

7. **Test the Integration**:

      - Run a test query where the LLM invokes a tool (e.g., the "hello" tool).
      - Verify that the client connects, executes the tool, and the LLM incorporates the result.
      - Check logs on the server side (e.g., via `/tools/history`) for executions.

8. **Handle Errors and Authentication**:

      - Implement error handling for failed connections or tool executions.
      - If authentication fails, renegotiate tokens via `/negotiate`.
      - Ensure CORS and security settings allow the client to connect.

9.  **Advanced Setup**:

      - For streaming: Use the `/tools/stream` endpoint for real-time tool execution.
      - For batch operations: Call multiple tools at once via `/tools/batch`.
      - Integrate with prompts: Use `/prompts` to retrieve structured prompts for the LLM.

By following these steps, your internal LLM can act as an MCP client, leveraging the server's tools and resources to provide more capable and context-aware responses. 

If using a specific LLM framework, refer to its documentation for MCP integration details.
## Next Steps

**[View All Labs →](index.md)** - See the complete learning path

**[Start Lab 1 →](Lab01-MCP-Fundamentals/index.md)** - Begin your MCP journey!

---

<div style="text-align: center; padding: 2em 0;">
  <h2>Ready to Build the Future of AI Applications?</h2>
  <p style="font-size: 1.2em; margin: 1em 0;">Let's get started!</p>
</div>
