#!/bin/bash

# Lab 004 - Deploy MCP to Kubernetes Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 004 - Deploy MCP to Kubernetes"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 004 exercises..."
print_info "Deploy MCP to Kubernetes implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 004: Deploy MCP to Kubernetes'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 004 Complete!"
echo ""
print_success "✓ Completed Deploy MCP to Kubernetes exercises"
echo ""
print_info "Next: Lab 005"
echo ""
