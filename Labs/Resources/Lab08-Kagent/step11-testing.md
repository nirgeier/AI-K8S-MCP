````markdown
# Step 11: Testing with MCP Inspector

## Build and Run

```bash
# Build the TypeScript code
npm run build

# Start the server in development mode
npm run dev
```
````

## Using MCP Inspector

MCP Inspector is a web-based debugging tool for MCP servers.

### Start Inspector

```bash
npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts
```

This will:

1. Start your K-Agent server
2. Launch MCP Inspector web interface
3. Open your browser automatically

### Connect to Server

1. Click the **"Connect"** button at the bottom left
2. Wait for "Connected" status (green indicator)
3. You should see "k-agent-logs v1.0.0" in the title

### Test list_pods Tool

1. Click the **"Tools"** tab
2. Click **"List Tools"** to refresh
3. Click on **`list_pods`**
4. Optionally enter a namespace in the input field
5. Click **"Run Tool"**

**Expected Result:**

```json
[
  {
    "name": "coredns-abc123",
    "namespace": "kube-system",
    "status": "Running",
    "containers": ["coredns"]
  }
]
```

### Test collect_pod_logs Tool

1. Click on **`collect_pod_logs`** in the tools list
2. In the **namespace** field, enter: `kube-system`
3. Optionally specify a **podName**
4. Set **tailLines** to `50`
5. Click **"Run Tool"**

**Expected Result:**

```
=== coredns-abc123/coredns ===
2024-01-15T10:30:45.123Z [INFO] CoreDNS-1.11.1
2024-01-15T10:30:45.124Z linux/amd64, go1.21.1
...
```

## Troubleshooting

| Issue               | Solution                          |
| ------------------- | --------------------------------- |
| "Cannot connect"    | Ensure server is running          |
| "Permission denied" | Check kubectl permissions         |
| "No pods found"     | Verify cluster is running         |
| "Timeout"           | Increase wait time, check cluster |

## Alternative: Manual Testing

You can also test by piping JSON-RPC messages:

```bash
# Test tools/list
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | npm run dev

# Test list_pods tool
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_pods","arguments":{}}}' | npm run dev
```

```

```
