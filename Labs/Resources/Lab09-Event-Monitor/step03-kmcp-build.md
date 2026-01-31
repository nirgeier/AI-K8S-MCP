# Step 3: Use kmcp to Build the Server

## 3.1 Install kmcp CLI

```bash
curl -fsSL https://raw.githubusercontent.com/kagent-dev/kmcp/refs/heads/main/scripts/get-kmcp.sh | bash
```

## 3.2 Initialize Project

```bash
cd ~
kmcp init python kagent-monitor-kmcp
cd kagent-monitor-kmcp
```

## 3.3 Add Dependencies

```bash
echo "kubernetes>=28.1.0" >> requirements.txt
echo "prometheus-client>=0.19.0" >> requirements.txt
```

## 3.4 Create k8s_tools.py

Create the file `src/k8s_tools.py` with the following content:

```python
from core.server import mcp
from kubernetes import client, config

# Initialize K8s client
try:
    config.load_kube_config()
except:
    config.load_incluster_config()
v1 = client.CoreV1Api()

@mcp.tool(description="Collect logs and events from the Kubernetes cluster")
async def collect_logs(namespace: str = "default") -> str:
    """Collect logs and events from the Kubernetes cluster"""
    # Fetch events
    events = v1.list_namespaced_event(namespace)
    output = []
    for e in events.items:
        output.append(f"[EVENT] {e.last_timestamp} {e.type} {e.reason}: {e.message}")
    return "\n".join(output)
```

## 3.5 Run Locally

```bash
kmcp run --project-dir .
```

## 3.6 Build Docker Image

```bash
docker build -t nirgeier/my-kagent-monitor:v1 .
```

## 3.7 Push or Load Image

### Docker Hub

```bash
docker push nirgeier/my-kagent-monitor:v1
```

### Kind

```bash
kind load docker-image my-kagent-monitor:v1 --name <cluster-name>
```

### Minikube

```bash
minikube image load my-kagent-monitor:v1
```

## 3.8 Deploy to Kubernetes

```bash
kmcp deploy --namespace default --image nirgeier/my-kagent-monitor:v1
```
