# MCP Labs - Learning Series

<img src="../assets/images/mcp-feature-image.jpg" alt="MCP Feature" class="center" style="max-width:800; border-radius:20px;"/>

---

* Welcome to the Model Context Protocol (MCP) hands-on learning series! 
* This comprehensive set of labs will take you from MCP fundamentals to building production-ready MCP servers.
* **Here you'll learn and build the Model Context Protocol (MCP) from scratch**
* Whether you're new to MCP or looking to deepen your understanding, this learning series will take you from fundamentals to building production-ready MCP servers.

---

## What You'll Learn 

Through these 8 progressive labs, you'll master:

| Topic | Description |
|-------|-------------|
| MCP Architecture | Understanding and mastering the client-server model and core concepts |
| Server Development | Building MCP servers from scratch with TypeScript using the official SDK |
| Tools Implementation | Creating sophisticated tools that interact with external systems and developing functions that LLMs can call to perform actions |
| Resource Management | Exposing contextual data through MCP resources that LLMs can read and reference |
| Prompt Engineering | Building reusable prompt templates for common tasks |
| Production Deployment | Applying best practices for real-world applications |

---

## Labs Overview

### [Lab 0: Environment Setup](Lab00-Setup/lab.md)

Get your development environment ready for MCP server development.

**Topics:**

- Install and configure required tools (Docker, kubectl, Helm, Ollama, MCP Inspector, K-Agent etc.)
- Build and run the K-Agent labs environment (Docker container or locally)
- Verify Kubernetes cluster connectivity
- Prepare the MCP server setup

---

### [Lab 1: MCP Fundamentals](Lab01-MCP-Fundamentals/lab.md)

Get started with the basics! Learn what MCP is, why it exists, and understand its architecture and core components.

**Topics:**

- What is MCP and the problem it solves
- Client-server architecture
- Core capabilities: Tools, Resources, and Prompts
- MCP communication model and lifecycle
- Common use cases

---

### [Lab 2: Building Your First MCP Server](Lab02-First-MCP-Server/lab.md)

Build a complete, working MCP server from the ground up.

**Topics:**

- Project setup with Node.js and TypeScript
- Implementing the MCP protocol
- Creating your first tool
- Testing with MCP Inspector
- Connecting to Claude Desktop

---

### [Lab 3: Implementing MCP Tools](Lab03-MCP-Tools/lab.md)

Master the art of creating sophisticated, production-ready tools.

**Topics:**

- Advanced input validation with JSON Schema
- Real-world tool examples (Weather API, File operations, Database queries)
- Returning rich content types
- Error handling patterns
- Performance optimization and caching

---

### [Lab 4: Working with MCP Resources](Lab04-MCP-Resources/lab.md)

Learn to expose contextual data that LLMs can read and reference.

**Topics:**

- Understanding tools vs. resources
- Implementing different resource types
- Resource URI schemes and templates
- Resource subscriptions for live updates
- Combining tools and resources

---

### [Lab 5: MCP Prompts and Complete Integration](Lab05-MCP-Prompts/lab.md)

Complete your MCP education with prompts and production best practices.

**Topics:**

- Creating reusable prompt templates
- Embedding resources in prompts
- Building a complete server with all capabilities
- Production deployment and configuration
- Debugging and troubleshooting

---

### [Lab 6: Complete MCP Server Implementation](Lab06-MCP-Workflow/lab.md)

Build a complete MCP server from scratch, learning each component.

**Topics:**

- Project setup with Python
- Implementing the MCP protocol
- Creating tools, resources, and prompts
- Testing and debugging

---

### [Lab 7: MCP Tools with Ollama Integration](Lab07-MCP-Ollama/lab.md)

Master creating sophisticated MCP tools with Ollama integration.

**Topics:**

- Design robust tool schemas with advanced validation
- Implement tools that interact with external systems
- Return multiple content types
- Handle errors gracefully
- Apply best practices for tool composition

---

### [Lab 8: K-Agent Integration](Lab08-Kagent/lab.md)

Implement a specialized MCP server (K-Agent) that interacts with Kubernetes clusters to provide AI-driven log collection and analysis.

**Topics:**

- MCP server architecture for Kubernetes
- Secure communication with Kubernetes API
- Implementing tools for pod discovery and log retrieval
- Collecting and structuring logs for LLM consumption
- Containerizing and deploying the K-Agent server


---

## Ready to Begin?

**[Start with Lab 1: MCP Fundamentals →](Lab01-MCP-Fundamentals/index.md)**

Let's build something amazing with MCP!
