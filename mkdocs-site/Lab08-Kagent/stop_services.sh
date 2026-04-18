#!/bin/bash

# Quick script to stop MCP Inspector and Ollama services
# Usage: ./stop_services.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "🛑 Stopping Kagent Services"
echo "=========================================="
echo ""

# Stop MCP Inspector
if pgrep -f "@modelcontextprotocol/inspector" >/dev/null 2>&1 || pgrep -f "tsx src/index.ts" >/dev/null 2>&1; then
  echo "Stopping MCP Inspector..."
  pkill -f "@modelcontextprotocol/inspector" 2>/dev/null || true
  pkill -f "tsx src/index.ts" 2>/dev/null || true
  sleep 1

  if pgrep -f "@modelcontextprotocol/inspector" >/dev/null 2>&1; then
    echo -e "${YELLOW}Force killing MCP Inspector...${NC}"
    pkill -9 -f "@modelcontextprotocol/inspector" 2>/dev/null || true
    pkill -9 -f "tsx src/index.ts" 2>/dev/null || true
  fi

  echo -e "${GREEN}✅ MCP Inspector stopped${NC}"
else
  echo "MCP Inspector is not running"
fi

echo ""

# Stop Ollama
if pgrep -f "ollama serve" >/dev/null 2>&1; then
  echo "Stopping Ollama..."
  pkill -f "ollama serve" 2>/dev/null || true
  sleep 2

  if pgrep -f "ollama serve" >/dev/null 2>&1; then
    echo -e "${YELLOW}Force killing Ollama...${NC}"
    pkill -9 -f "ollama serve" 2>/dev/null || true
  fi

  echo -e "${GREEN}✅ Ollama stopped${NC}"
else
  echo "Ollama is not running"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✨ Services stopped${NC}"
echo "=========================================="
echo ""
echo "To remove MCP servers and other resources:"
echo "  ./cleanup.sh --all"
echo ""
