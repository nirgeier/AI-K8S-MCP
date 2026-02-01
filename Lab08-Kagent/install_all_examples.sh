#!/bin/bash

#==============================================================================
# Kagent Official Examples & MCP Installation Script
#==============================================================================
#
# This script installs:
#   - Kagent official repository with examples
#   - K8sGPT MCP Server (Kubernetes diagnostics)
#   - 8 Official MCP Servers from Anthropic
#   - 4 Community MCP Servers
#
# Official MCP Servers (Node.js/npm):
#   1. GitHub MCP Server          - GitHub API integration
#   2. Filesystem MCP Server      - File system operations
#   3. Memory MCP Server          - Context management
#   4. Git MCP Server             - Git operations
#   5. Slack MCP Server           - Slack integration
#   6. PostgreSQL MCP Server      - Database access
#   7. Google Drive MCP Server    - Google Drive integration
#
# Community MCP Servers (Python/uvx):
#   1. Brave Search MCP Server    - Web search
#   2. Time MCP Server            - Time utilities
#   3. Fetch MCP Server           - HTTP requests
#   4. Sequential Thinking        - Reasoning chains
#
# Prerequisites:
#   - kubectl (configured with cluster access)
#   - git
#   - Kubernetes cluster running
#
# Usage:
#   ./install_all_examples.sh
#
#==============================================================================

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/examples"
KAGENT_DIR="$SCRIPT_DIR/../../lab_solution/k-agent-logs"

# ============================================
# Function: Open Kagent Dashboard
# ============================================
open_kagent_dashboard() {
  local kagent_path="${1:-$KAGENT_DIR}"

  if [ ! -d "$kagent_path" ]; then
    echo -e "${RED}❌ Kagent directory not found at: $kagent_path${NC}"
    echo ""
    echo "To build the K-Agent MCP Server:"
    echo "  1. Follow Lab 8 instructions to create the k-agent-logs server"
    echo "  2. Or run: $SCRIPT_DIR/install_kagent.sh"
    return 1
  fi

  if [ ! -d "$kagent_path/dist" ] || [ ! -f "$kagent_path/dist/index.js" ]; then
    echo -e "${RED}❌ Kagent not built. Building now...${NC}"
    cd "$kagent_path"

    # Check if package.json exists
    if [ ! -f "package.json" ]; then
      echo -e "${RED}❌ Not a valid Kagent project (no package.json found)${NC}"
      return 1
    fi

    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
      echo "📦 Installing dependencies..."
      npm install
    fi

    # Build
    echo "🔨 Building Kagent..."
    npm run build

    if [ ! -f "dist/index.js" ]; then
      echo -e "${RED}❌ Build failed${NC}"
      return 1
    fi

    echo -e "${GREEN}✅ Kagent built successfully${NC}"
    cd "$SCRIPT_DIR"
  fi

  echo ""
  echo -e "${BLUE}🚀 Opening Kagent Dashboard (MCP Inspector)...${NC}"
  echo ""
  echo "This will:"
  echo "  1. Start the MCP Inspector web interface"
  echo "  2. Connect to your Kagent MCP Server"
  echo "  3. Open in your default browser"
  echo ""
  echo "The dashboard allows you to:"
  echo "  • Test list_pods tool"
  echo "  • Test collect_pod_logs tool"
  echo "  • Interact with your Kubernetes cluster"
  echo "  • View all installed MCP servers"
  echo ""

  cd "$kagent_path"

  # Check if npx is available
  if ! command -v npx &>/dev/null; then
    echo -e "${RED}❌ npx not found. Please install Node.js${NC}"
    return 1
  fi

  echo -e "${GREEN}✅ Starting MCP Inspector...${NC}"
  echo "Press Ctrl+C to stop the dashboard"
  echo ""

  # Setup cleanup on exit
  cleanup_dashboard() {
    echo ""
    echo -e "${YELLOW}Stopping MCP Inspector...${NC}"
    # Kill any running MCP Inspector processes
    pkill -f "@modelcontextprotocol/inspector" 2>/dev/null || true
    pkill -f "tsx src/index.ts" 2>/dev/null || true
    echo -e "${GREEN}✅ Dashboard stopped${NC}"
  }

  trap cleanup_dashboard EXIT INT TERM

  # Start the MCP Inspector
  npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts

  # Cleanup
  cleanup_dashboard
  trap - EXIT INT TERM
}

echo "=========================================="
echo -e "${CYAN}🚀 Kagent Official Examples & MCP Installer${NC}"
echo "=========================================="
echo ""

# ============================================
# Step 1: Check Prerequisites
# ============================================
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"

