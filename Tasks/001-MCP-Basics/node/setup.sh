#!/bin/bash

# Create script for running MCP server with nodejs and MCP inspector
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
echo "Initializing MCP Basics Demo in $SCRIPT_DIR..."
# Check for node
if ! command -v node &> /dev/null; then

    echo "Error: node is not installed. Please install node first."
    exit 1
fi  
# Check for npm
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install npm first."
    exit 1
fi  
# Install dependencies
npm install
npm run build
echo "Setup complete."

# Kill any existing server or inspector processes (ports commonly used)
for P in 8888 6274 6277; do
    lsof -ti:$P | xargs -r kill -9 || true
done
# Start MCP Server in background
echo "Starting MCP Server (background)..."        
node build/index.js &

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

# Start MCP Inspector in background
echo "Starting MCP Inspector (background)..."
npx @modelcontextprotocol/inspector node ./build/index.js &

INSPECTOR_PID=$!
echo $INSPECTOR_PID > .inspector.pid  
echo "MCP Inspector started with PID $INSPECTOR_PID"

cat <<EOF
MCP Inspector is running in the background.
To stop the inspector, run:
  kill \\$(cat .inspector.pid) || true
Or run:
  lsof -ti:8888 6274 6277 | xargs -r  kill -9
EOF

echo "Setup finished successfully."

# Report status and exit (do not capture the shell)
sleep 1                     
if ps -p $SERVER_PID > /dev/null; then
    echo "MCP Server started (PID: $SERVER_PID)"
else
    echo "MCP Server failed to start; check logs or run 'tail -n +1 build/log/*.log'"
fi

if ps -p $INSPECTOR_PID > /dev/null; then
    echo "MCP Inspector started (PID: $INSPECTOR_PID)"
else
    echo "MCP Inspector failed to start; check npx installation or logs"
fi
echo "===================================================="
echo "= To stop the server and inspector:                ="
echo "=   kill \\$(cat .server.pid) || tru               ="
echo "=   kill \\$(cat .inspector.pid) || true           ="
echo "= Or run:                                          ="   
echo "=   lsof -ti:8888 6274 6277 | xargs -r kill -9     ="
echo "====================================================" 
echo "Setup script completed."
echo "===================================================="
