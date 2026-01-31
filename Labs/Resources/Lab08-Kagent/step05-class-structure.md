````markdown
# Step 05: K-Agent Server Class Structure

## Define the KAgentServer Class

Add the class definition to your `src/index.ts`:

```typescript
class KAgentServer {
  // Kubernetes API clients
  private k8sConfig: k8s.KubeConfig;
  private k8sAppsApi: k8s.AppsV1Api;
  private k8sCoreApi: k8s.CoreV1Api;

  // MCP Server instance
  private server: Server;

  constructor() {
    // Initialize Kubernetes configuration
    this.k8sConfig = new k8s.KubeConfig();
    try {
      this.k8sConfig.loadFromDefault();
    } catch (error) {
      console.error("Warning: Could not load Kubernetes configuration.");
      console.error("Make sure kubectl is configured.");
      console.error(
        "Error:",
        error instanceof Error ? error.message : String(error),
      );
    }

    // Create Kubernetes API clients
    this.k8sAppsApi = this.k8sConfig.makeApiClient(k8s.AppsV1Api);
    this.k8sCoreApi = this.k8sConfig.makeApiClient(k8s.CoreV1Api);

    // Initialize MCP server
    this.server = new Server(
      {
        name: "k-agent-logs",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
        },
      },
    );

    // Setup request handlers
    this.setupHandlers();
  }

  private setupHandlers() {
    // Will be implemented in next steps
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("K-Agent MCP server running on stdio");
  }
}

// Create and run the server
const server = new KAgentServer();
server.run().catch(console.error);
```
````

## Class Structure Explanation

### Properties

| Property     | Type         | Purpose                      |
| ------------ | ------------ | ---------------------------- |
| `k8sConfig`  | `KubeConfig` | Loads and manages kubeconfig |
| `k8sAppsApi` | `AppsV1Api`  | Apps API for deployments     |
| `k8sCoreApi` | `CoreV1Api`  | Core API for pods/logs       |
| `server`     | `Server`     | MCP server instance          |

### Constructor Flow

1. **Load Configuration** - Reads `~/.kube/config` or in-cluster config
2. **Create API Clients** - Instantiates typed K8s API clients
3. **Initialize MCP Server** - Creates server with name and capabilities
4. **Setup Handlers** - Registers tool and resource handlers

### Run Method

- Creates stdio transport for client communication
- Connects server to transport
- Begins listening for JSON-RPC requests

```

```