# Check kubectl
if ! command -v kubectl &>/dev/null; then
  echo -e "${YELLOW}⚠️  kubectl not found${NC}"
  echo "Please install kubectl first"
  exit 1
fi
echo -e "${GREEN}✅ kubectl installed${NC}"

# Check if cluster is accessible
if ! kubectl cluster-info &>/dev/null; then
  echo -e "${YELLOW}⚠️  No Kubernetes cluster found${NC}"
  echo "Please start your Kubernetes cluster first"
  exit 1
fi
echo -e "${GREEN}✅ Kubernetes cluster accessible${NC}"

# Check git
if ! command -v git &>/dev/null; then
  echo -e "${RED}❌ git not found. Please install git first${NC}"
  exit 1
fi
echo -e "${GREEN}✅ git installed${NC}"

echo ""

# ============================================
# Step 2: Clone Kagent Repository
# ============================================
echo -e "${BLUE}Step 2: Setting up Kagent repository...${NC}"

KAGENT_REPO_DIR="$EXAMPLES_DIR/kagent-repo"

if [ -d "$KAGENT_REPO_DIR" ]; then
  echo -e "${YELLOW}Kagent repository already exists, updating...${NC}"
  cd "$KAGENT_REPO_DIR"
  git pull origin main || echo -e "${YELLOW}⚠️  Could not update repository${NC}"
  cd "$SCRIPT_DIR"
else
  echo "Cloning Kagent repository..."
  mkdir -p "$EXAMPLES_DIR"
  git clone https://github.com/kagent-dev/kagent.git "$KAGENT_REPO_DIR"
fi

echo -e "${GREEN}✅ Kagent repository ready at: $KAGENT_REPO_DIR${NC}"
echo ""

# ============================================
# Step 3: List Available Examples
# ============================================
echo -e "${BLUE}Step 3: Exploring official examples...${NC}"

if [ -d "$KAGENT_REPO_DIR/examples" ]; then
  echo "📦 Available examples in repository:"
  ls -la "$KAGENT_REPO_DIR/examples" | grep "^d" | awk '{print "  - " $9}' | grep -v "^\s*-\s*\.\?$"
  echo ""
fi

# ============================================
# Step 4: Install Kagent CLI (Optional)
# ============================================
echo -e "${BLUE}Step 4: Checking Kagent CLI...${NC}"

if ! command -v kagent &>/dev/null; then
  echo -e "${YELLOW}Kagent CLI not found${NC}"
  echo "To install Kagent CLI, visit: https://kagent.dev/docs/kagent/introduction/installation"
  echo "Or run: curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash"
  echo ""
  echo -e "${YELLOW}Continuing without CLI (will use kubectl apply for examples)${NC}"
else
  echo -e "${GREEN}✅ Kagent CLI installed${NC}"
  kagent version || true
fi

echo ""

# ============================================
# Step 5: Install K8sGPT MCP Server Example
# ============================================
echo -e "${BLUE}Step 5: Installing K8sGPT MCP Server Example...${NC}"

K8SGPT_DIR="$KAGENT_REPO_DIR/contrib/tools/k8sgpt-mcp-server"

if [ -d "$K8SGPT_DIR" ]; then
  echo "📦 Installing K8sGPT MCP Server..."

  # Install the deployment
  kubectl apply -f "$K8SGPT_DIR/deploy-k8sgpt-mcp-server.yaml" 2>/dev/null ||
    echo -e "${YELLOW}⚠️  K8sGPT deployment may already exist${NC}"

  # Wait a moment for deployment
  sleep 2

  # Install the toolserver
  kubectl apply -f "$K8SGPT_DIR/k8sgpt-mcp-toolserver.yaml" 2>/dev/null ||
    echo -e "${YELLOW}⚠️  K8sGPT toolserver may already exist${NC}"

  echo -e "${GREEN}✅ K8sGPT MCP Server installed${NC}"

  # Check status
  echo "Checking K8sGPT pod status:"
  kubectl get pods -n kagent -l app=k8sgpt-mcp-server --no-headers 2>/dev/null | head -5 ||
    kubectl get pods -l app=k8sgpt-mcp-server --no-headers 2>/dev/null | head -5 ||
    echo "No pods found yet (they may be starting)"
else
  echo -e "${YELLOW}⚠️  K8sGPT example not found in repository${NC}"
fi

echo ""

# ============================================
# Step 6: Install Common MCP Servers via Package Managers
# ============================================
echo -e "${BLUE}Step 6: Installing common MCP servers...${NC}"

# Create namespace if it doesn't exist
kubectl create namespace kagent 2>/dev/null || echo "Namespace kagent already exists"

