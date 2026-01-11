from mcp.server.fastmcp import FastMCP
from starlette.responses import Response, JSONResponse, StreamingResponse
from starlette.requests import Request
import types
import httpx
import json
import asyncio
import time
import inspect
from typing import Any, Dict, List

# =============================================================================
# MCP Server with Generic API Integration Template
# =============================================================================
#
# This MCP server template is designed to work with ANY LLM API provider.
# It has been stripped of Ollama-specific code and now contains placeholders
# for implementing your own API provider.
#
# REQUIRED CHANGES TO IMPLEMENT YOUR API PROVIDER:
# =============================================================================
#
# 1. API CONFIGURATION (Lines ~15-25):
#    - Replace API_BASE_URL with your API's base endpoint
#    - Replace DEFAULT_MODEL with your preferred model name
#    - Replace API_KEY with your actual API key
#    - Update AUTH_HEADERS with any required authentication headers
#
# 2. TOOL FUNCTIONS (Lines ~140-250):
#    - api_generate(): Implement for text generation/completions
#    - api_chat(): Implement for chat-based conversations
#    - api_list_models(): Implement for listing available models
#    - Update request/response formats to match your API's specifications
#
# 3. ENDPOINTS (Lines ~500-600):
#    - /sampling: Update request/response format for completions
#    - /api/status: Update for your API's status/model endpoint
#    - Update error messages and response parsing
#
# 4. FUNCTION NAMING (Lines ~50-60):
#    - Update tool_map with your renamed function names if needed
#    - Update manifest endpoints if you rename routes
#
# 5. TESTING YOUR IMPLEMENTATION:
#    - Test /health endpoint to ensure server starts
#    - Test /api/status endpoint for API connectivity
#    - Test individual tools via MCP Inspector
#    - Check /tools endpoint for proper tool registration
#
# COMMON API PROVIDERS AND THEIR REQUIREMENTS:
# =============================================================================
#
# OpenAI:
# - API_BASE_URL: "https://api.openai.com/v1"
# - Auth: {"Authorization": f"Bearer {API_KEY}"}
# - Endpoints: /chat/completions, /completions, /models
#
# Anthropic Claude:
# - API_BASE_URL: "https://api.anthropic.com"
# - Auth: {"x-api-key": API_KEY, "anthropic-version": "2023-06-01"}
# - Endpoints: /v1/messages, /v1/complete
#
# Google Gemini:
# - API_BASE_URL: "https://generativelanguage.googleapis.com"
# - Auth: Query param ?key=API_KEY
# - Endpoints: /v1beta/models/{model}:generateContent
#
# Azure OpenAI:
# - API_BASE_URL: "https://your-resource.openai.azure.com/openai/deployments/your-deployment"
# - Auth: {"api-key": API_KEY}
# - Endpoints: /chat/completions, /completions
#
# =============================================================================
# TODO: Replace these placeholders with your actual API configuration
API_BASE_URL = "https://your-api-endpoint.com/v1"  # Your API base URL
DEFAULT_MODEL = "your-model-name"  # Your default model name
API_KEY = "your-api-key"  # Your API key (if required)
# TODO: Add any additional authentication headers or configuration needed
AUTH_HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    # Add any other required headers here
}

# Tool execution tracking
TOOL_EXECUTIONS = {}
EXECUTION_COUNTER = 0

mcp = FastMCP("kagent-mcp-server", port=8889)

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

# Helper functions for tool execution
def get_tool_function(tool_name: str):
    """Get the actual function for a tool by name"""
    # Build a mapping of tool names to functions
    # TODO: Update this mapping when you rename the API functions below
    tool_map = {
        'hello': hello,
        'add': add,
        'api_generate': api_generate,  # TODO: Rename this function to match your API
        'api_chat': api_chat,  # TODO: Rename this function to match your API
        'api_list_models': api_list_models,  # TODO: Rename this function to match your API
        'code_review_prompt': code_review_prompt,
        'debug_prompt': debug_prompt,
    }
    return tool_map.get(tool_name)

