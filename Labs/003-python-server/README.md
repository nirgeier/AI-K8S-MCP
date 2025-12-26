# Lab 003 - Python MCP Server with FastMCP

- In this lab, you'll build MCP servers using Python and the `FastMCP` framework. 
- `FastMCP` is a high-level Python framework that simplifies the creating of MCP servers with minimal boilerplate code. 
- You'll learn how to define tools using decorators, handle parameters, and integrate with Python's ecosystem.

**What you'll learn:**

- Building MCP servers with Python and `FastMCP`
- Using decorators to define tools
- Working with tool parameters and validation
- Testing Python MCP servers
- Best practices for Python MCP development

**Estimated time:** 15-20 minutes

---

## Pre-Requirements

- Completed [Lab 000 - K-Agent Labs Setup](../000-kagent-labs-setup/) and [Lab 001 - MCP Basics](../001-mcp-basics/)
- K-Agent labs environment running
- Basic Python knowledge

---

## 01. What is FastMCP?

`FastMCP` is a Python framework that makes it easy to build MCP servers. It provides:

- **Simple Decorator API**: Define tools with `@mcp.tool()` decorators
- **Automatic Schema Generation**: Generates JSON schemas from Python type hints
- **Built-in Validation**: Validates inputs based on type annotations
- **Minimal Boilerplate**: Focus on tool logic, not protocol details
- **Python Ecosystem**: Leverage any Python library in your tools

### FastMCP vs MCP SDK

| Feature   | FastMCP                              | MCP SDK (TypeScript)        |
|-----------|--------------------------------------|-----------------------------|
| Language  | Python                               | TypeScript/JavaScript       |
| API Style | Decorator-based                      | Class-based                 |
| Typing    | Type hints                           | TypeScript types            |
| Best for  | Python developers, rapid prototyping | Type safety, large projects |

---

## 02. FastMCP Server Structure

A basic FastMCP server looks like this:

```python
#!/usr/bin/env python3
from fastmcp import FastMCP

# Create server instance
mcp = FastMCP("My Server Name")

# Define tools using decorators
@mcp.tool()
def my_tool(param: str) -> str:
    """Tool description here"""
    return f"Result: {param}"

# Run the server
if __name__ == "__main__":
    mcp.run()
```

**Key Components:**

1. **Import FastMCP**: `from fastmcp import FastMCP`
2. **Create Server**: `mcp = FastMCP("Server Name")`
3. **Define Tools**: Use `@mcp.tool()` decorator
4. **Run Server**: Call `mcp.run()` to start

---

## 03. Tool Definition with Decorators

`FastMCP` uses Python decorators to define tools. The framework automatically:

- Extracts the tool name from the function name
- Uses the docstring as the tool description
- Generates input schema from type hints
- Validates inputs against the schema

**Example:**

```python
@mcp.tool()
def greet(name: str, greeting: str = "Hello") -> str:
    """Greet a person with a custom greeting"""
    return f"{greeting}, {name}!"
```

This creates a tool with:

- **Name**: `greet`
- **Description**: "Greet a person with a custom greeting"
- **Parameters**: 
    - `name` (string, required)
    - `greeting` (string, optional, default="Hello")
- **Return Type**: string

---

## 04. Type Hints and Validation

`FastMCP` uses Python's type hints for automatic validation:

```python
from typing import List, Optional

@mcp.tool()
def calculate_average(numbers: List[float]) -> float:
    """Calculate the average of a list of numbers"""
    if not numbers:
        return 0.0
    return sum(numbers) / len(numbers)

@mcp.tool()
def find_user(user_id: int, include_details: Optional[bool] = False) -> str:
    """Find a user by ID"""
    details = " with details" if include_details else ""
    return f"User {user_id}{details}"
```

**Supported Types:**

- Basic: `int`, `float`, `str`, `bool`
- Collections: `List`, `Dict`, `Tuple`
- Optional: `Optional[T]` or `T | None`
- Complex: Custom data classes

---

## 05. Hands-on Exercise

### Exercise 1: Create a Simple Calculator Server

Let's build a calculator MCP server with multiple tools.

```bash
# Connect to container
docker exec -it kagent-controller bash

# Create a new Python file for our calculator server
cat > /labs-scripts/calculator_server.py << 'EOF'
#!/usr/bin/env python3
from fastmcp import FastMCP

# Create the calculator MCP server
mcp = FastMCP("Calculator Server")

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
EOF

# Make it executable
chmod +x /labs-scripts/calculator_server.py
```

---

### Exercise 2: Test with MCP Inspector

Now let's test our calculator server:

```bash
# Inside the container, start MCP Inspector with our calculator server
npx @modelcontextprotocol/inspector python3 /labs-scripts/calculator_server.py
```

