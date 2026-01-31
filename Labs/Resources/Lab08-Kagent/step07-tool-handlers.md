````markdown
# Step 07: Tool Call Handlers

## Add Tool Call Handler to setupHandlers()

Add the following after the `ListToolsRequestSchema` handler:

```typescript
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
        throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
    }
  } catch (error) {
    throw new McpError(
      ErrorCode.InternalError,
      `Tool execution failed: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
});
```
````

## Handler Flow

```
Client Request
    ↓
CallToolRequestSchema Handler
    ↓
Extract: { name, arguments }
    ↓
Switch by Tool Name
    ├── list_pods → handleListPods()
    ├── collect_pod_logs → handleCollectPodLogs()
    └── unknown → McpError
    ↓
Return Result or Error
```

## Error Handling

The handler uses `McpError` with standard error codes:

| ErrorCode        | Usage                   |
| ---------------- | ----------------------- |
| `MethodNotFound` | Unknown tool name       |
| `InternalError`  | Execution failure       |
| `InvalidParams`  | Bad input (you can add) |

## Response Format

All tool handlers return:

```typescript
{
  content: [
    {
      type: "text",
      text: "result string",
    },
  ];
}
```

```

```
