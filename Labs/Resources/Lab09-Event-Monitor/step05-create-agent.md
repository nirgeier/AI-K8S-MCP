# Step 5: Create the Agent

## 5.1 Create RemoteMCPServer

Create the file `remotemcpserver.yaml` with the following content:

```yaml
apiVersion: kagent.dev/v1alpha2
kind: RemoteMCPServer
metadata:
  name: k8s-monitor-mcp
  namespace: default
  labels:
    app.kubernetes.io/name: k8s-monitor-mcp
    app.kubernetes.io/part-of: kagent
spec:
  description: K8s Event and Log Monitor MCP Server
  protocol: STREAMABLE_HTTP
  url: http://k8s-monitor.default:3000/mcp
```

Then apply it:

```bash
kubectl apply -f remotemcpserver.yaml
```

## 5.2 Create Agent

Create the file `agent.yaml` with the following content:

```yaml
apiVersion: kagent.dev/v1alpha2
kind: Agent
metadata:
  name: k8s-monitor-agent
  namespace: default
  labels:
    app.kubernetes.io/name: k8s-monitor-agent
    app.kubernetes.io/part-of: kagent
spec:
  declarative:
    modelConfig: default-model-config
    systemMessage: |
      You are a Kubernetes monitoring agent that can collect logs and events from a Kubernetes cluster.
      Use the collect_logs tool to gather information about events and pod logs in a given namespace.
    tools:
      - type: McpServer
        mcpServer:
          apiGroup: kagent.dev
          kind: RemoteMCPServer
          name: k8s-monitor-mcp
          toolNames:
            - trace
            - fail
            - sleep
    deployment:
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
        limits:
          cpu: 500m
          memory: 512Mi
```

Then apply it:

```bash
kubectl apply -f agent.yaml
```

## 5.3 Verify the Agent

```bash
kubectl get agents -n default
```

Expected output:

```
NAME                TYPE          READY   ACCEPTED
k8s-monitor-agent   Declarative   True    True
```

## 5.4 Verify RemoteMCPServer

```bash
kubectl get remotemcpservers -n default
```

## 5.5 Debug (if READY: False)

```bash
kubectl logs -l app.kubernetes.io/name=k8s-monitor-agent -n default
```
