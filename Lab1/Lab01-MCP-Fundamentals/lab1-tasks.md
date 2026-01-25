# MCP Fundementals Tasks - Lab 1

Welcome to the MCP Lab Tasks section! 

This comprehensive collection of hands-on exercises will help you master the Model Context Protocol through practical implementation.

Each lab has 15 exercises designed to build your skills progressively. Try to solve each exercise on your own before clicking the solution dropdown.

---


### Exercise 1.1: Identify MCP Components

Identify the three main components of the MCP architecture and explain their roles.

??? "Solution"
    The three main components are:
    
    1. <strong>MCP Client</strong>: Applications that host LLMs (like Roo Code, Claude Desktop)
    2. <strong>MCP Server</strong>: Exposes capabilities to clients (tools, resources, prompts)
    3. <strong>MCP Protocol</strong>: JSON-RPC 2.0 based communication standard

### Exercise 1.2: MCP vs Traditional APIs

Explain how MCP differs from traditional REST APIs in terms of LLM integration.

??? "Solution"
    MCP provides a standardized protocol specifically designed for LLM integration, while traditional APIs require custom integration code for each application. MCP enables universal connectivity across all MCP-compatible clients.

### Exercise 1.3: Transport Layers

List the three main transport mechanisms supported by MCP and their use cases.

??? "Solution"
    1. <strong>STDIO</strong>: Most common, for local subprocess communication
    2. <strong>SSE (Server-Sent Events)</strong>: HTTP-based for remote servers
    3. <strong>Streamable HTTP</strong>: Modern standard for remote MCP servers

### Exercise 1.4: MCP Capabilities

Name the three types of capabilities MCP servers can expose.

??? "Solution"
    1. <strong>Tools</strong>: Functions for performing actions
    2. <strong>Resources</strong>: Contextual data for reading
    3. <strong>Prompts</strong>: Pre-built prompt templates

### Exercise 1.5: JSON-RPC Message Types

Identify the three types of messages used in MCP communication.

??? "Solution"
    1. <strong>Requests</strong>: Require responses (tools/list, resources/read)
    2. <strong>Responses</strong>: Match to requests with results or errors
    3. <strong>Notifications</strong>: One-way messages (initialized, cancelled)

### Exercise 1.6: MCP Initialization Flow

Describe the sequence of messages during MCP server initialization.

??? "Solution"
    1. Client sends `initialize` request
    2. Server processes and responds with `initialize` response
    3. Client sends `initialized` notification
    4. Connection is established

### Exercise 1.7: Tool Definition Schema

What information must be included when defining an MCP tool?

??? "Solution"
    - Tool name
    - Description
    - Input parameters (JSON Schema)
    - Whether it has side effects

### Exercise 1.8: Resource Identifiers

How are MCP resources identified and what types of data can they contain?

??? "Solution"
    Resources are identified by URIs and can contain text, binary data, or structured data. They are typically read-only.

### Exercise 1.9: Prompt Templates

Explain the purpose of MCP prompts and how they differ from regular prompts.

??? "Solution"
    MCP prompts are pre-built, reusable prompt templates that can include embedded resources and support arguments for customization, ensuring consistency across applications.

### Exercise 1.10: Security Considerations

List three security best practices for MCP implementations.

??? "Solution"
    1. <strong>Authentication & Authorization</strong>: Validate requests and use least-privilege access
    2. <strong>Data Privacy</strong>: Control what data is exposed
    3. <strong>Input Validation</strong>: Sanitize user inputs to prevent injection attacks

### Exercise 1.11: MCP Client Examples

Name three popular MCP client applications.

??? "Solution"
    1. Roo Code (VS Code extension)
    2. Claude Desktop
    3. Continue.dev

### Exercise 1.12: Protocol Versioning

How does MCP handle protocol versioning and backward compatibility?

??? "Solution"
    MCP uses capability negotiation during initialization, allowing clients and servers to agree on supported features and maintain backward compatibility.

### Exercise 1.13: Error Handling

How are errors communicated in MCP?

??? "Solution"
    Errors are communicated through JSON-RPC error responses with error codes, messages, and optional data fields.

### Exercise 1.14: Connection Lifecycle

Describe the complete MCP connection lifecycle from start to finish.

??? "Solution"
    1. Initialization handshake
    2. Capability discovery
    3. Normal operation (tool calls, resource access)
    4. Cleanup and graceful shutdown

### Exercise 1.15: MCP Ecosystem Benefits

Explain three key benefits of the MCP ecosystem approach.

??? "Solution"
    1. <strong>Universal Integration</strong>: One server works with all MCP clients
    2. <strong>Standardized Communication</strong>: Consistent interface across applications
    3. <strong>Rapid Development</strong>: Reduced integration time and duplication