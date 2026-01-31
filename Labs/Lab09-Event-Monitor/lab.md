# Lab 09: K8s Event & Log Monitor with Kagent

## Overview

In this lab, you will build a complete observability solution using MCP. You will:

1.  Perform a minimal installation of **Kagent**.
2.  Create a custom **MCP Server in Python** (using the `mcp` SDK) to monitor Kubernetes events and logs.
3.  Register/Connect this tool to Kagent.
4.  Deploy **Prometheus** and **Grafana** using **Helm Charts** to visualize the data.

This lab demonstrates how to extend Kagent's capabilities with custom Python-based tools and integrate K8s observability.

---

## Prerequisites

- **Kubernetes Cluster**: A running cluster (Docker Desktop, OrbStack, Minikube, or remote).
- **kubectl**: Configured to access your cluster.
- **Python 3.10+**: Installed on your local machine.
- **Helm**: Installed (`brew install helm` or equivalent).
- **Kagent CLI**: Installed (or we will install it).

---

## Step 1: Install Kagent

First, we need to set up the Kagent platform. We will perform a minimal installation for development/demo purposes.

### 1.1 Install Kagent CLI

If you haven't installed the `kagent` CLI yet, run the following command:

```bash
curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
```

### 1.2 Install Kagent Platform

Install Kagent into your cluster with the `demo` profile, which sets up the necessary components with minimal resources.

```bash
kagent install --profile demo
```

Verify the installation:

```bash
kubectl get pods -n kagent
```

Wait until all pods are in the `Running` state.

---

## Step 2: Create Custom MCP Tool (Python)

We will use the **MCP Python SDK** to create a tool that connects to Kubernetes, collects events/logs, and exposes metrics.

### 2.1 Project Setup

Create a new directory for your tool:

```bash
mkdir -p kagent-monitor/src
cd kagent-monitor
python3 -m venv venv
source venv/bin/activate
```

### 2.2 Install Dependencies

Create a `requirements.txt` file:

```text
mcp>=1.0.0
kubernetes>=28.1.0
prometheus-client>=0.19.0
```

Install the `requirements.txt`:

```bash
pip install -r requirements.txt
```

### 2.3 Create the MCP Server

Create `src/monitor.py`. This script implements an MCP server that lists K8s events and collects logs.

```python
import asyncio
import os
from kubernetes import client, config
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
from prometheus_client import start_http_server, Counter

# Prometheus Metrics
EVENTS_FETCHED = Counter('k8s_events_fetched_total', 'Total number of K8s events fetched')

# Connect to K8s
try:
    config.load_kube_config()
except:
    config.load_incluster_config()

v1 = client.CoreV1Api()
server = Server("k8s-monitor")

@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="collect_logs",
            description="Collect logs and events from the Kubernetes cluster",
            inputSchema={
                "type": "object",
                "properties": {
                    "namespace": {"type": "string", "description": "Namespace to filter (default: default)"},
                }
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "collect_logs":
        ns = arguments.get("namespace", "default")

        # 1. Fetch Events
        events = v1.list_namespaced_event(ns)
        EVENTS_FETCHED.inc(len(events.items))

        event_logs = []
        for e in events.items:
            event_logs.append(f"[EVENT] {e.last_timestamp} {e.type} {e.reason}: {e.message}")

        # 2. Fetch Pod Logs (Sample from first pod)
        pods = v1.list_namespaced_pod(ns)
        pod_logs = []
        if pods.items:
            p = pods.items[0]
            try:
                logs = v1.read_namespaced_pod_log(p.metadata.name, ns, tail_lines=5)
                pod_logs.append(f"[POD {p.metadata.name}] {logs}")
            except:
                pod_logs.append(f"[POD {p.metadata.name}] Could not read logs")

        full_log = "\n".join(event_logs + pod_logs)
        return [TextContent(type="text", text=full_log)]

    raise ValueError(f"Unknown tool: {name}")

async def main():
    # Start Prometheus Metrics endpoint on port 8000
    start_http_server(8000)

    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
```

### 2.4 Test the Tool (Offline)

You can run the tool directly to Verify it starts:

```bash
# This will listen on stdio (blocking) and Metrics port 8000
# Press Ctrl+C to stop
npx @modelcontextprotocol/inspector python3 src/monitor.py
```

---

## Step 2: Use `kmcp` to Build the Server

- Kagent provides a CLI tool called `kmcp` that simplifies bootstrapping, building, and deploying MCP servers.
- It handles the boilerplate and provides a structured way to manage tools.

### 2.1 Install `kmcp` CLI

Install the `kmcp` CLI on your local machine:

```bash
curl -fsSL https://raw.githubusercontent.com/kagent-dev/kmcp/refs/heads/main/scripts/get-kmcp.sh | bash
```

Verify the installation:

```bash
kmcp --help
```

### 2.2 Initialize a New Project

Create a new Python MCP project using `kmcp`. This will set up a project structure with best practices.

