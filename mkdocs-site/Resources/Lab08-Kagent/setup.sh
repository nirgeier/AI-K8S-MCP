#!/bin/bash

#==============================================================================
# Lab 08 - K-Agent Setup Script
#==============================================================================
# This script sets up the K-Agent MCP Server project from scratch
#
# Usage:
#   ./setup.sh              # Full setup
#   ./setup.sh --skip-deps  # Skip npm install
#   ./setup.sh --help       # Show help
#==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/k-agent-logs"

# Parse arguments
SKIP_DEPS=false
for arg in "$@"; do
  case $arg in
  --skip-deps)
    SKIP_DEPS=true
    ;;
  --help)
    echo "Lab 08 - K-Agent Setup Script"
    echo ""
    echo "Usage: ./setup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --skip-deps    Skip npm install"
    echo "  --help         Show this help"
    exit 0
    ;;
  esac
done

echo "=========================================="
echo -e "${BLUE}🚀 Lab 08 - K-Agent Setup${NC}"
echo "=========================================="
echo ""

# Step 1: Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"

if ! command -v node &>/dev/null; then
  echo -e "${RED}❌ Node.js not found. Please install Node.js 18+${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"

if ! command -v npm &>/dev/null; then
  echo -e "${RED}❌ npm not found${NC}"
  exit 1
fi
echo -e "${GREEN}✅ npm: $(npm --version)${NC}"

if ! command -v kubectl &>/dev/null; then
  echo -e "${YELLOW}⚠️  kubectl not found - K-Agent will have limited functionality${NC}"
else
  echo -e "${GREEN}✅ kubectl available${NC}"
  if kubectl cluster-info &>/dev/null; then
    echo -e "${GREEN}✅ Kubernetes cluster accessible${NC}"
  else
    echo -e "${YELLOW}⚠️  No Kubernetes cluster found${NC}"
  fi
fi

echo ""

# Step 2: Create project directory
echo -e "${BLUE}Step 2: Creating project directory...${NC}"

if [ -d "$PROJECT_DIR" ]; then
  echo -e "${YELLOW}⚠️  Project directory already exists${NC}"
  read -p "Overwrite? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Keeping existing directory"
  else
    rm -rf "$PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
  fi
else
  mkdir -p "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"
echo -e "${GREEN}✅ Project directory: $PROJECT_DIR${NC}"
echo ""

# Step 3: Create package.json
echo -e "${BLUE}Step 3: Creating package.json...${NC}"

cat >package.json <<'EOF'
{
  "name": "k-agent-logs",
  "version": "1.0.0",
  "description": "K-Agent MCP server for Kubernetes log collection",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/index.ts",
    "start": "node dist/index.js",
    "inspector": "npx @modelcontextprotocol/inspector node_modules/.bin/tsx src/index.ts"
  },
  "keywords": ["kubernetes", "mcp", "logs", "monitoring"],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "dependencies": {
    "@kubernetes/client-node": "^1.4.0",
    "@modelcontextprotocol/sdk": "^1.25.2"
  },
  "devDependencies": {
    "@types/node": "^25.0.3",
    "tsx": "^4.21.0",
    "typescript": "^5.9.3"
  }
}
EOF

echo -e "${GREEN}✅ package.json created${NC}"
echo ""

# Step 4: Create tsconfig.json
echo -e "${BLUE}Step 4: Creating tsconfig.json...${NC}"

cat >tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

echo -e "${GREEN}✅ tsconfig.json created${NC}"
echo ""

# Step 5: Create source directory and main file
echo -e "${BLUE}Step 5: Creating source files...${NC}"

mkdir -p src

cat >src/index.ts <<'EOF'
// Import MCP SDK components and Kubernetes client
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as k8s from '@kubernetes/client-node';

class KAgentServer {
  private k8sConfig: k8s.KubeConfig;
  private k8sAppsApi: k8s.AppsV1Api;
  private k8sCoreApi: k8s.CoreV1Api;
  private server: Server;

