# Step 4: Verify Tool Registration

## 4.1 Check Deployment Status

```bash
kubectl get pods -n default -l app=kagent-monitor-kmcp
```

## 4.2 Verify MCP Server Registration

```bash
kubectl get mcpservers -n default
```

## 4.3 Manual Registration (Optional)

Create the file `mcpserver.yaml` with the following content:

```yaml
apiVersion: kagent.dev/v1alpha1
kind: MCPServer
metadata:
  name: k8s-monitor
  namespace: default
  labels:
    app.kubernetes.io/name: k8s-monitor
    app.kubernetes.io/part-of: kagent
    app.kubernetes.io/component: mcp-server
spec:
  deployment:
    args:
      - src/main.py
    cmd: python
    image: nirgeier/my-kagent-monitor:v1
    port: 3000
  stdioTransport: {}
  transportType: stdio
```

Then apply it:

```bash
kubectl apply -f mcpserver.yaml
```