!!! warning "Port Already in Use?"
    If you see `❌ Proxy Server PORT IS IN USE at port 6277 ❌`, there's already an MCP Inspector running. 
    
    **Solution: Kill the existing process**
    ```bash
    # Find and kill any running inspector processes
    pkill -f "inspector" || true
    
    # Wait a moment for the port to be released
    sleep 2
    
    # Now try again
    npx @modelcontextprotocol/inspector python3 /labs-scripts/calculator_server.py
    ```
    
    **Alternative: Kill specific port**
    ```bash
    # Kill process on port 6277
    lsof -ti:6277 | xargs kill -9 2>/dev/null || true
    
    # Also check port 6274 (sometimes used)
    lsof -ti:6274 | xargs kill -9 2>/dev/null || true
    
    # Try again
    npx @modelcontextprotocol/inspector python3 /labs-scripts/calculator_server.py
    ```

!!! info "Testing Steps"
    1. Copy the authentication URL from the terminal
    2. Open it in your browser
    3. Verify transport is set to **stdio**
    4. Command should show: `python3`
    5. Argument should show: `/labs-scripts/calculator_server.py`
    6. Click **Connect**
    7. Go to **Tools** tab and click **List Tools**
    8. You should see 5 tools: add, subtract, multiply, divide, power

**Test the tools:**

1. **Test Add Tool**:
      - Click `add`
      - Enter `a`: `15`
      - Enter `b`: `7`
      - Click **Run Tool**
      - Expected: `22.0`

2. **Test Divide Tool**:
      - Click `divide`
      - Enter `a`: `100`
      - Enter `b`: `4`
      - Click **Run Tool**
      - Expected: "The result is 25.0"

3. **Test Power Tool**:
      - Click `power`
      - Enter `base`: `2`
      - Enter `exponent`: `8`
      - Click **Run Tool**
      - Expected: `256.0`

4. **Test Error Handling**:
      - Click `divide`
      - Enter `a`: `10`
      - Enter `b`: `0`
      - Click **Run Tool**
      - Expected: "Error: Division by zero"

---

### Exercise 3: Build a Text Processing Server

Create a more advanced server with string manipulation tools:

```bash
# Inside the container
cat > /labs-scripts/text_server.py << 'EOF'
#!/usr/bin/env python3
from fastmcp import FastMCP
from typing import List

mcp = FastMCP("Text Processing Server")

@mcp.tool()
def to_uppercase(text: str) -> str:
    """Convert text to uppercase"""
    return text.upper()

@mcp.tool()
def to_lowercase(text: str) -> str:
    """Convert text to lowercase"""
    return text.lower()

@mcp.tool()
def reverse_text(text: str) -> str:
    """Reverse the input text"""
    return text[::-1]

@mcp.tool()
def count_words(text: str) -> int:
    """Count the number of words in text"""
    return len(text.split())

@mcp.tool()
def count_characters(text: str, include_spaces: bool = True) -> int:
    """Count characters in text, optionally excluding spaces"""
    if include_spaces:
        return len(text)
    return len(text.replace(" ", ""))

@mcp.tool()
def find_substring(text: str, substring: str) -> str:
    """Find if substring exists in text and return its position"""
    index = text.find(substring)
    if index == -1:
        return f"Substring '{substring}' not found in text"
    return f"Substring '{substring}' found at position {index}"

@mcp.tool()
def split_by_delimiter(text: str, delimiter: str = ",") -> List[str]:
    """Split text by a delimiter"""
    return text.split(delimiter)

if __name__ == "__main__":
    mcp.run()
EOF

chmod +x /labs-scripts/text_server.py
```

**Test the text processing server:**

```bash
# Start MCP Inspector
npx @modelcontextprotocol/inspector python3 /labs-scripts/text_server.py
```


!!! info "Testing Steps"
    1. Copy the authentication URL from the terminal
    2. Open it in your browser
    3. Verify transport is set to **stdio**
    4. Command should show: `python3`
    5. Argument should show: `/labs-scripts/text_server.py`
    6. Click **Connect**
    7. Go to **Tools** tab and click **List Tools**
    8. You should see 7 tools: to_uppercase, to_lowercase, reverse_text, count_words, count_characters, find_substring, split_by_delimiter


Try these tests:

1. **to_uppercase**:
      - Input: "hello world"
      - Expected: "HELLO WORLD"

2. **count_words**:
      - Input: "The quick brown fox jumps"
      - Expected: `5`

3. **find_substring**:
      - text: "Python MCP Server"
      - substring: "MCP"
      - Expected: "Substring 'MCP' found at position 7"

4. **split_by_delimiter**:
      - text: "apple,banana,orange"
      - delimiter: ","
      - Expected: `["apple", "banana", "orange"]`

---

### Exercise 4: Command-Line Testing

Test tools programmatically using Python:

