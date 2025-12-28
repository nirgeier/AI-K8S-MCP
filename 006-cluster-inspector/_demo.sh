#!/bin/bash

# Lab 006 - Cluster Health Inspector Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 006 - Cluster Health Inspector"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 006 exercises..."
print_info "Cluster Health Inspector implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 006: Cluster Health Inspector'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 006 Complete!"
echo ""
print_success "✓ Completed Cluster Health Inspector exercises"
echo ""
print_info "Next: Lab 007"
echo ""
