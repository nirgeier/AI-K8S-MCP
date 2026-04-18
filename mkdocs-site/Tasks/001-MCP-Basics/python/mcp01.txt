from mcp.server.fastmcp import FastMCP
from starlette.responses import Response, JSONResponse
from starlette.requests import Request
import types

mcp = FastMCP("kagent-mcp-server", port=8888)

# Backwards-compat shim: some inspector tooling (fastmcp helpers)
# expect a `_list_tools_mcp` coroutine on the server instance. Provide
# a thin wrapper that forwards to the FastMCP `list_tools` implementation.
async def _list_tools_mcp(self):
    return await self.list_tools()

# Bind the method to the instance
# MCP need to access it as an instance method later
# This will return list of ToolMetadata objects
mcp._list_tools_mcp = types.MethodType(_list_tools_mcp, mcp)

# Common CORS headers used by the inspector (browser-based)
HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Proxy-Token",
}

# Example tool definitions
# These will be automatically registered with the MCP server
@mcp.tool()
def hello(name: str) -> str:
    """Returns a friendly greeting message"""
    return f"Hello, {name}! Welcome to K-Agent Labs."

# Example tool that adds two numbers
# Demonstrates handling of numeric inputs and outputs
# This will become MCP tool available at /tools
@mcp.tool()
def add(a: float, b: float) -> str:
    """Adds two numbers together"""
    result = a + b
    return f"The sum of {a} and {b} is {result}"

# Resource to return the source code of this server
# Useful for inspection and learning purposes
@mcp.resource("mcp://code")
def get_code() -> str:
    """Returns the source code of this server"""
    with open(__file__, "r") as f:
        return f.read()

@mcp.custom_route("/", methods=["GET", "OPTIONS"])
async def root_health_check(request: Request) -> Response:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=HEADERS)
    return Response("MCP Server Running", status_code=200, headers=HEADERS)

# Health check endpoints
# MCP manifest endpoint, negotiation, and tools listing
@mcp.custom_route("/health", methods=["GET", "OPTIONS"])
async def health_check(request: Request) -> Response:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=HEADERS)
    return Response("MCP Server Running", status_code=200, headers=HEADERS)

# MCP Manifest endpoint as per MCP specification
# Provides metadata about the MCP server
@mcp.custom_route("/.well-known/mcp", methods=["GET", "OPTIONS"])
async def mcp_manifest(request: Request) -> JSONResponse:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=HEADERS)
    host = request.headers.get("host", "localhost:8888")
    scheme = request.url.scheme or "http"
    base = f"{scheme}://{host}"
    manifest = {
        "name": "kagent-mcp-server",
        "version": "0.1.0",
        "base_url": base,
        "transport": "streamable-http",
        "endpoints": {
            "manifest": "/.well-known/mcp",
            "health": "/health",
            "root": "/",
            "negotiate": "/negotiate",
            "events": "/mcp",
            "tools": "/tools",
        },
    }
    return JSONResponse(manifest, headers=HEADERS)

# MCP Negotiation endpoint
# Clients use this to negotiate connection parameters
# Supports token-based authentication
@mcp.custom_route("/negotiate", methods=["GET", "POST", "OPTIONS"])
async def negotiate(request: Request) -> JSONResponse:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=HEADERS)
    host = request.headers.get("host", "localhost:8888")
    scheme = request.url.scheme or "http"
    mcp_url = f"{scheme}://{host}/mcp"

    # Accept proxy token from query param, X-Proxy-Token header, or Authorization bearer
    token = request.query_params.get("token") or request.headers.get("x-proxy-token") or request.headers.get("X-Proxy-Token")
    auth = request.headers.get("authorization") or request.headers.get("Authorization")
    if not token and auth and auth.lower().startswith("bearer "):
        token = auth.split(None, 1)[1]

    response = {"transport": "streamable-http", "url": mcp_url}
    if token:
        response["proxy_token"] = token

    return JSONResponse(response, headers=HEADERS)

# Tools listing endpoint
# Returns metadata about all registered tools
# Used by inspectors to discover available tools
@mcp.custom_route("/tools", methods=["GET", "OPTIONS"])
async def tools_list(request: Request) -> JSONResponse:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=HEADERS)
    # Use the server's list_tools implementation so the inspector sees
    # the canonical, generated tool metadata instead of a hand-written list.
    tools = await mcp._list_tools_mcp()

    serializable = []
    for t in tools:
        try:
            serializable.append(t.model_dump())
        except Exception:
            try:
                serializable.append(t.dict())
            except Exception:
                serializable.append(str(t))

    return JSONResponse({"tools": serializable}, headers=HEADERS)

# Main entry point to run the MCP server
def main():
    # Start the MCP server with streamable-http transport
    # Mounted at /mcp path
    # This will listen on port 8888 as configured above
    mcp.run(transport="streamable-http", mount_path="/mcp")

if __name__ == "__main__":
    main()
