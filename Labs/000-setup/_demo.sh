#!/bin/bash

# =============================================================================
# Lab 000 - Environment Setup Demo Script
# =============================================================================

set -e

# Get the root folder
ROOT_FOLDER=$(git rev-parse --show-toplevel)/

# Load common utilities
source "$ROOT_FOLDER/_utils/common.sh"

# =============================================================================
# Main Demo
# =============================================================================

print_header "Lab 000 - Environment Setup"

# Step 1: Check prerequisites
print_step "Step 1: Checking prerequisites..."
check_prerequisites

# Step 2: Initialize cluster
print_step "Step 2: Initializing Kubernetes cluster..."
source "$ROOT_FOLDER/_utils/init-cluster.sh"

# Step 3: Build labs environment
print_step "Step 3: Building K-Agent labs environment..."
cd "$ROOT_FOLDER/labs-environment"

# Create .env file
export TARGET_PLATFORM=$(detect_platform)
echo "TARGET_PLATFORM=$TARGET_PLATFORM" > .env
echo "ROOT_FOLDER=$ROOT_FOLDER" >> .env

print_info "Platform: $TARGET_PLATFORM"

# Create runtime directories
mkdir -p "$ROOT_FOLDER/runtime/labs-scripts"
mkdir -p "$ROOT_FOLDER/runtime/.ssh"
mkdir -p "$ROOT_FOLDER/runtime/.kube"

# Copy kubeconfig if exists
if [ -f "$HOME/.kube/config" ]; then
    cp "$HOME/.kube/config" "$ROOT_FOLDER/runtime/.kube/config"
    print_success "Kubeconfig copied"
fi

# Build and start container
print_info "Building Docker image..."
docker_compose build

print_info "Starting container..."
docker_compose up -d

# Wait for container to be ready
print_info "Waiting for container to be ready..."
sleep 5

# Step 4: Verify installation
print_step "Step 4: Verifying installation..."

# Check container status
if docker_compose ps | grep -q "Up"; then
    print_success "Container is running"
else
    print_error "Container is not running"
    exit 1
fi

# Verify tools in container
print_info "Checking tools in container..."
docker exec kagent-controller bash -c "
echo '=== Tool Versions ==='
echo 'Node.js:' \$(node --version)
echo 'npm:' \$(npm --version)
echo 'Python:' \$(python --version)
echo 'kubectl:' \$(kubectl version --client --short 2>/dev/null || echo 'N/A')
echo 'Helm:' \$(helm version --short 2>/dev/null || echo 'N/A')
echo 'Docker:' \$(docker --version 2>/dev/null || echo 'N/A')
echo '===================='
"

# Test kubectl connectivity
print_info "Testing kubectl connectivity..."
if docker exec kagent-controller kubectl cluster-info >/dev/null 2>&1; then
    print_success "kubectl can connect to cluster"
    docker exec kagent-controller kubectl get nodes
else
    print_warning "kubectl cannot connect to cluster (kubeconfig may not be mounted)"
fi

# Step 5: Build MCP server
print_step "Step 5: Building MCP server..."
docker exec kagent-controller bash -c "cd /app && npm install && npm run build"

if docker exec kagent-controller test -f /app/build/index.js; then
    print_success "MCP server built successfully"
else
    print_error "MCP server build failed"
    exit 1
fi

# Summary
print_header "Setup Complete!"
echo ""
print_success "✓ Prerequisites checked"
print_success "✓ Kubernetes cluster initialized"
print_success "✓ Labs environment container running"
print_success "✓ Tools verified"
print_success "✓ MCP server built"
echo ""
print_info "You can now proceed to Lab 001 - MCP Basics"
print_info ""
print_info "Useful commands:"
print_info "  - Connect to container: docker exec -it kagent-controller bash"
print_info "  - Check logs: docker compose logs -f"
print_info "  - Stop container: docker compose down"
echo ""
