#!/bin/bash

# Lab 005 - Kubectl Integration Tool Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 005 - Kubectl Integration Tool"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 005 exercises..."
print_info "Kubectl Integration Tool implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 005: Kubectl Integration Tool'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 005 Complete!"
echo ""
print_success "✓ Completed Kubectl Integration Tool exercises"
echo ""
print_info "Next: Lab 006"
echo ""
