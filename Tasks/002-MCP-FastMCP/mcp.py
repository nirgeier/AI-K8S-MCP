from fastmcp import FastMCP

# Create the calculator MCP server
mcp = FastMCP("Calculator Server", port=9000)

@mcp.tool()
def add(a: float, b: float) -> float:
    """Add two numbers together"""
    return a + b

@mcp.tool()
def subtract(a: float, b: float) -> float:
    """Subtract b from a"""
    return a - b

@mcp.tool()
def multiply(a: float, b: float) -> float:
    """Multiply two numbers"""
    return a * b

@mcp.tool()
def divide(a: float, b: float) -> str:
    """Divide a by b"""
    if b == 0:
        return "Error: Division by zero"
    result = a / b
    return f"The result is {result}"

@mcp.tool()
def power(base: float, exponent: float) -> float:
    """Raise base to the power of exponent"""
    return base ** exponent

if __name__ == "__main__":
    mcp.run()