```bash
# Inside the container, create a test script
cat > /labs-scripts/test_calculator.py << 'EOF'
#!/usr/bin/env python3
import subprocess
import json
import time

def test_mcp_tool(server_path, tool_name, arguments):
    """Test an MCP tool by spawning the server and sending requests"""
    
    # Start the server process
    process = subprocess.Popen(
        ['python3', server_path],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )
    
    time.sleep(0.5)  # Give server time to start
    
    # Create the tool call request
    request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": tool_name,
            "arguments": arguments
        }
    }
    
    # Send request
    process.stdin.write(json.dumps(request) + "\n")
    process.stdin.flush()
    
    # Read response
    time.sleep(0.5)
    response_line = process.stdout.readline()
    
    # Clean up
    process.terminate()
    process.wait(timeout=2)
    
    try:
        response = json.loads(response_line)
        return response
    except:
        return {"error": "Failed to parse response", "raw": response_line}

# Test calculator operations
print("Testing Calculator Server...")
print("-" * 50)

# Test addition
result = test_mcp_tool('/labs-scripts/calculator_server.py', 'add', {'a': 10, 'b': 20})
print(f"add(10, 20) = {result}")

# Test division
result = test_mcp_tool('/labs-scripts/calculator_server.py', 'divide', {'a': 100, 'b': 5})
print(f"divide(100, 5) = {result}")

# Test power
result = test_mcp_tool('/labs-scripts/calculator_server.py', 'power', {'base': 3, 'exponent': 4})
print(f"power(3, 4) = {result}")

print("-" * 50)
print("Tests complete!")
EOF

chmod +x /labs-scripts/test_calculator.py

# Run the tests
python3 /labs-scripts/test_calculator.py
```

---

## 06. Advanced Features

### Error Handling

Add proper error handling to your tools:

```python
@mcp.tool()
def safe_divide(a: float, b: float) -> str:
    """Safely divide two numbers with error handling"""
    try:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        result = a / b
        return f"Result: {result}"
    except Exception as e:
        return f"Error: {str(e)}"
```

### Using Python Libraries

`FastMCP` integrates seamlessly with Python's ecosystem:

```python
import math
from datetime import datetime

@mcp.tool()
def calculate_sqrt(number: float) -> float:
    """Calculate square root using math library"""
    return math.sqrt(number)

@mcp.tool()
def get_current_time() -> str:
    """Get current timestamp"""
    return datetime.now().isoformat()
```

### Complex Return Types

Return structured data:

```python
from typing import Dict, List

@mcp.tool()
def analyze_text(text: str) -> Dict[str, int]:
    """Analyze text and return statistics"""
    return {
        "characters": len(text),
        "words": len(text.split()),
        "lines": text.count('\n') + 1,
        "vowels": sum(1 for c in text.lower() if c in 'aeiou')
    }
```


---

## 07. Best Practices

!!! tip "FastMCP Best Practices"
    **1. Use Type Hints**
    ```python
    # Good
    @mcp.tool()
    def process(data: str, count: int) -> List[str]:
        pass
    
    # Avoid (no type hints)
    @mcp.tool()
    def process(data, count):
        pass
    ```
    
    **2. Write Clear Docstrings**
    ```python
    # Good
    @mcp.tool()
    def calculate_tax(amount: float, rate: float) -> float:
        """Calculate tax on an amount using the given rate.
        
        Args:
            amount: The base amount
            rate: Tax rate as a decimal (e.g., 0.15 for 15%)
        """
        return amount * rate
    ```
    
    **3. Handle Errors Gracefully**
    ```python
    @mcp.tool()
    def safe_operation(value: int) -> str:
        """Perform operation with error handling"""
        try:
            result = 100 / value
            return f"Success: {result}"
        except ZeroDivisionError:
            return "Error: Cannot divide by zero"
        except Exception as e:
            return f"Error: {str(e)}"
    ```
    
    **4. Validate Inputs**
    ```python
    @mcp.tool()
    def process_positive(number: int) -> str:
        """Process only positive numbers"""
        if number <= 0:
            return "Error: Number must be positive"
        return f"Processing {number}"
    ```
    
    **5. Use Meaningful Names**
    ```python
    # Good
    @mcp.tool()
    def calculate_monthly_payment(principal: float, rate: float, months: int) -> float:
        pass
    
    # Avoid
    @mcp.tool()
    def calc(p: float, r: float, m: int) -> float:
        pass
    ```

---

## 08. Key Takeaways

!!! success "What You Learned"
    - ✓ Building MCP servers with Python and FastMCP
    - ✓ Using `@mcp.tool()` decorator for tool definition
    - ✓ Leveraging type hints for automatic schema generation
    - ✓ Testing Python MCP servers with MCP Inspector
    - ✓ Implementing error handling and validation
    - ✓ Integrating Python libraries with MCP tools
    - ✓ Command-line testing with subprocess

!!! info "FastMCP Advantages"
    - **Rapid Development**: Minimal boilerplate, quick prototyping
    - **Python Ecosystem**: Access to thousands of Python libraries
    - **Type Safety**: Automatic validation from type hints
    - **Easy Testing**: Simple to test with Python scripts
    - **Readable Code**: Decorator pattern is clean and intuitive

---

## 09. Additional Resources

- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
- [Python Type Hints Guide](https://docs.python.org/3/library/typing.html)
- [MCP Specification](https://modelcontextprotocol.io/docs)
- [Python Decorators Tutorial](https://realpython.com/primer-on-python-decorators/)

---

## 10. Next Steps

Now that you can build Python MCP servers with FastMCP, you'll learn how to create TypeScript-based MCP servers for type-safe, production-grade implementations.
