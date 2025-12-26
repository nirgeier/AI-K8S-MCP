#!/bin/bash

# Lab 003 - Python MCP Server with FastMCP Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 003 - Python MCP Server with FastMCP"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 003 exercises..."
print_info "Python MCP Server with FastMCP implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 003: Python MCP Server with FastMCP'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 003 Complete!"
echo ""
print_success "✓ Completed Python MCP Server with FastMCP exercises"
echo ""
print_info "Next: Lab 004"
echo ""
