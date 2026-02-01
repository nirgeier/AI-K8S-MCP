#!/bin/bash

# Quick script to open Kagent Dashboard
# This sources the main install script to get the open_kagent_dashboard function

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Set KAGENT_DIR
KAGENT_DIR="$SCRIPT_DIR/../../lab_solution/k-agent-logs"

echo "=========================================="
echo -e "${BLUE}🚀 Opening Kagent Dashboard${NC}"
echo "=========================================="
echo ""

# Check if Kagent exists and is built
if [ ! -d "$KAGENT_DIR" ]; then
  echo -e "${RED}❌ Kagent directory not found at:${NC}"
  echo "   $KAGENT_DIR"
  exit 1
fi

if [ ! -d "$KAGENT_DIR/dist" ] || [ ! -f "$KAGENT_DIR/dist/index.js" ]; then
  echo -e "${RED}❌ Kagent not built. Please run install_kagent.sh first${NC}"
  exit 1
fi

echo "📁 Kagent location: $KAGENT_DIR"
echo ""
echo "This will open the MCP Inspector which allows you to:"
echo "  • Test list_pods tool"
echo "  • Test collect_pod_logs tool"
echo "  • Interact with your Kubernetes cluster"
echo ""
echo -e "${GREEN}✅ Starting MCP Inspector...${NC}"
echo "Press Ctrl+C to stop the dashboard"
echo ""
echo "The dashboard will open in your browser automatically."
echo ""

cd "$KAGENT_DIR"

# Start the MCP Inspector
npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts
