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