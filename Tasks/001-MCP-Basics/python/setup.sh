#!/bin/bash

# Exit on error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Initializing MCP Basics Demo in $SCRIPT_DIR..."

# Check for uv
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed. Please install uv first (curl -LsSf https://astral.sh/uv/install.sh | sh)."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    uv venv
else
    echo "Virtual environment already exists."
fi

# Activate virtual environment
source .venv/bin/activate

# Install requirements
if [ -f "requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    uv pip install -r requirements.txt
else
    echo "Warning: requirements.txt not found. Installing mcp directly..."
    uv pip install mcp uvicorn
fi

echo "Setup complete."

# Kill any existing server or inspector processes (ports commonly used)
for P in 8888 6274 6277; do
    lsof -ti:$P | xargs -r kill -9 || true
done

# Start MCP Server in background
echo "Starting MCP Server (background)..."
uv run server.py &
SERVER_PID=$!
echo $SERVER_PID > .server.pid

# Wait briefly for server to start
echo "Waiting for MCP Server to initialize..."
sleep 5

cat <<EOF
To stop the server and inspector:
  kill \\$(cat .server.pid) || true
  kill \\$(cat .inspector.pid) || true
Or run:
  lsof -ti:8888 6274 6277 | xargs -r kill -9
EOF

echo "Setup finished successfully."
echo "===================================================="
echo "= MCP Basics Demo is running!                      ="
echo "= Access the Inspector at:                         ="
echo "= http://localhost:6274                            ="
echo "===================================================="

echo "Testing the server with: curl http://localhost:8888/health"
curl -sSvlk http://localhost:8888/health
echo "===================================================="

echo "curl http://localhost:8888/tools"
curl http://localhost:8888/tools | jq .
echo "===================================================="

echo "curl http://localhost:8888/negotiate"
curl http://localhost:8888/negotiate | jq .
echo "===================================================="


# Start MCP Inspector in background (omit auth) and detach
echo "Starting MCP Inspector (background)..."
DANGEROUSLY_OMIT_AUTH=true npx @modelcontextprotocol/inspector http://localhost:8888/mcp &

INSPECTOR_PID=$!
echo $INSPECTOR_PID > .inspector.pid

# Report status and exit (do not capture the shell)
sleep 1
if ps -p $SERVER_PID > /dev/null; then
    echo "MCP Server started (PID: $SERVER_PID)"
else
    echo "MCP Server failed to start; check logs or run 'tail -n +1 .venv/log/*.log'"
fi

if ps -p $INSPECTOR_PID > /dev/null; then
    echo "MCP Inspector started (PID: $INSPECTOR_PID)"
else
    echo "MCP Inspector failed to start; check npx installation or logs"
fi

