# MCP Labs - Learning Series

Welcome to the Model Context Protocol (MCP) hands-on learning series! 

This comprehensive set of labs will take you from MCP fundamentals to building production-ready MCP servers.

---

## What You'll Learn

Through these five progressive [labs](index.md), you'll master:

- **MCP Architecture** - Understanding the client-server model and core concepts
- **Server Development** - Building MCP servers from scratch with TypeScript
- **Tools Implementation** - Creating sophisticated tools that interact with external systems
- **Resource Management** - Exposing contextual data through MCP resources
- **Prompt Engineering** - Building reusable prompt templates for common tasks

## Lab Overview

### [Lab 1: MCP Fundamentals](Lab01-MCP-Fundamentals/index.md)

Get started with the basics! Learn what MCP is, why it exists, and understand its architecture and core components.

**Topics:**

- What is MCP and the problem it solves
- Client-server architecture
- Core capabilities: Tools, Resources, and Prompts
- MCP communication model and lifecycle
- Common use cases

**Duration:** 30-45 minutes

---

### [Lab 2: Building Your First MCP Server](Lab02-First-MCP-Server/index.md)

Build a complete, working MCP server from the ground up.

**Topics:**

- Project setup with Node.js and TypeScript
- Implementing the MCP protocol
- Creating your first tool
- Testing with MCP Inspector
- Connecting to Claude Desktop

**Duration:** 1-1.5 hours

---

### [Lab 3: Implementing MCP Tools](Lab03-MCP-Tools/index.md)

Master the art of creating sophisticated, production-ready tools.

**Topics:**

- Advanced input validation with JSON Schema
- Real-world tool examples (Weather API, File operations, Database queries)
- Returning rich content types
- Error handling patterns
- Performance optimization and caching

**Duration:** 1.5-2 hours

---

### [Lab 4: Working with MCP Resources](Lab04-MCP-Resources/index.md)

Learn to expose contextual data that LLMs can read and reference.

**Topics:**

- Understanding tools vs. resources
- Implementing different resource types
- Resource URI schemes and templates
- Resource subscriptions for live updates
- Combining tools and resources

**Duration:** 1-1.5 hours

---

### [Lab 5: MCP Prompts and Complete Integration](Lab05-MCP-Prompts/index.md)

Complete your MCP education with prompts and production best practices.

**Topics:**

- Creating reusable prompt templates
- Embedding resources in prompts
- Building a complete server with all capabilities
- Production deployment and configuration
- Debugging and troubleshooting

**Duration:** 1.5-2 hours

---

### [Lab 6: K-Agent Integration](Lab06-K-Agent/index.md)

Implement a specialized MCP server (K-Agent) that interacts with Kubernetes clusters to provide AI-driven log collection and analysis.

**Topics:**

- MCP server architecture for Kubernetes
- Secure communication with Kubernetes API
- Implementing tools for pod discovery and log retrieval
- Collecting and structuring logs for LLM consumption
- Containerizing and deploying the K-Agent server

**Duration:** 2-3 hours

---

### [Tasks](Lab01-MCP-Fundamentals/lab1-tasks.md/)
**Duration:** Varies

A dedicated section with exercises and challenges to reinforce your learning from all labs.

---

# Getting Started

<br>

### Prerequisites

- **Node.js** v18 or later
- Basic knowledge of JavaScript/TypeScript
- A code editor (VS Code recommended)
- Terminal/command line familiarity

---

### Recommended Path

1. **Start with [Lab 1](Lab01-MCP-Fundamentals/index.md)** - Even if you're experienced, the fundamentals are important
2. **Complete labs in order** - Each builds on previous knowledge
3. **Do the [hands-on exercises](Lab01-MCP-Fundamentals/lab1-tasks.md/)** - Practice is key to mastery
4. **Experiment freely** - Try variations and explore beyond the examples

---

### Lab Format

Each lab includes:

-  Clear learning objectives
-  Detailed explanations
-  Complete code examples
-  Hands-on exercises
-  Key takeaways
-  Links to additional resources
  
---

## Tips for Success

1. **Set aside focused time** - Labs require concentration and experimentation
2. **Type the code yourself** - Don't just copy-paste; understand each line
3. **Test frequently** - Run your code after each major change
4. **Read error messages carefully** - They often tell you exactly what's wrong
5. **Experiment with modifications** - Try changing parameters and adding features
6. **Join the community** - Connect with other MCP learners and developers

---

## Development Tools

You'll use these tools throughout the labs:

- **[MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)** - Official SDK for building servers
- **[MCP Inspector](https://github.com/modelcontextprotocol/inspector)** - Essential testing tool

---

## Additional Resources

- [MCP Official Documentation](https://modelcontextprotocol.io)
- [MCP Specification](https://spec.modelcontextprotocol.io)
- [MCP GitHub Organization](https://github.com/modelcontextprotocol)
- [Example Servers Repository](https://github.com/modelcontextprotocol/servers)
- [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification)

---

## After Completing the Labs

Once you've finished all five labs, you'll be ready to:

- Build custom MCP servers for your specific needs
- Integrate LLMs with your company's tools and data
- Contribute to the MCP open source ecosystem
- Share your servers with the community
- Help others learn MCP

---

## Community and Support

- **[Stack Overflow](https://stackoverflow.com/questions/tagged/model-context-protocol)** - Tag questions with `model-context-protocol`
- **[MCP Discord](https://discord.gg/modelcontextprotocol)** - Ask questions, share projects
- **[GitHub Organization](https://github.com/modelcontextprotocol)** - Contribute to the ecosystem
- **[Official Documentation](https://modelcontextprotocol.io)** - Comprehensive reference
- **[MCP Specification](https://spec.modelcontextprotocol.io)** - Protocol details
---

## Ready to Begin?

**[Start with Lab 1: MCP Fundamentals →](Lab01-MCP-Fundamentals/index.md)**

Let's build something amazing with MCP!