```bash
cd ~
kmcp init python kagent-monitor-kmcp
cd kagent-monitor-kmcp
```

This creates a directory structure like this:

- `src/main.py`: The entry point for the server.
- `src/tools/`: Directory where you can add your custom tools.
- `requirements.txt`: Python dependencies.
- `kmcp.yaml`: Project configuration.

### 2a.3 Add Dependencies

Edit standard `requirements.txt` to include the Kubernetes and Prometheus libraries:

```bash
echo "kubernetes>=28.1.0" >> requirements.txt
echo "prometheus-client>=0.19.0" >> requirements.txt
```

### 2a.4 Implement the Tool

- In `kmcp` projects, tools are automatically discovered from the `src/tools/` directory.
- Create a new file `src/tools/monitor.py` and add the logic.

Create `src/tools/k8s_tools.py`:

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

### 2a.5 Run Locally with `kmcp`

Run the server locally with the MCP Inspector attached:

```bash
kmcp run --project-dir .
```

### 2a.6 Build and Push Docker Image

Before deploying to the cluster, you need to build the Docker image and make it available to your Kubernetes cluster (by pushing to a registry or loading it directly).

1. **Build the image using Docker:**

   ```bash
   docker build -t nirgeier/my-kagent-monitor:v1 .
   ```

2. **Push or Load the image:**
   - **If using a Registry (Docker Hub, etc.):**
     ```bash
     docker push nirgeier/my-kagent-monitor:v1
     ```
   - **If using Kind:**
     ```bash
     kind load docker-image my-kagent-monitor:v1 --name <cluster-name>
     ```
   - **If using Minikube:**
     ```bash
     minikube image load my-kagent-monitor:v1
     ```

### 2a.7 Deploy to Kubernetes

Deploy the MCP server to your cluster using `kmcp`. You must specify the image you built.

```bash
# Deploy with the custom image
kmcp deploy --namespace default --image nirgeier/my-kagent-monitor:v1
```

_(Note: Ensure the image name matches exactly what you built/loaded. If you used a different name, update the command accordingly.)_

---

## Step 3: Verify Tool Registration

Since we used `kmcp deploy` in the previous step, the MCP server is installed and should be registered with Kagent.

### 3.1 Check Deployment Status

First, ensure the pod is running. Common issues include `ImagePullBackOff` if the image name is incorrect or not loaded into the cluster.

```bash
kubectl get pods -n default -l app=kagent-monitor-kmcp
```

### 3.2 Verify MCP Server Registration

Check if the `MCPServer` resource exists:

```bash
kubectl get mcpservers -n default
```

You should see your project name (e.g., `kagent-monitor-kmcp`) in the list.

### 3.3 (Optional) Manual Registration

If `kmcp deploy` failed or you want to register it manually:

1.  **Create Manifest**:
    Create a file `mcpserver.yaml`:

    ```yaml
    apiVersion: kagent.dev/v1alpha1
    kind: MCPServer
    metadata:
      name: k8s-monitor
      namespace: default
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

2.  **Apply Manifest**:

    ```bash
    kubectl apply -f mcpserver.yaml
    ```

---

## Step 4: Create the Agent

The Kagent Dashboard displays **Agent** resources, not MCPServers directly. An MCPServer provides tools, but you need to create an **Agent** resource to make it appear in the dashboard.

### 4.1 Create RemoteMCPServer Resource

First, create a `RemoteMCPServer` that provides HTTP access to the MCP server.

Create a file `remotemcpserver.yaml`:

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

Apply it:

```bash
kubectl apply -f remotemcpserver.yaml
```

### 4.2 Create Agent Resource

Now create an **Agent** that uses the tools from your MCP server.

Create a file `agent.yaml`:

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

> **Important**: The `toolNames` field is required. List the tools exposed by your MCP server. You can find these by checking the MCP server logs when it starts.

Apply it:

```bash
kubectl apply -f agent.yaml
```

### 4.3 Verify the Agent

Check that the Agent is ready:

```bash
kubectl get agents -n default
```

You should see `k8s-monitor-agent` with `READY: True`:

```
NAME                TYPE          READY   ACCEPTED
k8s-monitor-agent   Declarative   True    True
```

Also verify the RemoteMCPServer:

```bash
kubectl get remotemcpservers -n default
```

If the Agent shows `READY: False`, check the pod logs:

```bash
kubectl logs -l app.kubernetes.io/name=k8s-monitor-agent -n default
```

---

## Step 5: Install NGINX Ingress Controller

To expose our services (like Grafana) externally, we will use an Ingress Controller. This allows us to access dashboards via a URL instead of using `port-forward`.

### 4.1 Install via Helm

Add the ingress-nginx repository and install the chart:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

Wait until the ingress controller pod is running:

```bash
kubectl get pods -n ingress-nginx
```

---

## Step 6: Deploy Prometheus & Grafana (Helm)

We will deploy the observability stack using Helm Charts to visualize the metrics exposed by our tool.

### 5.1 Add Helm Repos

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 5.2 Install Prometheus

We need to configure Prometheus to scrape our MCP tool and also know it is served under a subpath (`/prometheus`).
We effectively set the `external-url` and adjust the health check probes to match that new path.

Create `prometheus-config.yaml`:

```yaml
server:
  baseURL: /prometheus

  # Fix probes to check status at /prometheus/-/ready instead of /-/ready
  readinessProbe:
    httpGet:
      path: /prometheus/-/ready
      port: 9090
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 5
    timeoutSeconds: 4
    failureThreshold: 3
    successThreshold: 1

  livenessProbe:
    httpGet:
      path: /prometheus/-/healthy
      port: 9090
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 3
    successThreshold: 1

extraScrapeConfigs: |
  - job_name: 'mcp-monitor'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_name]
        regex: .*monitor.*
        action: keep
      - source_labels: [__address__]
        regex: ([^:]+)(?::\d+)?
        replacement: ${1}:8000
        target_label: __address__
```

Install Prometheus:

```bash
helm upgrade --install prometheus prometheus-community/prometheus -f prometheus-config.yaml
```

### 5.3 Install Grafana

When deploying Grafana behind an ingress with a subpath (e.g. `/grafana`), we must configure the `root_url` and `serve_from_sub_path` settings so it generates correct links.

Create `grafana-config.yaml`:

```yaml
adminPassword: admin123
grafana.ini:
  server:
    domain: cluster.local
    root_url: "%(protocol)s://%(domain)s/grafana"
    serve_from_sub_path: true
```

Install Grafana with the configuration:

```bash
helm upgrade --install grafana grafana/grafana -f grafana-config.yaml
```

### 5.4 Verify Deployments

Ensure all pods are running before proceeding:

```bash
kubectl get pods -n default
kubectl get pods -n ingress-nginx
```

---

## Step 7: Expose Services via Ingress

Instead of using `port-forward`, we will expose Prometheus, Grafana, and the Kagent UI using the NGINX Ingress Controller. We will configure them on the hostname `cluster.local`.

### 6.1 Create Ingress Manifest

Create a file named `observability-ingress.yaml`. This defines routing rules for:

- `/` -> Kagent Dashboard (`kagent-ui`)
- `/grafana` -> Grafana
- `/prometheus` -> Prometheus

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: observability-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: cluster.local
      http:
        paths:
          - path: /prometheus
            pathType: Prefix
            backend:
              service:
                name: prometheus-server
                port:
                  number: 80
          - path: /grafana
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kagent-ui
                port:
                  number: 8080
```

### 6.2 Apply the Ingress

```bash
kubectl apply -f observability-ingress.yaml
```

### 6.3 Update Hosts File

To access `http://cluster.local`, map the hostname to your local machine (or the cluster IP).

1.  **Find the IP**:
    - **Docker Desktop / OrbStack**: Use `127.0.0.1`.
    - **Minikube**: Run `minikube ip`.

2.  **Edit Host File**:
    - **Linux/macOS**: `/etc/hosts`
    - **Windows**: `C:\Windows\System32\drivers\etc\hosts`

    Add the following line:

    ```text
    127.0.0.1  cluster.local
    ```

    _(Replace `127.0.0.1` with your Minikube IP if applicable)_.

---

## Step 8: Access and Configure

Now you can access all services via the browser.

### 7.1 Access Grafana

1.  Navigate to **[http://cluster.local/grafana](http://cluster.local/grafana)**.
2.  **Login**:
    - User: `admin`
    - Password: `admin` (or the password set in `grafana-config.yaml`).
3.  **Add Data Source**:
    - Go to **Connections > Data Sources > Add data source**.
    - Select **Prometheus**.
    - **Connection URL**: `http://prometheus-server` (Keep this as the internal K8s Service name).
    - Click **Save & Test**.

### 7.2 Access Prometheus

- Navigate to **[http://cluster.local/prometheus](http://cluster.local/prometheus)**.
- You can query for `k8s_events_fetched_total` to verify your MCP tool is sending metrics.

### 7.3 Access Kagent Dashboard & MCP Tool

- Navigate to **[http://cluster.local](http://cluster.local)**.
- This loads the **Kagent Dashboard**.
- Look for **k8s-monitor** (or `kagent-monitor-kmcp`) in the list of active Agents/MCP Servers.
- You can verify that Kagent sees the `collect_logs` tool capability provided by your server.

---

## Summary

You have successfully:

1.  Installed Kagent.
2.  Built a Python MCP tool to collect K8s logs/events.
3.  Registered the tool.
4.  Installed NGINX Ingress Controller.
5.  Deployed an observability stack (Prometheus/Grafana) behind an Ingress.
6.  Exposed the Kagent Dashboard on the same domain.

This setup offers a production-like environment where AI agents (via Kagent) and human operators (via Grafana) can monitor the cluster side-by-side.