# Function to deploy MCP server using package manager
deploy_package_mcp() {
  local name=$1
  local manager=$2
  local package=$3
  local description=$4

  echo ""
  echo -e "${CYAN}Installing $name MCP Server...${NC}"
  echo "Description: $description"

  # Create MCPServer resource
  cat <<EOF | kubectl apply -f - 2>/dev/null || echo -e "${YELLOW}⚠️  $name may already exist${NC}"
apiVersion: kagent.dev/v1alpha1
kind: MCPServer
metadata:
  name: $name
  namespace: kagent
  labels:
    app: $name
    type: mcp-server
spec:
  deployment:
    image: node:24-bookworm-slim
    command: ["npx"]
    args: ["$package"]
    port: 3000
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
EOF

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ $name MCP Server configuration created${NC}"
  fi
}

# Install GitHub MCP Server
deploy_package_mcp \
  "github-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-github" \
  "MCP server for GitHub integration"

# Install Filesystem MCP Server
deploy_package_mcp \
  "filesystem-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-filesystem" \
  "MCP server for filesystem operations"

# Install Memory MCP Server
deploy_package_mcp \
  "memory-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-memory" \
  "MCP server for memory/context management"

# Install Git MCP Server
deploy_package_mcp \
  "git-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-git" \
  "MCP server for Git operations"

# Install Slack MCP Server
deploy_package_mcp \
  "slack-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-slack" \
  "MCP server for Slack integration"

# Install PostgreSQL MCP Server
deploy_package_mcp \
  "postgres-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-postgres" \
  "MCP server for PostgreSQL database"

# Install Google Drive MCP Server
deploy_package_mcp \
  "gdrive-mcp-server" \
  "npx" \
  "@modelcontextprotocol/server-gdrive" \
  "MCP server for Google Drive integration"

echo ""
echo -e "${GREEN}✅ Official MCP servers deployed${NC}"

echo ""
echo -e "${BLUE}Installing community MCP servers (Python-based)...${NC}"

# Function to deploy Python-based MCP server using uvx
deploy_python_mcp() {
  local name=$1
  local package=$2
  local description=$3

  echo ""
  echo -e "${CYAN}Installing $name MCP Server...${NC}"
  echo "Description: $description"

  # Create MCPServer resource for Python packages
  cat <<EOF | kubectl apply -f - 2>/dev/null || echo -e "${YELLOW}⚠️  $name may already exist${NC}"
apiVersion: kagent.dev/v1alpha1
kind: MCPServer
metadata:
  name: $name
  namespace: kagent
  labels:
    app: $name
    type: mcp-server
    language: python
spec:
  deployment:
    image: python:3.11-slim
    command: ["sh", "-c"]
    args: ["pip install uv && uvx $package"]
    port: 3000
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
EOF

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ $name MCP Server configuration created${NC}"
  fi
}

# Install Brave Search MCP Server
deploy_python_mcp \
  "brave-search-mcp-server" \
  "mcp-server-brave-search" \
  "MCP server for Brave Search API"

# Install Time MCP Server
deploy_python_mcp \
  "time-mcp-server" \
  "mcp-server-time" \
  "MCP server for time utilities"

# Install Fetch MCP Server
deploy_python_mcp \
  "fetch-mcp-server" \
  "mcp-server-fetch" \
  "MCP server for HTTP requests"

# Install Sequential Thinking MCP Server
deploy_python_mcp \
  "sequential-thinking-mcp-server" \
  "mcp-server-sequential-thinking" \
  "MCP server for sequential reasoning"

echo ""
echo -e "${GREEN}✅ Community MCP servers deployed${NC}"

echo ""

# ============================================
# Step 7: Deploy Example Agents from Examples Directory
# ============================================
echo -e "${BLUE}Step 7: Checking for deployable examples...${NC}"

EXAMPLES_YAML_DIR="$KAGENT_REPO_DIR/examples"

