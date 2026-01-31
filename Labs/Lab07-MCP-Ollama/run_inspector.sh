#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define ports used by MCP Inspector
PORTS="6274 6277"

echo "🧹 Cleaning up ports $PORTS..."
# Find and kill processes using these ports
lsof -t -i:6274 -i:6277 | xargs kill -9 2>/dev/null || true

echo "📂 Changing to directory: $SCRIPT_DIR"
cd "$SCRIPT_DIR"

echo "🚀 Starting MCP Inspector with mcp_ollama.py..."
# Run the inspector which internally runs the python server
npx @modelcontextprotocol/inspector python3 mcp_ollama.py
