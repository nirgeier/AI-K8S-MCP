#!/bin/bash

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Navigate to the project root directory
cd "$PROJECT_ROOT"

# Check if the virtual environment exists
if [ -d ".venv" ]; then
  echo "Activating virtual environment..."
  source .venv/bin/activate
else
  echo "Error: Virtual environment not found at $PROJECT_ROOT/.venv"
  echo "Please set up the environment first."
  exit 1
fi

# Define the server script path
SERVER_SCRIPT="demo/step11-main.py"

if [ ! -f "$SERVER_SCRIPT" ]; then
  echo "Error: Server script not found at $SERVER_SCRIPT"
  exit 1
fi

echo "Starting MCP Inspector with server: $SERVER_SCRIPT"
echo "URL should open in your browser shortly..."
echo "Press Ctrl+C to stop."

# Run the MCP Inspector
npx @modelcontextprotocol/inspector python3 "$SERVER_SCRIPT"