if [ -d "$EXAMPLES_YAML_DIR" ]; then
  echo "Searching for YAML manifests in examples directory..."

  # Find and apply YAML/YML files
  yaml_count=0
  while IFS= read -r -d '' yaml_file; do
    echo ""
    echo -e "${CYAN}Applying: $(basename "$yaml_file")${NC}"
    kubectl apply -f "$yaml_file" 2>&1 | grep -v "unchanged" || true
    ((yaml_count++))
  done < <(find "$EXAMPLES_YAML_DIR" -maxdepth 3 -type f \( -name "*.yaml" -o -name "*.yml" \) -print0 2>/dev/null)

  if [ $yaml_count -gt 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Applied $yaml_count example manifests${NC}"
  else
    echo -e "${YELLOW}No YAML manifests found in examples directory${NC}"
  fi
fi

echo ""

# ============================================
# Step 8: Summary
# ============================================
echo "=========================================="
echo -e "${GREEN}✨ Installation Summary${NC}"
echo "=========================================="
echo ""

echo "📦 Installed Components:"
echo ""
echo "1. Kagent Repository:"
echo "   Location: $KAGENT_REPO_DIR"
echo "   Examples: $KAGENT_REPO_DIR/examples"
echo "   Contrib:  $KAGENT_REPO_DIR/contrib/tools"
echo ""

echo "2. MCP Servers (deployed to Kubernetes):"
echo ""
echo "   Official MCP Servers:"
echo "   - K8sGPT MCP Server (Kubernetes diagnostics)"
echo "   - GitHub MCP Server (GitHub integration)"
echo "   - Filesystem MCP Server (File operations)"
echo "   - Memory MCP Server (Context management)"
echo "   - Git MCP Server (Git operations)"
echo "   - Slack MCP Server (Slack integration)"
echo "   - PostgreSQL MCP Server (Database access)"
echo "   - Google Drive MCP Server (Google Drive integration)"
echo ""
echo "   Community MCP Servers:"
echo "   - Brave Search MCP Server (Web search)"
echo "   - Time MCP Server (Time utilities)"
echo "   - Fetch MCP Server (HTTP requests)"
echo "   - Sequential Thinking MCP Server (Reasoning)"
echo ""

echo "3. Check deployed resources:"
echo "   kubectl get mcpservers -n kagent"
echo "   kubectl get pods -n kagent"
echo "   kubectl get agents -n kagent"
echo ""

# Check what was actually created
echo -e "${CYAN}Current MCP Servers:${NC}"
kubectl get mcpservers -n kagent 2>/dev/null || echo "No MCP servers found (may need to install Kagent CRDs)"

echo ""
echo -e "${CYAN}Current Pods in kagent namespace:${NC}"
kubectl get pods -n kagent 2>/dev/null || echo "No pods found in kagent namespace"

echo ""
echo -e "${CYAN}MCP Server Summary:${NC}"
total_servers=$(kubectl get mcpservers -n kagent --no-headers 2>/dev/null | wc -l | xargs)
echo "Total MCP Servers installed: ${total_servers:-0}"
echo ""

if [ "$total_servers" -gt 0 ]; then
  echo "Server types:"
  kubectl get mcpservers -n kagent -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.language}{"\n"}{end}' 2>/dev/null |
    awk '{if ($2=="python") print "  - "$1" (Python)"; else print "  - "$1" (Node.js)"}' | sort
fi

echo ""

# ============================================
# Step 9: Next Steps
# ============================================
echo "=========================================="
echo -e "${MAGENTA}📚 Next Steps${NC}"
echo "=========================================="
echo ""

echo "1. Explore the examples:"
echo "   cd $KAGENT_REPO_DIR/examples"
echo "   ls -la"
echo ""

echo "2. Create your own MCP server:"
echo "   kagent mcp init my-mcp-server"
echo "   cd my-mcp-server"
echo "   kagent mcp add-tool my-tool"
echo ""

echo "3. Deploy a custom MCP server:"
echo "   # Official npm packages"
echo "   kagent mcp deploy package --deployment-name weather --manager npx --args @modelcontextprotocol/server-weather"
echo "   kagent mcp deploy package --deployment-name puppeteer --manager npx --args @modelcontextprotocol/server-puppeteer"
echo ""
echo "   # Python packages"
echo "   kagent mcp deploy package --deployment-name arxiv --manager uvx --args mcp-server-arxiv"
echo "   kagent mcp deploy package --deployment-name google --manager uvx --args mcp-server-google"
echo ""

echo "4. View MCP server logs:"
echo "   kubectl logs -n kagent -l app=github-mcp-server"
echo "   kubectl logs -n kagent -l app=brave-search-mcp-server"
echo ""

echo "5. List all installed MCP servers:"
echo "   kubectl get mcpservers -n kagent"
echo "   kubectl get pods -n kagent -l type=mcp-server"
echo ""

echo "6. Access the Kagent UI (if installed):"
echo "   kubectl port-forward -n kagent svc/kagent-ui 8080:8080"
echo "   open http://localhost:8080"
echo ""

echo "=========================================="
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo "=========================================="
echo ""

echo "📖 Documentation:"
echo "   Official Docs: https://kagent.dev"
echo "   GitHub:        https://github.com/kagent-dev/kagent"
echo "   MCP Examples:  https://github.com/kagent-dev/kagent/tree/main/examples"
echo ""

