#!/bin/bash

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR" # Run from the same directory
# Define the server script path
SERVER_SCRIPT="${SCRIPT_DIR}/step11-main.md"
TEMP_PY="${SCRIPT_DIR}/temp_server.py"

# Navigate to the project root directory
cd "$PROJECT_ROOT"

# Check if the virtual environment exists
if [ -d ".venv" ]; then
  echo "Activating virtual environment..."
  source .venv/bin/activate
else
  echo "Creating virtual environment..."
  python3 -m venv .venv
  source .venv/bin/activate
  echo "Installing requirements..."
  pip install -r requirements.txt
fi

if [ ! -f "$SERVER_SCRIPT" ]; then
  echo "Error: Server file $SERVER_SCRIPT not found"
  exit 1
fi

echo "Extracting server code from Markdown..."
python3 -c 'import sys; c=sys.stdin.read(); s=c.find("```python"); e=c.rfind("```"); print(c[s+9:e] if s!=-1 and e!=-1 else c)' <"$SERVER_SCRIPT" >"$TEMP_PY"

echo "Starting MCP Inspector with server..."
echo "URL should open in your browser shortly..."
echo "Press Ctrl+C to stop."

# Use the python executable from the virtual environment
PYTHON_EXEC="$PROJECT_ROOT/.venv/bin/python3"

# Run the MCP Inspector with the temp file
# Clean up temp file on exit
trap 'rm -f "$TEMP_PY"' EXIT

npx @modelcontextprotocol/inspector "$PYTHON_EXEC" "$TEMP_PY"
