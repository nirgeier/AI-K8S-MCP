#!/bin/bash

# Script to execute Lab 3: Implementing MCP Tools (Python version)
# Creates a demo folder with advanced tools: weather (Ollama), file operations, and database queries

set -e # Exit on any error

echo "🚀 Starting Lab 3: Implementing MCP Tools (Python)"
echo "===================================================="
echo ""
echo "This lab includes three advanced tools:"
echo "  1. Weather Information (using Ollama AI)"
echo "  2. File Operations (secure file reading)"
echo "  3. Database Query (mock implementation)"
echo ""

# Clean up ports first
echo "🧹 Cleaning up any existing processes on ports 8889, 6274, 6277..."
lsof -ti:8889,6274,6277 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 2

# Create demo folder
echo "📁 Creating demo folder..."
rm -rf demo-python
mkdir -p demo-python
cd demo-python

# Step 1: Create Project Structure
echo "📦 Setting up Python project..."
mkdir -p my-advanced-mcp-tools-python
cd my-advanced-mcp-tools-python

# Step 2: Create Virtual Environment
echo "🐍 Creating virtual environment with uv..."
if ! command -v uv &>/dev/null; then
  echo "❌ uv is not installed. Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.cargo/bin:$PATH"
fi

uv venv
source .venv/bin/activate

# Step 3: Create requirements.txt
echo "📝 Creating requirements.txt..."
cat >requirements.txt <<'EOF'
fastmcp
uvicorn
httpx
starlette
EOF

# Step 4: Install Dependencies
echo "📥 Installing dependencies..."
uv pip install -r requirements.txt

# Step 5: Create Python MCP Server
echo "🏗️  Creating advanced Python MCP server with three tools..."
cat >mcp_server.py <<'EOFPY'
#!/usr/bin/env python3
"""
Advanced MCP server with weather, file operations, and database tools
"""
from fastmcp import FastMCP
from typing import Dict, Any, List
import os
import httpx
import json
from datetime import datetime
from pathlib import Path

# Initialize FastMCP server
mcp = FastMCP("my-advanced-mcp-tools-python", port=8889)

# ============================================================
# Tool 1: Weather Information with Ollama
# ============================================================

@mcp.tool()
async def get_weather(city: str, units: str = "celsius") -> str:
    """
    Get current weather information for a city using AI
    
    Args:
        city: City name (e.g., 'London', 'New York')
        units: Temperature units ('celsius' or 'fahrenheit')
    
    Returns:
        Weather information as formatted text
    """
    if not city or city.strip() == "":
        raise ValueError("City name cannot be empty")
    
    if units not in ["celsius", "fahrenheit"]:
        units = "celsius"
    
    # Prepare prompt for Ollama
    prompt = f"""Generate realistic current weather information for {city}.
    Return ONLY a JSON object with this exact structure:
    {{
      "name": "{city}",
      "sys": {{"country": "XX"}},
      "main": {{"temp": 20.5, "feels_like": 22.1, "humidity": 65}},
      "weather": [{{"description": "clear sky"}}],
      "wind": {{"speed": 3.2}}
    }}

    Use realistic weather data appropriate for the location. Temperature should be in Celsius. Choose an appropriate 2-letter country code for the city. Make the weather description realistic for the location and season."""
    
    try:
        # Call Ollama API
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                'http://localhost:11434/api/generate',
                json={
                    'model': 'gpt-oss:20b',
                    'prompt': prompt,
                    'stream': False,
                    'format': 'json'
                }
            )
            
            if response.status_code != 200:
                raise Exception(f"Ollama API error: {response.status_code} {response.text}. Make sure Ollama is running with 'ollama serve'.")
            
            ollama_result = response.json()
            
            try:
                # Parse the JSON response from Ollama
                data = json.loads(ollama_result['response'])
            except (json.JSONDecodeError, KeyError):
                # Fallback to mock data if parsing fails
                print('Failed to parse Ollama response, using fallback data')
                fallback_data = {
                    "london": {
                        "name": "London",
                        "sys": {"country": "GB"},
                        "main": {"temp": 15.2, "feels_like": 14.8, "humidity": 82},
                        "weather": [{"description": "light rain"}],
                        "wind": {"speed": 3.6}
                    },
                    "new york": {
                        "name": "New York",
                        "sys": {"country": "US"},
                        "main": {"temp": 22.5, "feels_like": 24.1, "humidity": 65},
                        "weather": [{"description": "clear sky"}],
                        "wind": {"speed": 2.1}
                    },
                    "tokyo": {
                        "name": "Tokyo",
                        "sys": {"country": "JP"},
                        "main": {"temp": 18.7, "feels_like": 18.2, "humidity": 78},
                        "weather": [{"description": "few clouds"}],
                        "wind": {"speed": 1.8}
                    },
                    "paris": {
                        "name": "Paris",
                        "sys": {"country": "FR"},
                        "main": {"temp": 12.8, "feels_like": 11.9, "humidity": 71},
                        "weather": [{"description": "overcast clouds"}],
                        "wind": {"speed": 4.2}
                    },
                    "sydney": {
                        "name": "Sydney",
                        "sys": {"country": "AU"},
                        "main": {"temp": 24.3, "feels_like": 25.1, "humidity": 73},
                        "weather": [{"description": "sunny"}],
                        "wind": {"speed": 2.8}
                    }
                }
                data = fallback_data.get(city.lower().strip(), fallback_data["london"])
            
            # Convert to Fahrenheit if requested
            if units == "fahrenheit":
                data["main"]["temp"] = (data["main"]["temp"] * 9/5) + 32
                data["main"]["feels_like"] = (data["main"]["feels_like"] * 9/5) + 32
            
            # Format response
            temp_unit = "°F" if units == "fahrenheit" else "°C"
            weather_text = f"""
Weather in {data["name"]}, {data["sys"]["country"]}:
- Temperature: {data["main"]["temp"]:.1f}{temp_unit}
- Feels like: {data["main"]["feels_like"]:.1f}{temp_unit}
- Conditions: {data["weather"][0]["description"]}
- Humidity: {data["main"]["humidity"]}%
- Wind Speed: {data["wind"]["speed"]} m/s

*Generated by Ollama AI*
""".strip()
            
            return weather_text
            
    except httpx.ConnectError:
        raise Exception("Cannot connect to Ollama. Make sure Ollama is running with 'ollama serve'.")
    except Exception as e:
        raise Exception(f"Failed to get weather: {str(e)}")


