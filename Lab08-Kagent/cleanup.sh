#!/bin/bash

#==============================================================================
# Kagent Cleanup Script
#==============================================================================
#
# This script stops all running services and optionally removes installed
# components from the Kagent installation.
#
# Usage:
#   ./cleanup.sh [options]
#
# Options:
#   --all          Remove everything (MCP servers, namespace, repository)
#   --services     Stop services only (MCP Inspector, Ollama)
#   --mcp          Remove MCP servers only
#   --help         Show this help message
#
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/examples"

# Show help
show_help() {
  cat <<EOF
Kagent Cleanup Script

Usage: ./cleanup.sh [options]

Options:
  --all          Remove everything (stop services, remove MCP servers, namespace, repository)
  --services     Stop running services only (MCP Inspector, Ollama)
  --mcp          Remove MCP servers from Kubernetes only
  --namespace    Delete the kagent namespace
  --repo         Remove cloned repository
  --help         Show this help message

Examples:
  ./cleanup.sh --services              # Stop MCP Inspector and Ollama
  ./cleanup.sh --mcp                   # Remove all MCP servers
  ./cleanup.sh --all                   # Complete cleanup
  ./cleanup.sh --services --mcp        # Stop services and remove MCP servers

If no options provided, only services will be stopped.
EOF
}

# Parse arguments
STOP_SERVICES=false
REMOVE_MCP=false
REMOVE_NAMESPACE=false
REMOVE_REPO=false

if [ $# -eq 0 ]; then
  STOP_SERVICES=true
else
  while [[ $# -gt 0 ]]; do
    case $1 in
    --all)
      STOP_SERVICES=true
      REMOVE_MCP=true
      REMOVE_NAMESPACE=true
      REMOVE_REPO=true
      shift
      ;;
    --services)
      STOP_SERVICES=true
      shift
      ;;
    --mcp)
      REMOVE_MCP=true
      shift
      ;;
    --namespace)
      REMOVE_NAMESPACE=true
      shift
      ;;
    --repo)
      REMOVE_REPO=true
      shift
      ;;
    --help | -h)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
    esac
  done
fi

echo "=========================================="
echo -e "${CYAN}🧹 Kagent Cleanup${NC}"
echo "=========================================="
echo ""

# ============================================
# Stop Running Services
# ============================================
if [ "$STOP_SERVICES" = true ]; then
  echo -e "${BLUE}Stopping running services...${NC}"

  # Stop MCP Inspector
  if pgrep -f "@modelcontextprotocol/inspector" >/dev/null 2>&1; then
    echo "Stopping MCP Inspector..."
    pkill -f "@modelcontextprotocol/inspector" 2>/dev/null || true
    pkill -f "tsx src/index.ts" 2>/dev/null || true
    sleep 1

    if pgrep -f "@modelcontextprotocol/inspector" >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  Force killing MCP Inspector...${NC}"
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
      echo -e "${YELLOW}⚠️  Force killing Ollama...${NC}"
      pkill -9 -f "ollama serve" 2>/dev/null || true
    fi

    echo -e "${GREEN}✅ Ollama stopped${NC}"
  else
    echo "Ollama is not running"
  fi

  echo ""
fi

# ============================================
# Remove MCP Servers
# ============================================
if [ "$REMOVE_MCP" = true ]; then
  echo -e "${BLUE}Removing MCP servers from Kubernetes...${NC}"

  if command -v kubectl &>/dev/null; then
    server_count=$(kubectl get mcpservers -n kagent --no-headers 2>/dev/null | wc -l | xargs)

    if [ "$server_count" -gt 0 ]; then
      echo "Found $server_count MCP server(s)"
      kubectl delete mcpserver --all -n kagent
      echo -e "${GREEN}✅ MCP servers removed${NC}"
    else
      echo "No MCP servers found"
    fi
  else
    echo -e "${YELLOW}⚠️  kubectl not found, skipping MCP server removal${NC}"
  fi

  echo ""
fi

# ============================================
# Remove Namespace
# ============================================
if [ "$REMOVE_NAMESPACE" = true ]; then
  echo -e "${BLUE}Removing kagent namespace...${NC}"

  if command -v kubectl &>/dev/null; then
    if kubectl get namespace kagent >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  This will remove ALL resources in the kagent namespace${NC}"
      read -p "Are you sure? (y/N): " -n 1 -r
      echo ""

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace kagent
        echo -e "${GREEN}✅ Namespace removed${NC}"
      else
        echo "Namespace deletion cancelled"
      fi
    else
      echo "Namespace 'kagent' does not exist"
    fi
  else
    echo -e "${YELLOW}⚠️  kubectl not found, skipping namespace removal${NC}"
  fi

  echo ""
fi

# ============================================
# Remove Repository
# ============================================
if [ "$REMOVE_REPO" = true ]; then
  echo -e "${BLUE}Removing cloned repository...${NC}"

  KAGENT_REPO_DIR="$EXAMPLES_DIR/kagent-repo"

  if [ -d "$KAGENT_REPO_DIR" ]; then
    repo_size=$(du -sh "$KAGENT_REPO_DIR" 2>/dev/null | cut -f1)
    echo "Repository size: $repo_size"
    echo "Location: $KAGENT_REPO_DIR"

    read -p "Remove repository? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$KAGENT_REPO_DIR"
      echo -e "${GREEN}✅ Repository removed${NC}"
    else
      echo "Repository removal cancelled"
    fi
  else
    echo "Repository not found at $KAGENT_REPO_DIR"
  fi

  echo ""
fi

# ============================================
# Summary
# ============================================
echo "=========================================="
echo -e "${GREEN}✨ Cleanup Complete${NC}"
echo "=========================================="
echo ""

# Show what's still running/installed
echo "Current status:"
echo ""

# Check services
if pgrep -f "@modelcontextprotocol/inspector" >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  MCP Inspector is still running${NC}"
else
  echo -e "${GREEN}✅ MCP Inspector stopped${NC}"
fi

if pgrep -f "ollama serve" >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Ollama is still running${NC}"
else
  echo -e "${GREEN}✅ Ollama stopped${NC}"
fi

echo ""

# Check Kubernetes resources
if command -v kubectl &>/dev/null && kubectl cluster-info &>/dev/null; then
  mcp_count=$(kubectl get mcpservers -n kagent --no-headers 2>/dev/null | wc -l | xargs)
  if [ "$mcp_count" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $mcp_count MCP server(s) still in Kubernetes${NC}"
  else
    echo -e "${GREEN}✅ No MCP servers in Kubernetes${NC}"
  fi

  if kubectl get namespace kagent >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  kagent namespace still exists${NC}"
  else
    echo -e "${GREEN}✅ kagent namespace removed${NC}"
  fi
fi

echo ""

# Check repository
if [ -d "$EXAMPLES_DIR/kagent-repo" ]; then
  echo -e "${YELLOW}⚠️  Repository still exists at: $EXAMPLES_DIR/kagent-repo${NC}"
else
  echo -e "${GREEN}✅ Repository removed${NC}"
fi

echo ""
echo "For complete cleanup, run: ./cleanup.sh --all"
echo ""
