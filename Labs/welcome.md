
<!-- header start -->
<div markdown class="center">
# K-Agent Labs

<img src="assets/images/k-agent-labs.png" style="width:400px; border-radius: 20px;">
</div>

---

<img src="assets/images/tldr.png" style="width:100px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">

!!! success "Getting Started Tip"
    Choose the preferred way to run the labs. If you encounter any issues, please check the documentation or ask for assistance.

<div class="grid cards" markdown style="text-align: center;border-radius: 20px;">

- ![](assets/images/docker.png){: .height-64px}
  ```bash
  cd labs-environment && docker-compose up -d
  ```

- ![](assets/images/gcp.png){: .height-64px}<br/><br/>
  <a target="_blank" href="https://shell.cloud.google.com/">Launch on Google Cloud Shell</a>

</div>

## Intro

- This tutorial is for teaching the **K-Agent framework** through hands-on labs designed as practical exercises.
- Each lab is packaged in its own folder and includes the files, manifests, and assets required to complete the lab.
- Every lab folder includes a `README` that describes the lab's objectives, tasks, and how to verify the solution.
- The K-Agent Labs are a series of Kubernetes and MCP automation exercises designed to teach Model Context Protocol skills & features.
- The inspiration for this project is to provide practical learning experiences for K-Agent and MCP.

## Pre-Requirements

- This tutorial will test your `Kubernetes`, `MCP`, and `Cloud` skills.
- You should be familiar with the following topics:
    - Basic Docker and container concepts
    - Kubernetes fundamentals (pods, deployments, services)
    - Basic knowledge of YAML
    - Node.js or Python programming basics
- For advanced Labs: 
    - `MCP` protocol basics
    - `Kubernetes` advanced concepts (RBAC, ConfigMaps, Secrets)
    - `GCP` (Google Cloud Platform) basics
  
## Usage

--8<-- "000-setup/usage.md"

---

!!! warning ""
    - Ensure you have the necessary permissions to run Docker commands or Kubernetes operations on your system.
    - Enjoy, and don't forget to star the project on GitHub!

## Preface

### What is K-Agent?

- **K-Agent** is a Kubernetes-native Model Context Protocol (MCP) server framework.
- It enables AI assistants to interact with Kubernetes clusters and cloud services through standardized tools.
- K-Agent provides a set of MCP tools for cluster management, monitoring, and operations.
- The framework supports multiple transport protocols: stdio, HTTP, and WebSocket.
- K-Agent can be deployed as a containerized service in Kubernetes or run locally for development.

### What is MCP (Model Context Protocol)?

- `MCP` is an open standard protocol for connecting AI assistants to external tools and data sources.
- MCP defines a standard way for AI models to discover, invoke, and interact with tools.
- The protocol uses JSON-RPC 2.0 over various transports (stdio, HTTP, WebSocket).
- MCP enables AI assistants to perform actions beyond text generation, such as API calls, database queries, and system operations.

### How K-Agent Works

<img src="assets/images/k-agent-architecture.png" class="border-radius-20" alt="K-Agent Architecture Diagram"/>

- K-Agent acts as an MCP server that exposes Kubernetes and cloud management capabilities as tools.
- AI assistants connect to K-Agent using the MCP protocol.
- K-Agent translates MCP tool invocations into Kubernetes API calls or cloud service operations.
- Results are returned to the AI assistant in a structured format.

---

### How the K-Agent Labs Work  

- Here's a brief overview of how the `K-Agent Labs` work:

<div class="grid cards" markdown>

- #### Lab Structure
    * Each `lab` is a self-contained learning module with README, demo scripts, and resources.
    
    * Labs build upon each other, starting with MCP basics and progressing to production deployments.
    * Each lab includes hands-on exercises and verification steps.

- #### Environment

    * A unified Docker container provides all the necessary tools (Node.js, Python, kubectl, Helm).

    * The environment is consistent across all platforms (macOS, Linux, Windows).

    * Automated scripts initialize clusters and deploy resources.

- #### Progressive Learning

    * Start with MCP fundamentals and simple tools.

    * Progress through TypeScript and Python MCP server development.

    * Learn Kubernetes deployment and management.

- #### Hands-On Practice
  
    * Each lab includes executable demo scripts for automation.

    * Verify your work with provided test scripts.

    * Build real-world MCP tools that interact with Kubernetes.

</div>
  
- The K-Agent Labs are **designed for practical learning** with a focus on hands-on experience.
  - They guide you from MCP basics to production-ready deployments.
  - Labs can be completed in any supported environment (Docker Desktop, Minikube, Kind, GKE).
  - Each lab is designed to take 10-15 minutes, with a total learning time of ~3 hours.