def validate_tool_arguments(tool_func, arguments: Dict[str, Any]) -> tuple[bool, str]:
    """Validate arguments against function signature"""
    try:
        sig = inspect.signature(tool_func)
        params = sig.parameters
        
        # Check required arguments
        for param_name, param in params.items():
            if param.default == inspect.Parameter.empty and param_name not in arguments:
                return False, f"Missing required argument: {param_name}"
        
        # Check for unexpected arguments
        for arg_name in arguments:
            if arg_name not in params:
                return False, f"Unexpected argument: {arg_name}"
        
        return True, "Valid"
    except Exception as e:
        return False, f"Validation error: {str(e)}"

async def execute_tool(tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Execute a tool and return the result"""
    global EXECUTION_COUNTER
    execution_id = f"exec_{EXECUTION_COUNTER}"
    EXECUTION_COUNTER += 1
    
    start_time = time.time()
    
    try:
        tool_func = get_tool_function(tool_name)
        if not tool_func:
            return {
                "execution_id": execution_id,
                "tool": tool_name,
                "success": False,
                "error": f"Tool '{tool_name}' not found",
                "duration_ms": 0
            }
        
        # Validate arguments
        valid, message = validate_tool_arguments(tool_func, arguments)
        if not valid:
            return {
                "execution_id": execution_id,
                "tool": tool_name,
                "success": False,
                "error": message,
                "duration_ms": 0
            }
        
        # Execute the tool
        if inspect.iscoroutinefunction(tool_func):
            result = await tool_func(**arguments)
        else:
            result = tool_func(**arguments)
        
        duration_ms = (time.time() - start_time) * 1000
        
        execution_record = {
            "execution_id": execution_id,
            "tool": tool_name,
            "arguments": arguments,
            "success": True,
            "result": result,
            "duration_ms": round(duration_ms, 2),
            "timestamp": time.time()
        }
        
        TOOL_EXECUTIONS[execution_id] = execution_record
        return execution_record
        
    except Exception as e:
        duration_ms = (time.time() - start_time) * 1000
        execution_record = {
            "execution_id": execution_id,
            "tool": tool_name,
            "arguments": arguments,
            "success": False,
            "error": str(e),
            "duration_ms": round(duration_ms, 2),
            "timestamp": time.time()
        }
        TOOL_EXECUTIONS[execution_id] = execution_record
        return execution_record

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

# API Integration Tools
# TODO: Implement these functions to match your API provider's specifications
@mcp.tool()
def api_generate(prompt: str, model: str = DEFAULT_MODEL, max_tokens: int = 500) -> str:
    """
    Generate text using your API provider
    
    TODO: Implement this function according to your API's documentation:
    - Update the endpoint URL to match your API's completions/chat endpoint
    - Modify the request JSON structure to match your API's expected format
    - Update response parsing to extract the generated text from your API's response
    - Add proper error handling for your API's error responses
    """
    try:
        import requests
        
        # TODO: Update this request to match your API's format
        # Example for OpenAI-compatible API:
        response = requests.post(
            f"{API_BASE_URL}/completions",  # TODO: Change endpoint as needed
            headers=AUTH_HEADERS,
            json={
                "model": model,
                "prompt": prompt,
                "max_tokens": max_tokens,
                # TODO: Add any other required parameters for your API
            },
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            # TODO: Update this to extract text from your API's response format
            return result.get("choices", [{}])[0].get("text", "No response from model")
        else:
            return f"Error: {response.status_code} - {response.text}"
    except Exception as e:
        return f"Error calling API: {str(e)}"

@mcp.tool()
def api_chat(message: str, model: str = DEFAULT_MODEL, system: str = "") -> str:
    """
    Chat with your API provider using chat API
    
    TODO: Implement this function according to your API's chat documentation:
    - Update the endpoint URL to match your API's chat endpoint
    - Modify the messages structure to match your API's expected format
    - Update response parsing to extract the assistant's message
    - Handle system messages if your API supports them
    """
    try:
        import requests
        
        # TODO: Update message format to match your API
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": message})
        
        # TODO: Update this request to match your API's format
        response = requests.post(
            f"{API_BASE_URL}/chat/completions",  # TODO: Change endpoint as needed
            headers=AUTH_HEADERS,
            json={
                "model": model,
                "messages": messages,
                # TODO: Add any other required parameters for your API
            },
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            # TODO: Update this to extract message from your API's response format
            return result.get("choices", [{}])[0].get("message", {}).get("content", "No response")
        else:
            return f"Error: {response.status_code} - {response.text}"
    except Exception as e:
        return f"Error calling API: {str(e)}"

@mcp.tool()
def api_list_models() -> str:
    """
    List available models from your API provider
    
    TODO: Implement this function to list models from your API:
    - Find your API's models/list endpoint
    - Update response parsing to extract model information
    - Format the output to show model names and any relevant details
    """
    try:
        import requests
        
        # TODO: Update this to match your API's models endpoint
        response = requests.get(
            f"{API_BASE_URL}/models",  # TODO: Change endpoint as needed
            headers=AUTH_HEADERS,
            timeout=5
        )
        
        if response.status_code == 200:
            data = response.json()
            # TODO: Update this to parse your API's model list format
            models = data.get("data", [])
            if not models:
                return "No models available"
            
            result = "Available models:\n"
            for model in models:
                # TODO: Update this to match your API's model object structure
                name = model.get("id", "unknown")
                result += f"- {name}\n"
            return result
        else:
            return f"Error: {response.status_code}"
    except Exception as e:
        return f"Error listing models: {str(e)}"

# Prompts - Reusable prompt templates
@mcp.prompt()
def code_review_prompt(code: str, language: str = "python") -> str:
    """Generate a code review prompt for the given code"""
    return f"""Please review this {language} code and provide feedback:

```{language}
{code}
```

Focus on:
- Code quality and best practices
- Potential bugs or issues
- Performance improvements
- Security concerns
"""

@mcp.prompt()
def debug_prompt(error_message: str, code_context: str = "") -> str:
    """Generate a debugging prompt"""
    prompt = f"""Help me debug this error:

Error: {error_message}
"""
    if code_context:
        prompt += f"\n\nCode context:\n```\n{code_context}\n```"
    return prompt

# Resource to return the source code of this server
# Useful for inspection and learning purposes
@mcp.resource("mcp://code")
def get_code() -> str:
    """Returns the source code of this server"""
    with open(__file__, "r") as f:
        return f.read()

@mcp.resource("mcp://server-info")
def get_server_info() -> str:
    """Returns information about this MCP server"""
    return """K-Agent MCP Server

Version: 0.1.0
Capabilities:
- Tools: hello, add, api_generate, api_chat, api_list_models
- Prompts: code_review_prompt, debug_prompt
- Resources: code, server-info
- Sampling: LLM sampling support via your API provider
- Roots: File system access
"""

@mcp.custom_route("/", methods=["GET", "OPTIONS"])
async def root_health_check(request: Request) -> Response:
    return Response("MCP Server Running", status_code=200, headers=HEADERS)

# Health check endpoints
# MCP manifest endpoint, negotiation, and tools listing
@mcp.custom_route("/health", methods=["GET", "OPTIONS"])
async def health_check(request: Request) -> Response:
    return Response("MCP Server Running", status_code=200, headers=HEADERS)

# MCP Manifest endpoint as per MCP specification
# Provides metadata about the MCP server
@mcp.custom_route("/.well-known/mcp", methods=["GET", "OPTIONS"])
async def mcp_manifest(request: Request) -> JSONResponse:
    host = request.headers.get("host", "localhost:8889")
    scheme = request.url.scheme or "http"
    base = f"{scheme}://{host}"
    manifest = {
        "name": "kagent-mcp-server",
        "version": "0.1.0",
        "base_url": base,
        "transport": "streamable-http",
        "capabilities": {
            "tools": True,
            "prompts": True,
            "resources": True,
            "sampling": True,
            "roots": True,
            "logging": True
        },
        "endpoints": {
            "manifest": "/.well-known/mcp",
            "health": "/health",
            "ping": "/ping",
            "root": "/",
            "negotiate": "/negotiate",
            "metadata": "/metadata",
            "events": "/mcp",
            "tools": "/tools",
            "tools_execute": "/tools/execute",
            "tools_batch": "/tools/batch",
            "tools_stream": "/tools/stream",
            "tools_history": "/tools/history",
            "prompts": "/prompts",
            "resources": "/resources",
            "sampling": "/sampling",
            "roots": "/roots",
            "api_status": "/api/status",  # TODO: Rename this endpoint to match your API provider
        },
    }
    return JSONResponse(manifest, headers=HEADERS)

# MCP Negotiation endpoint
# Clients use this to negotiate connection parameters
# Supports token-based authentication
@mcp.custom_route("/negotiate", methods=["GET", "POST", "OPTIONS"])
async def negotiate(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    host = request.headers.get("host", "localhost:8889")
    scheme = request.url.scheme or "http"
    mcp_url = f"{scheme}://{host}/mcp"

    # Accept proxy token from query param, X-Proxy-Token header, or Authorization bearer
    token = request.query_params.get("token") or request.headers.get("x-proxy-token") or request.headers.get("X-Proxy-Token")
    auth = request.headers.get("authorization") or request.headers.get("Authorization")
    if not token and auth and auth.lower().startswith("bearer "):
        token = auth.split(None, 1)[1]

    response = {
        "transport": "streamable-http",
        "url": mcp_url,
    }
    
    # Include token in response if provided
    if token:
        response["proxy_token"] = token
    else:
        # When no token is provided, explicitly indicate no auth is required
        # This helps the Inspector understand it can connect without authentication
        response["requiresAuth"] = False

    return JSONResponse(response, headers=HEADERS)

# Tools listing endpoint
# Returns metadata about all registered tools
# Used by inspectors to discover available tools
@mcp.custom_route("/tools", methods=["POST", "GET", "OPTIONS"])
async def tools_list(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)

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

# Tool execution endpoint - Execute a single tool
@mcp.custom_route("/tools/execute", methods=["POST", "OPTIONS"])
async def tool_execute(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    try:
        body = await request.json()
        tool_name = body.get("tool")
        arguments = body.get("arguments", {})
        
        if not tool_name:
            return JSONResponse({
                "success": False,
                "error": "Missing 'tool' field"
            }, headers=HEADERS, status_code=400)
        
        result = await execute_tool(tool_name, arguments)
        return JSONResponse(result, headers=HEADERS)
        
    except Exception as e:
        return JSONResponse({
            "success": False,
            "error": f"Execution failed: {str(e)}"
        }, headers=HEADERS, status_code=500)

# Batch tool execution endpoint
@mcp.custom_route("/tools/batch", methods=["POST", "OPTIONS"])
async def tool_batch_execute(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    try:
        body = await request.json()
        calls = body.get("calls", [])
        
        if not calls:
            return JSONResponse({
                "success": False,
                "error": "Missing 'calls' array"
            }, headers=HEADERS, status_code=400)
        
        results = []
        for call in calls:
            tool_name = call.get("tool")
            arguments = call.get("arguments", {})
            
            if tool_name:
                result = await execute_tool(tool_name, arguments)
                results.append(result)
            else:
                results.append({
                    "success": False,
                    "error": "Missing tool name in call"
                })
        
        return JSONResponse({
            "success": True,
            "results": results,
            "total": len(results)
        }, headers=HEADERS)
        
    except Exception as e:
        return JSONResponse({
            "success": False,
            "error": f"Batch execution failed: {str(e)}"
        }, headers=HEADERS, status_code=500)

# Tool execution history endpoint
@mcp.custom_route("/tools/history", methods=["GET", "OPTIONS"])
async def tool_history(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    limit = int(request.query_params.get("limit", 10))
    
    # Get recent executions
    executions = list(TOOL_EXECUTIONS.values())
    executions.sort(key=lambda x: x.get("timestamp", 0), reverse=True)
    
    return JSONResponse({
        "executions": executions[:limit],
        "total": len(executions)
    }, headers=HEADERS)

# Get specific execution details
@mcp.custom_route("/tools/execution/{execution_id}", methods=["GET", "OPTIONS"])
async def tool_execution_detail(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    execution_id = request.path_params.get("execution_id")
    
    if execution_id in TOOL_EXECUTIONS:
        return JSONResponse(TOOL_EXECUTIONS[execution_id], headers=HEADERS)
    else:
        return JSONResponse({
            "error": f"Execution '{execution_id}' not found"
        }, headers=HEADERS, status_code=404)

# Streaming tool execution
@mcp.custom_route("/tools/stream", methods=["POST", "OPTIONS"])
async def tool_stream_execute(request: Request):
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    try:
        body = await request.json()
        tool_name = body.get("tool")
        arguments = body.get("arguments", {})
        
        async def generate_stream():
            # Send start event
            yield json.dumps({
                "event": "start",
                "tool": tool_name,
                "timestamp": time.time()
            }) + "\n"
            
            # Execute tool
            result = await execute_tool(tool_name, arguments)
            
            # Send result event
            yield json.dumps({
                "event": "result",
                "data": result
            }) + "\n"
            
            # Send end event
            yield json.dumps({
                "event": "end",
                "timestamp": time.time()
            }) + "\n"
        
        return StreamingResponse(
            generate_stream(),
            media_type="application/x-ndjson",
            headers=HEADERS
        )
        
    except Exception as e:
        return JSONResponse({
            "success": False,
            "error": f"Stream execution failed: {str(e)}"
        }, headers=HEADERS, status_code=500)

# Prompts listing endpoint
@mcp.custom_route("/prompts", methods=["POST", "GET", "OPTIONS"])
async def prompts_list(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    prompts = [
        {
            "name": "code_review_prompt",
            "description": "Generate a code review prompt for the given code",
            "arguments": [
                {"name": "code", "description": "The code to review", "required": True},
                {"name": "language", "description": "Programming language", "required": False}
            ]
        },
        {
            "name": "debug_prompt",
            "description": "Generate a debugging prompt",
            "arguments": [
                {"name": "error_message", "description": "The error message", "required": True},
                {"name": "code_context", "description": "Relevant code context", "required": False}
            ]
        }
    ]
    
    return JSONResponse({"prompts": prompts}, headers=HEADERS)

# Resources listing endpoint
@mcp.custom_route("/resources", methods=["POST", "GET", "OPTIONS"])
async def resources_list(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    resources = [
        {
            "uri": "mcp://code",
            "name": "Server Source Code",
            "description": "Returns the source code of this server",
            "mimeType": "text/plain"
        },
        {
            "uri": "mcp://server-info",
            "name": "Server Information",
            "description": "Returns information about this MCP server",
            "mimeType": "text/plain"
        }
    ]
    
    return JSONResponse({"resources": resources}, headers=HEADERS)

# Ping endpoint for connection health checks
@mcp.custom_route("/ping", methods=["POST", "GET", "OPTIONS"])
async def ping(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    return JSONResponse({
        "status": "ok",
        "timestamp": __import__('time').time(),
        "server": "kagent-mcp-server"
    }, headers=HEADERS)

# Sampling endpoint - LLM sampling capability using your API provider
@mcp.custom_route("/sampling", methods=["POST", "OPTIONS"])
async def sampling(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    body = await request.json() if request.method == "POST" else {}
    prompt = body.get("prompt", "")
    max_tokens = body.get("maxTokens", 100)
    model = body.get("model", DEFAULT_MODEL)
    
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            # TODO: Update this request to match your API's completions endpoint
            response = await client.post(
                f"{API_BASE_URL}/completions",  # TODO: Change endpoint as needed
                headers=AUTH_HEADERS,
                json={
                    "model": model,
                    "prompt": prompt,
                    "max_tokens": max_tokens,
                    # TODO: Add any other required parameters for your API
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                # TODO: Update this to match your API's response format
                return JSONResponse({
                    "completion": result.get("choices", [{}])[0].get("text", ""),
                    "stopReason": "endTurn" if result.get("choices", [{}])[0].get("finish_reason") == "stop" else "length",
                    "model": model,
                    "context": result.get("usage", {})  # TODO: Adjust based on your API's usage format
                }, headers=HEADERS)
            else:
                return JSONResponse({
                    "error": f"API error: {response.status_code}",
                    "completion": "",
                    "stopReason": "error",
                    "model": model
                }, headers=HEADERS, status_code=500)
    except Exception as e:
        return JSONResponse({
            "error": f"Failed to connect to API: {str(e)}",
            "completion": "",
            "stopReason": "error",
            "model": model
        }, headers=HEADERS, status_code=500)

# Roots endpoint - File system roots
@mcp.custom_route("/roots", methods=["POST", "GET", "OPTIONS"])
async def roots_list(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    import os
    roots = [
        {
            "uri": f"file://{os.getcwd()}",
            "name": "Current Directory"
        }
    ]
    
    return JSONResponse({"roots": roots}, headers=HEADERS)

# API status endpoint - Check connection and get info about your API provider
@mcp.custom_route("/api/status", methods=["GET", "OPTIONS"])  # TODO: Rename this route to match your API provider
async def api_status(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            # TODO: Update this to check your API's health/status endpoint
            # This could be a models endpoint, health check, or any endpoint that confirms connectivity
            response = await client.get(
                f"{API_BASE_URL}/models",  # TODO: Change to appropriate health/status endpoint
                headers=AUTH_HEADERS
            )
            
            if response.status_code == 200:
                data = response.json()
                # TODO: Update this to parse your API's model list or status response
                models = data.get("data", [])
                return JSONResponse({
                    "status": "connected",
                    "url": API_BASE_URL,
                    "models_count": len(models),
                    "models": [{
                        "name": m.get("id"),  # TODO: Adjust based on your API's model object structure
                        "size": m.get("size", 0),
                        "modified": m.get("modified_at")
                    } for m in models],
                    "default_model": DEFAULT_MODEL
                }, headers=HEADERS)
            else:
                return JSONResponse({
                    "status": "error",
                    "url": API_BASE_URL,
                    "error": f"HTTP {response.status_code}"
                }, headers=HEADERS)
    except Exception as e:
        return JSONResponse({
            "status": "disconnected",
            "url": API_BASE_URL,
            "error": str(e)
        }, headers=HEADERS)

# Server metadata endpoint
@mcp.custom_route("/metadata", methods=["GET", "OPTIONS"])
async def metadata(request: Request) -> JSONResponse:
    # Handle OPTIONS preflight
    if request.method == "OPTIONS":
        return JSONResponse({}, headers=HEADERS)
    
    return JSONResponse({
        "serverInfo": {
            "name": "kagent-mcp-server",
            "version": "0.1.0",
            "protocolVersion": "2024-11-05"
        },
        "capabilities": {
            "tools": {"listChanged": False},
            "prompts": {"listChanged": False},
            "resources": {"subscribe": False, "listChanged": False},
            "logging": {},
            "sampling": {},
            "roots": {"listChanged": False}
        }
    }, headers=HEADERS)

# Add CORS middleware to handle preflight requests for all endpoints
@mcp.custom_route("/mcp", methods=["OPTIONS"])
async def mcp_options(request: Request) -> Response:
    """Handle CORS preflight for the MCP endpoint"""
    return Response(status_code=200, headers=HEADERS)

# Main entry point to run the MCP server
def main():
    # Start the MCP server with streamable-http transport
    # Mounted at /mcp path
    # This will listen on port 8889 as configured above
    mcp.run(transport="streamable-http", mount_path="/mcp")

if __name__ == "__main__":
    main()