echo "💬 Get Help:"
echo "   Discord:       https://discord.gg/Fu3k65f2k3"
echo "   Slack:         https://cloud-native.slack.com/archives/C08ETST0076"
echo ""

echo "=========================================="
echo -e "${YELLOW}⚠️  Important Notes${NC}"
echo "=========================================="
echo ""
echo "📌 Server Startup Times:"
echo "   MCP servers may take 1-3 minutes to download images and start"
echo "   Monitor progress with: watch kubectl get pods -n kagent"
echo ""
echo "🔍 Troubleshooting:"
echo "   If a server fails to start:"
echo "   1. Check logs: kubectl logs -n kagent -l app=<server-name>"
echo "   2. Describe pod: kubectl describe pod -n kagent -l app=<server-name>"
echo "   3. Check events: kubectl get events -n kagent --sort-by='.lastTimestamp'"
echo ""
echo "🔄 To reinstall a server:"
echo "   kubectl delete mcpserver <server-name> -n kagent"
echo "   Then re-run this script"
echo ""
echo "📊 Total Installed:"
echo "   ✅ 1 K8sGPT Server"
echo "   ✅ 7 Official MCP Servers (Node.js)"
echo "   ✅ 4 Community MCP Servers (Python)"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━"
echo "   🎯 12 MCP Servers Total"
echo ""

# ============================================
# Step 10: Open Kagent Dashboard (Optional)
# ============================================
echo "=========================================="
echo -e "${MAGENTA}📊 Open Kagent Dashboard?${NC}"
echo "=========================================="
echo ""

# Check if Kagent exists
if [ -d "$KAGENT_DIR" ]; then
  if [ -d "$KAGENT_DIR/dist" ] && [ -f "$KAGENT_DIR/dist/index.js" ]; then
    echo -e "${GREEN}✅ K-Agent MCP Server found and ready${NC}"
    echo "Location: $KAGENT_DIR"
    echo ""
    read -p "Would you like to open the Kagent Dashboard now? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      open_kagent_dashboard "$KAGENT_DIR"
    else
      echo ""
      echo "You can open the dashboard later by running:"
      echo "  cd $KAGENT_DIR"
      echo "  npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts"
      echo ""
      echo "Or run:"
      echo "  $SCRIPT_DIR/open_dashboard.sh"
      echo ""
    fi
  else
    echo -e "${YELLOW}⚠️  K-Agent MCP Server found but not built${NC}"
    echo "Location: $KAGENT_DIR"
    echo ""
    read -p "Would you like to build and open the Kagent Dashboard now? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      open_kagent_dashboard "$KAGENT_DIR"
    else
      echo ""
      echo "To build and run the dashboard later:"
      echo "  cd $KAGENT_DIR"
      echo "  npm install"
      echo "  npm run build"
      echo "  npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts"
      echo ""
    fi
  fi
else
  echo -e "${YELLOW}⚠️  K-Agent MCP Server not found${NC}"
  echo "Expected location: $KAGENT_DIR"
  echo ""
  echo "To create the K-Agent MCP Server:"
  echo "  1. Follow Lab 8 instructions in the documentation"
  echo "  2. Or run: $SCRIPT_DIR/install_kagent.sh"
  echo ""
fi

echo "=========================================="
echo -e "${GREEN}✨ All Done!${NC}"
echo "=========================================="
echo ""

echo "=========================================="
echo -e "${CYAN}🛑 Cleanup Commands${NC}"
echo "=========================================="
echo ""
echo "Quick cleanup script available:"
echo "  ./cleanup.sh --help              # Show all options"
echo "  ./cleanup.sh --services          # Stop MCP Inspector and Ollama"
echo "  ./cleanup.sh --mcp               # Remove MCP servers"
echo "  ./cleanup.sh --all               # Complete cleanup"
echo ""
echo "Or manually:"
echo ""
echo "1. Stop MCP Inspector (if running):"
echo "   pkill -f '@modelcontextprotocol/inspector'"
echo "   pkill -f 'tsx src/index.ts'"
echo ""
echo "2. Stop Ollama (if running from install_kagent.sh):"
echo "   pkill -f 'ollama serve'"
echo ""
echo "3. Remove all installed MCP servers:"
echo "   kubectl delete mcpserver --all -n kagent"
echo ""
echo "4. Delete the kagent namespace:"
echo "   kubectl delete namespace kagent"
echo ""
echo "5. Clean up cloned repository:"
echo "   rm -rf $EXAMPLES_DIR/kagent-repo"
echo ""
