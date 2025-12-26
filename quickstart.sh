#!/bin/bash

# =============================================================================
# K-Agent Labs - Quick Start Script
# =============================================================================

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                    K-Agent Labs Quick Start                    ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Get the root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "📁 Working directory: $ROOT_DIR"
echo ""

# Step 1: Check prerequisites
echo "1️⃣  Checking prerequisites..."
echo ""

MISSING=""

if ! command -v docker &> /dev/null; then
    echo "   ❌ Docker not found"
    MISSING="docker $MISSING"
else
    echo "   ✅ Docker found: $(docker --version | head -1)"
fi

if ! command -v kubectl &> /dev/null; then
    echo "   ❌ kubectl not found"
    MISSING="kubectl $MISSING"
else
    echo "   ✅ kubectl found: $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"
fi

if ! command -v git &> /dev/null; then
    echo "   ❌ Git not found"
    MISSING="git $MISSING"
else
    echo "   ✅ Git found: $(git --version)"
fi

echo ""

if [ -n "$MISSING" ]; then
    echo "⚠️  Missing tools: $MISSING"
    echo ""
    echo "Please install missing tools and try again."
    echo "See Labs/000-setup/README.md for installation instructions."
    exit 1
fi

# Step 2: Setup environment
echo "2️⃣  Setting up labs environment..."
echo ""

cd labs-environment

# Detect platform
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    TARGET_PLATFORM="linux/amd64"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    TARGET_PLATFORM="linux/arm64"
else
    echo "   ⚠️  Unknown architecture: $ARCH, using linux/amd64"
    TARGET_PLATFORM="linux/amd64"
fi

echo "   📦 Platform: $TARGET_PLATFORM"

# Create .env file
echo "TARGET_PLATFORM=$TARGET_PLATFORM" > .env
echo "ROOT_FOLDER=$ROOT_DIR" >> .env

echo "   ✅ Environment configured"
echo ""

# Step 3: Create runtime directories
echo "3️⃣  Creating runtime directories..."
echo ""

mkdir -p "$ROOT_DIR/runtime/labs-scripts"
mkdir -p "$ROOT_DIR/runtime/.ssh"
mkdir -p "$ROOT_DIR/runtime/.kube"

# Copy kubeconfig if exists
if [ -f "$HOME/.kube/config" ]; then
    cp "$HOME/.kube/config" "$ROOT_DIR/runtime/.kube/config"
    echo "   ✅ Copied kubeconfig"
else
    echo "   ℹ️  No kubeconfig found at ~/.kube/config"
fi

echo ""

# Step 4: Build and start container
echo "4️⃣  Building labs environment (this may take a few minutes)..."
echo ""

if docker compose build; then
    echo "   ✅ Build completed successfully"
else
    echo "   ❌ Build failed"
    exit 1
fi

echo ""
echo "5️⃣  Starting labs environment..."
echo ""

if docker compose up -d; then
    echo "   ✅ Container started"
else
    echo "   ❌ Failed to start container"
    exit 1
fi

# Wait for container to be ready
echo ""
echo "   ⏳ Waiting for container to be ready..."
sleep 5

# Check container status
if docker compose ps | grep -q "Up"; then
    echo "   ✅ Container is running"
else
    echo "   ❌ Container is not running"
    docker compose logs
    exit 1
fi

cd "$ROOT_DIR"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                   ✅ Setup Complete! ✅                         ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "🎉 K-Agent Labs environment is ready!"
echo ""
echo "📚 Next steps:"
echo ""
echo "   1. Run Lab 000 (Environment Setup):"
echo "      cd Labs/000-setup && bash _demo.sh"
echo ""
echo "   2. Run Lab 001 (MCP Basics):"
echo "      cd Labs/001-mcp-basics && bash _demo.sh"
echo ""
echo "   3. Connect to the container:"
echo "      docker exec -it kagent-controller bash"
echo ""
echo "   4. View documentation:"
echo "      cd mkdocs && bash scripts/init_site.sh --serve"
echo ""
echo "   5. Stop the environment:"
echo "      cd labs-environment && docker compose down"
echo ""
echo "📖 Full documentation: https://codewizard-il.github.io/Kagent/"
echo ""
echo "Happy learning! 🚀"
echo ""
