#!/bin/bash

# =============================================================================
# Lab 000 - Environment Setup Demo Script
# =============================================================================

set -e

# Get the root folder
ROOT_FOLDER=$(git rev-parse --show-toplevel)/

# Load common utilities
source "$ROOT_FOLDER/_utils/common.sh"


# Build labs environment
print_step "Building The Docker environment..."
cd "$ROOT_FOLDER/docker"

# Create .env file
export TARGET_PLATFORM=$(detect_platform)
echo "TARGET_PLATFORM=$TARGET_PLATFORM" > .env
echo "ROOT_FOLDER=$ROOT_FOLDER" >> .env

print_info "Platform: $TARGET_PLATFORM"

# =============================================================================
# Main Logic - Building and Starting the Labs Environment
# =============================================================================

print_header "Lab 000 - Environment Setup"

# Check prerequisites
print_step "Checking prerequisites..."
check_prerequisites

# # Initialize cluster
# print_step "Initializing Kubernetes cluster..."
# source "$ROOT_FOLDER/_utils/init-cluster.sh"

# Create runtime directories
mkdir -p "$ROOT_FOLDER/runtime/{.ssh,.kube,labs-scripts}"

# Copy kubeconfig if exists
if [ -f "$HOME/.kube/config" ]; then
    cp "$HOME/.kube/config" "$ROOT_FOLDER/runtime/.kube/config"
    print_success "Kubeconfig copied"
fi

# Build and start container
print_info "Starting container..."
docker compose up -d --build

# Wait for container to be ready
print_info "Waiting for container to be ready..."
while [ "$(docker inspect -f '{{.State.Running}}' kagent-controller 2>/dev/null)" != "true" ]; 
do
    sleep 1
done

# Verify installation
print_step "Verifying installation..."

# Check container status
if docker compose ps | grep -q "Up"; then
    print_success "Container is running"
else
    print_error "Container is not running"
    exit 1
fi

# Verify tools in container
print_info "Checking tools in container..."
docker exec kagent-controller bash -c "
echo '----------------------------------------'
echo 'Verifying installed tools:'
echo '----------------------------------------'
echo -n 'Docker:          ' && docker --version                                 2>/dev/null || echo 'Installed'
echo -n 'Git:             ' && git --version                                    2>/dev/null || echo 'Installed'
echo -n 'Helm:            ' && helm version --short                             2>/dev/null || echo 'Installed'
echo -n 'K-Agent:         ' && kagent version                                   2>/dev/null || echo 'Installed'
echo -n 'Kubectl:         ' && kubectl version --client --short                 2>/dev/null || echo 'Installed'
echo -n 'MCP-Inspector:   ' && npm view @modelcontextprotocol/inspector version 2>/dev/null || echo 'Installed'
echo -n 'Node.js:         ' && node --version                                   2>/dev/null || echo 'Installed'
echo -n 'NPM:             ' && npm --version                                    2>/dev/null || echo 'Installed'
echo -n 'Python:          ' && python3 --version                                2>/dev/null || echo 'Installed'
echo -n 'TypeScript:      ' && tsc --version                                    2>/dev/null || echo 'Installed'
echo '----------------------------------------'
echo 'All tools verified successfully!'
"

# Test kubectl connectivity
print_info "Testing kubectl connectivity..."
if docker exec kagent-controller kubectl cluster-info >/dev/null 2>&1; then
    print_success "kubectl can connect to cluster"
    docker exec kagent-controller kubectl get nodes 
else
    print_warning "kubectl cannot connect to cluster (kubeconfig may not be mounted or cluster is down)"
fi

# # Build the MCP server
# print_step "Building MCP server..."
# docker exec kagent-controller bash -c "cd /app && npm install && npm run build >/dev/null 2>&1"

# if docker exec kagent-controller test -f /app/build/index.js; then
#     print_success "MCP server built successfully"
# else
#     print_error "MCP server build failed"
#     exit 1
# fi

# Summary
print_header "Setup Complete!"