  constructor() {
    this.k8sConfig = new k8s.KubeConfig();
    try {
      this.k8sConfig.loadFromDefault();
    } catch (error) {
      console.error("Warning: Could not load Kubernetes configuration.");
    }

    this.k8sAppsApi = this.k8sConfig.makeApiClient(k8s.AppsV1Api);
    this.k8sCoreApi = this.k8sConfig.makeApiClient(k8s.CoreV1Api);

    this.server = new Server(
      { name: "k-agent-logs", version: "1.0.0" },
      { capabilities: { tools: {}, resources: {} } }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "list_pods",
            description: "List all pods across namespaces with their status",
            inputSchema: {
              type: "object",
              properties: {
                namespace: { type: "string", description: "Optional: Filter by specific namespace" }
              }
            }
          },
          {
            name: "collect_pod_logs",
            description: "Collect logs from all containers in specified pods",
            inputSchema: {
              type: "object",
              properties: {
                namespace: { type: "string", description: "Namespace to collect logs from" },
                podName: { type: "string", description: "Specific pod name (optional)" },
                tailLines: { type: "number", description: "Number of log lines", default: 100 }
              },
              required: ["namespace"]
            }
          }
        ]
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      try {
        switch (name) {
          case "list_pods": return await this.handleListPods(args);
          case "collect_pod_logs": return await this.handleCollectPodLogs(args);
          default: throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
        }
      } catch (error) {
        throw new McpError(ErrorCode.InternalError, `Tool failed: ${error instanceof Error ? error.message : String(error)}`);
      }
    });
  }

  private async handleListPods(args: any) {
    const pods = await this.getPods(args?.namespace);
    const podList = pods.map(pod => ({
      name: pod.metadata?.name || 'unknown',
      namespace: pod.metadata?.namespace || 'unknown',
      status: pod.status?.phase || 'unknown',
      containers: pod.spec?.containers?.map(c => c.name) || []
    }));
    return { content: [{ type: "text", text: JSON.stringify(podList, null, 2) }] };
  }

  private async handleCollectPodLogs(args: any) {
    const { namespace, podName, tailLines = 100 } = args;
    if (!namespace) throw new Error("Namespace is required");
    const logs = await this.collectPodLogs(namespace, podName, tailLines);
    return { content: [{ type: "text", text: logs }] };
  }

  private async collectPodLogs(namespace: string, podName?: string, tailLines: number = 100): Promise<string> {
    const pods = podName
      ? await this.getPods(namespace).then(p => p.filter(pod => pod.metadata?.name === podName))
      : await this.getPods(namespace);
    const allLogs: string[] = [];
    for (const pod of pods) {
      if (!pod.metadata?.name) continue;
      for (const container of pod.spec?.containers || []) {
        try {
          const logs = await this.getPodLogs(namespace, pod.metadata.name, container.name, tailLines);
          allLogs.push(`=== ${pod.metadata.name}/${container.name} ===\n${logs}\n`);
        } catch (error) {
          allLogs.push(`=== ${pod.metadata.name}/${container.name} ===\nError: ${error instanceof Error ? error.message : String(error)}\n`);
        }
      }
    }
    return allLogs.join('\n');
  }

  private async getPods(namespace?: string): Promise<k8s.V1Pod[]> {
    try {
      if (namespace) {
        const response = await this.k8sCoreApi.listNamespacedPod({ namespace });
        return response.items || [];
      } else {
        const response = await this.k8sCoreApi.listPodForAllNamespaces();
        return response.items || [];
      }
    } catch (error) { throw this.handleK8sError(error); }
  }

  private async getPodLogs(namespace: string, podName: string, containerName: string, tailLines: number): Promise<string> {
    try {
      const response = await this.k8sCoreApi.readNamespacedPodLog({
        name: podName, namespace, container: containerName, tailLines, timestamps: true
      });
      return response || '';
    } catch (error) { throw this.handleK8sError(error); }
  }

  private handleK8sError(error: any): Error {
    if (error.response?.statusCode === 403) return new Error('Access denied');
    if (error.response?.statusCode === 404) return new Error('Resource not found');
    return new Error(`Kubernetes error: ${error.message}`);
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("K-Agent MCP server running on stdio");
  }
}

const server = new KAgentServer();
server.run().catch(console.error);
EOF

echo -e "${GREEN}✅ Source files created${NC}"
echo ""

# Step 6: Install dependencies
if [ "$SKIP_DEPS" = false ]; then
  echo -e "${BLUE}Step 6: Installing dependencies...${NC}"
  npm install
  echo -e "${GREEN}✅ Dependencies installed${NC}"
else
  echo -e "${YELLOW}Step 6: Skipping dependency installation${NC}"
fi
echo ""

# Step 7: Build project
echo -e "${BLUE}Step 7: Building project...${NC}"
if [ -d "node_modules" ]; then
  npm run build
  echo -e "${GREEN}✅ Project built successfully${NC}"
else
  echo -e "${YELLOW}⚠️  Skipping build (no node_modules)${NC}"
fi
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}✨ K-Agent Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🚀 Quick Start:"
echo "   cd $PROJECT_DIR"
echo ""
echo "   # Run in development mode"
echo "   npm run dev"
echo ""
echo "   # Open MCP Inspector"
echo "   npm run inspector"
echo ""
echo "   # Build for production"
echo "   npm run build"
echo "   npm start"
echo ""
echo "=========================================="
