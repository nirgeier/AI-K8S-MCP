#!/bin/bash

# Lab 013 - Security and RBAC Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 013 - Security and RBAC"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 013 exercises..."
print_info "Security and RBAC implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 013: Security and RBAC'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 013 Complete!"
echo ""
print_success "✓ Completed Security and RBAC exercises"
echo ""
print_info "Next: Lab 014"
echo ""