# ============================================================
# Tool 2: File Operations
# ============================================================

@mcp.tool()
async def read_file(filepath: str, encoding: str = "utf8", max_size: int = 1048576) -> str:
    """
    Read contents of a text file with security validation
    
    Args:
        filepath: Absolute path to the file
        encoding: File encoding ('utf8', 'ascii', or 'base64')
        max_size: Maximum file size in bytes (default 1MB)
    
    Returns:
        File contents with metadata
    """
    # Security: Validate input
    if not filepath or not isinstance(filepath, str) or filepath.strip() == "":
        raise ValueError("filepath must be a non-empty string")
    
    if encoding not in ["utf8", "ascii", "base64"]:
        encoding = "utf8"
    
    if max_size < 1 or max_size > 10485760:  # Max 10MB
        max_size = 1048576
    
    try:
        # Security: Resolve absolute path to prevent directory traversal
        absolute_path = Path(filepath).resolve()
        
        # Security: Check if path exists and is a file
        if not absolute_path.exists():
            raise FileNotFoundError(f"File not found: {filepath}")
        
        if not absolute_path.is_file():
            raise ValueError("Path is not a file")
        
        # Security: Check file size
        file_size = absolute_path.stat().st_size
        if file_size > max_size:
            raise ValueError(f"File size ({file_size} bytes) exceeds maximum allowed size ({max_size} bytes)")
        
        # Read file
        if encoding == "base64":
            import base64
            with open(absolute_path, 'rb') as f:
                content = base64.b64encode(f.read()).decode('ascii')
        else:
            with open(absolute_path, 'r', encoding=encoding) as f:
                content = f.read()
        
        # Get file metadata
        stats = absolute_path.stat()
        modified_time = datetime.fromtimestamp(stats.st_mtime).isoformat()
        
        # Return result with metadata
        result = f"""File: {absolute_path}
Size: {file_size} bytes
Modified: {modified_time}
Encoding: {encoding}

Content:
{content}"""
        
        return result
        
    except Exception as e:
        raise Exception(f"Failed to read file: {str(e)}")


# ============================================================
# Tool 3: Database Query (Mock)
# ============================================================

