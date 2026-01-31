````markdown
# Step 10: Complete K-Agent Server Code

## Complete src/index.ts

```typescript
// Import MCP SDK components and Kubernetes client
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as k8s from "@kubernetes/client-node";

class KAgentServer {
  // Store Kubernetes API clients (for talking to your cluster)
  private k8sConfig: k8s.KubeConfig;
  private k8sAppsApi: k8s.AppsV1Api;
  private k8sCoreApi: k8s.CoreV1Api;
  private server: Server;

  constructor() {
    // Initialize connection to your Kubernetes cluster (uses ~/.kube/config)
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

    this.k8sAppsApi = this.k8sConfig.makeApiClient(k8s.AppsV1Api);
    this.k8sCoreApi = this.k8sConfig.makeApiClient(k8s.CoreV1Api);

    // Create MCP server that AI tools can connect to
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

    // Handle incoming MCP requests
    this.setupHandlers();
  }

  private setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "list_pods",
            description: "List all pods across namespaces with their status",
            inputSchema: {
              type: "object",
              properties: {
                namespace: {
                  type: "string",
                  description: "Optional: Filter by specific namespace",
                },
              },
            },
          },
          {
            name: "collect_pod_logs",
            description: "Collect logs from all containers in specified pods",
            inputSchema: {
              type: "object",
              properties: {
                namespace: {
                  type: "string",
                  description: "Namespace to collect logs from",
                },
                podName: {
                  type: "string",
                  description:
                    "Specific pod name (optional - collects from all if not specified)",
                },
                tailLines: {
                  type: "number",
                  description: "Number of recent log lines to retrieve",
                  default: 100,
                },
              },
              required: ["namespace"],
            },
          },
        ],
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "list_pods":
            return await this.handleListPods(args);
          case "collect_pod_logs":
            return await this.handleCollectPodLogs(args);
          default:
            throw new McpError(
              ErrorCode.MethodNotFound,
              `Unknown tool: ${name}`,
            );
        }
      } catch (error) {
        throw new McpError(
          ErrorCode.InternalError,
          `Tool execution failed: ${error instanceof Error ? error.message : String(error)}`,
        );
      }
    });
  }

  private async handleListPods(args: any) {
    const namespace = args?.namespace;
    const pods = await this.getPods(namespace);

    const podList = pods.map((pod) => ({
      name: pod.metadata?.name || "unknown",
      namespace: pod.metadata?.namespace || "unknown",
      status: pod.status?.phase || "unknown",
      containers: pod.spec?.containers?.map((c) => c.name) || [],
    }));

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(podList, null, 2),
        },
      ],
    };
  }

  private async handleCollectPodLogs(args: any) {
    const { namespace, podName, tailLines = 100 } = args;

    if (!namespace) {
      throw new Error("Namespace is required");
    }

    const logs = await this.collectPodLogs(namespace, podName, tailLines);

    return {
      content: [
        {
          type: "text",
          text: logs,
        },
      ],
    };
  }

  private async collectPodLogs(
    namespace: string,
    podName?: string,
    tailLines: number = 100,
  ): Promise<string> {
    const pods = podName
      ? await this.getPods(namespace).then((pods) =>
          pods.filter((p) => p.metadata?.name === podName),
        )
      : await this.getPods(namespace);

    const allLogs: string[] = [];

    for (const pod of pods) {
      if (!pod.metadata?.name) continue;

      const containers = pod.spec?.containers || [];
      for (const container of containers) {
        try {
          const logs = await this.getPodLogs(
            namespace,
            pod.metadata.name,
            container.name,
            tailLines,
          );
          allLogs.push(
            `=== ${pod.metadata.name}/${container.name} ===\n${logs}\n`,
          );
        } catch (error) {
          allLogs.push(
            `=== ${pod.metadata.name}/${container.name} ===\nError retrieving logs: ${error instanceof Error ? error.message : String(error)}\n`,
          );
        }
      }
    }

    return allLogs.join("\n");
  }

  private async getPods(namespace?: string): Promise<k8s.V1Pod[]> {
    try {
      if (namespace) {
        const response = await this.k8sCoreApi.listNamespacedPod({ namespace });
        return response.items || [];
      } else {
        const response = await this.k8sCoreApi.listPodForAllNamespaces();
        return response.items || [];
      }
    } catch (error) {
      throw this.handleK8sError(error);
    }
  }

  private async getPodLogs(
    namespace: string,
    podName: string,
    containerName: string,
    tailLines: number,
  ): Promise<string> {
    try {
      const response = await this.k8sCoreApi.readNamespacedPodLog({
        name: podName,
        namespace: namespace,
        container: containerName,
        tailLines: tailLines,
        timestamps: true,
      });
      return response || "";
    } catch (error) {
      throw this.handleK8sError(error);
    }
  }

  private handleK8sError(error: any): Error {
    if (error.response?.statusCode === 403) {
      return new Error(
        "Access denied: Insufficient permissions to access Kubernetes resources",
      );
    }

    if (error.response?.statusCode === 404) {
      return new Error(
        "Resource not found: The specified pod or namespace may not exist",
      );
    }

    return new Error(`Kubernetes operation failed: ${error.message}`);
  }

  // Start the server and listen for connections
  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("K-Agent MCP server running on stdio");
  }
}

// Actually run the server
const server = new KAgentServer();
server.run().catch(console.error);
```
````

## File Summary

| Lines   | Component                           |
| ------- | ----------------------------------- |
| 1-13    | Imports                             |
| 15-46   | Constructor & initialization        |
| 48-96   | setupHandlers() - tool registration |
| 98-144  | Tool handler methods                |
| 146-188 | Kubernetes API methods              |
| 190-206 | Error handling & server run         |

## Verify the Code

```bash
# Check for syntax errors
npm run build

# Test development mode
npm run dev
```

Expected output:

```
K-Agent MCP server running on stdio
```

```

```
