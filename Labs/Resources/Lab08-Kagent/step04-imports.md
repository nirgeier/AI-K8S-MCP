````markdown
# Step 04: Imports and Dependencies

## Understanding the Imports

Add the following imports to your `src/index.ts` file:

```typescript
// MCP SDK - Server Infrastructure
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

// MCP SDK - Protocol Types and Schemas
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// Kubernetes Client
import * as k8s from "@kubernetes/client-node";
```
````

## Import Breakdown

### MCP Server Components

| Import                 | Purpose                                                    |
| ---------------------- | ---------------------------------------------------------- |
| `Server`               | Core MCP server class - handles all protocol communication |
| `StdioServerTransport` | Transport layer for stdin/stdout communication             |

### MCP Types and Schemas

| Import                       | Purpose                            |
| ---------------------------- | ---------------------------------- |
| `CallToolRequestSchema`      | Schema for tool execution requests |
| `ErrorCode`                  | Standard MCP error codes           |
| `ListResourcesRequestSchema` | Schema for resource listing        |
| `ListToolsRequestSchema`     | Schema for tool listing            |
| `McpError`                   | Custom MCP error class             |
| `ReadResourceRequestSchema`  | Schema for resource reading        |

### Kubernetes Client

| Import           | Purpose                               |
| ---------------- | ------------------------------------- |
| `k8s`            | Full Kubernetes client library        |
| `k8s.KubeConfig` | Configuration loader                  |
| `k8s.CoreV1Api`  | Core API (pods, services, namespaces) |
| `k8s.AppsV1Api`  | Apps API (deployments, replicasets)   |

## Why These Imports?

1. **MCP SDK** provides the server infrastructure and protocol handling
2. **Kubernetes Client** enables API communication with your cluster
3. **Type Schemas** ensure type-safe request/response handling

```

```
