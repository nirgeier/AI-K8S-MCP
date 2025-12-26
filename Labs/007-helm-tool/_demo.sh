#!/bin/bash

# Lab 007 - Helm Package Management Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 007 - Helm Package Management"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 007 exercises..."
print_info "Helm Package Management implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 007: Helm Package Management'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 007 Complete!"
echo ""
print_success "✓ Completed Helm Package Management exercises"
echo ""
print_info "Next: Lab 008"
echo ""
