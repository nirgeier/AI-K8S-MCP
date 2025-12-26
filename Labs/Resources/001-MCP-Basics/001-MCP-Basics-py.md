### MCP Basics with Python
```python
from mcp.server.fastmcp import FastMCP

# Create server instance
mcp = FastMCP("kagent-mcp-server")

@mcp.tool()
def hello(name: str) -> str:
    """Returns a friendly greeting message"""
    return f"Hello, {name}! Welcome to K-Agent Labs."

@mcp.tool()
def add(a: float, b: float) -> str:
    """Adds two numbers together"""
    result = a + b
    return f"The sum of {a} and {b} is {result}"

def main():
    # Initialize and run the server
    mcp.run()

if __name__ == "__main__":
    main()
```
