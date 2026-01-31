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