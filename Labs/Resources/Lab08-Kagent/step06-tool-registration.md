````markdown
# Step 06: Tool Registration

## Register Tools in setupHandlers()

Update the `setupHandlers()` method to register available tools:

```typescript
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
                description: "Optional: Filter by specific namespace"
              }
            }
          }
        },
        {
          name: "collect_pod_logs",
          description: "Collect logs from all containers in specified pods",
          inputSchema: {
            type: "object",
            properties: {
              namespace: {
                type: "string",
                description: "Namespace to collect logs from"
              },
              podName: {
                type: "string",
                description: "Specific pod name (optional - collects from all if not specified)"
              },
              tailLines: {
                type: "number",
                description: "Number of recent log lines to retrieve",
                default: 100
              }
            },
            required: ["namespace"]
          }
        }
      ]
    };
  });

  // Tool call handler will be added in next step
}
```
````

## Tool Definitions Explained

### list_pods Tool

| Property      | Value       | Description        |
| ------------- | ----------- | ------------------ |
| `name`        | `list_pods` | Tool identifier    |
| `description` | String      | What the tool does |
| `inputSchema` | JSON Schema | Validates inputs   |

**Input Parameters:**

- `namespace` (optional): Filter to specific namespace

### collect_pod_logs Tool

| Property   | Value              | Description         |
| ---------- | ------------------ | ------------------- |
| `name`     | `collect_pod_logs` | Tool identifier     |
| `required` | `["namespace"]`    | Required parameters |

**Input Parameters:**

- `namespace` (required): Target namespace
- `podName` (optional): Specific pod filter
- `tailLines` (optional, default: 100): Log line count

## JSON Schema Format

The `inputSchema` uses JSON Schema to define:

- Parameter types (`string`, `number`)
- Required fields
- Default values
- Descriptions for AI understanding

```

```