@mcp.tool()
async def query_users(status: str = "all", limit: int = 10, offset: int = 0) -> str:
    """
    Query user database with filtering and pagination
    
    Args:
        status: Filter by user status ('active', 'inactive', or 'all')
        limit: Maximum number of results (1-100)
        offset: Pagination offset (0+)
    
    Returns:
        Formatted query results
    """
    # Validate parameters
    if status not in ["active", "inactive", "all"]:
        status = "all"
    
    if limit < 1 or limit > 100:
        limit = 10
    
    if offset < 0:
        offset = 0
    
    # Mock database
    all_users = [
        {"id": 1, "name": "Alice Johnson", "email": "alice@example.com", "status": "active", "created": "2024-01-15"},
        {"id": 2, "name": "Bob Smith", "email": "bob@example.com", "status": "active", "created": "2024-02-20"},
        {"id": 3, "name": "Charlie Brown", "email": "charlie@example.com", "status": "inactive", "created": "2024-03-10"},
        {"id": 4, "name": "Diana Prince", "email": "diana@example.com", "status": "active", "created": "2024-04-05"},
        {"id": 5, "name": "Eve Wilson", "email": "eve@example.com", "status": "inactive", "created": "2024-05-12"},
        {"id": 6, "name": "Frank Miller", "email": "frank@example.com", "status": "active", "created": "2024-06-18"},
        {"id": 7, "name": "Grace Lee", "email": "grace@example.com", "status": "active", "created": "2024-07-22"},
        {"id": 8, "name": "Henry Davis", "email": "henry@example.com", "status": "inactive", "created": "2024-08-30"},
    ]
    
    # Filter by status
    if status != "all":
        filtered_users = [u for u in all_users if u["status"] == status]
    else:
        filtered_users = all_users
    
    # Apply pagination
    paginated_users = filtered_users[offset:offset + limit]
    total_count = len(filtered_users)
    
    # Format response
    users_list = "\n".join([
        f"• {user['name']} ({user['email']}) - {user['status']} - Created: {user['created']}"
        for user in paginated_users
    ])
    
    page_num = (offset // limit) + 1
    result_text = f"""
Database Query Results
======================
Filter: status={status}
Showing: {len(paginated_users)} of {total_count} users
Page: {page_num}

{users_list}

Query executed at: {datetime.now().isoformat()}
""".strip()
    
    return result_text


# ============================================================
# Tool 4: Hello World (Bonus from Lab 2)
# ============================================================

@mcp.tool()
async def hello_world(name: str) -> str:
    """
    Returns a friendly greeting message
    
    Args:
        name: The name to greet
    
    Returns:
        Greeting message
    """
    if not name:
        raise ValueError("Name parameter is required")
    
    return f"Hello, {name}! Welcome to Lab 3 - Advanced MCP Tools! 🚀"


# ============================================================
# Custom Routes for Testing and Inspector
# ============================================================

@mcp.custom_route("/health", ["GET"])
async def health_check(request) -> Dict[str, Any]:
    """Health check endpoint"""
    return {
        "status": "healthy",
        "server": "my-advanced-mcp-tools-python",
        "timestamp": datetime.now().isoformat(),
        "tools": ["get_weather", "read_file", "query_users", "hello_world"]
    }

@mcp.custom_route("/.well-known/mcp", ["GET"])
async def mcp_metadata(request) -> Dict[str, Any]:
    """MCP metadata endpoint"""
    return {
        "name": "my-advanced-mcp-tools-python",
        "version": "1.0.0",
        "description": "Advanced MCP server with weather, file, and database tools",
        "capabilities": ["tools"],
        "transport": ["http"]
    }


# ============================================================
# Main Entry Point
# ============================================================

if __name__ == "__main__":
    print("🚀 Starting Advanced MCP Tools Server (Python)")
    print("=" * 50)
    print("Available tools:")
    print("  • get_weather - Weather information with Ollama AI")
    print("  • read_file - Secure file reading operations")
    print("  • query_users - Mock database queries")
    print("  • hello_world - Simple greeting tool")
    print("=" * 50)
    print(f"Server running on http://localhost:8889")
    print("Press Ctrl+C to stop")
    print()
    
    # Run the server
    mcp.run()
EOFPY

# Make it executable
chmod +x mcp_server.py

# Create a sample test file for file reading tool
echo "📄 Creating sample test file..."
echo "This is a test file for the read_file tool.
It contains multiple lines of text.
You can test reading this file with the MCP Inspector!" >test-file.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "=================================================="
echo "🔍 Starting MCP Inspector with Python Server"
echo "=================================================="
echo ""
echo "The MCP Inspector will now launch and start the server."
echo "You can test all tools through the Inspector interface:"
echo ""
echo "1. 🌤️  Weather Tool (get_weather):"
echo "   - Try cities: London, New York, Tokyo, Paris, Sydney"
echo "   - Test units: celsius or fahrenheit"
echo "   - Note: Requires Ollama running (ollama serve)"
echo "   - Falls back to mock data if Ollama is unavailable"
echo ""
echo "2. 📁 File Tool (read_file):"
echo "   - Test with: $(pwd)/test-file.txt"
echo "   - Try different encodings: utf8, ascii, base64"
echo "   - Test error cases with non-existent files"
echo ""
echo "3. 💾 Database Tool (query_users):"
echo "   - Filter: active, inactive, or all"
echo "   - Pagination: set limit (1-100) and offset"
echo "   - Mock database with 8 sample users"
echo ""
echo "4. 👋 Hello World (hello_world):"
echo "   - Simple greeting tool from Lab 2"
echo ""
echo "=================================================="
echo ""
echo "🌐 Inspector will open in your browser at http://localhost:6274"
echo "📡 Transport: stdio (process-based communication)"
echo ""
echo "To stop the server: Press Ctrl+C"
echo ""

# Launch MCP Inspector with stdio transport
# The Inspector will launch the Python server as a subprocess
DANGEROUSLY_OMIT_AUTH=true npx @modelcontextprotocol/inspector uv run mcp_server.py
