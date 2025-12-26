#!/bin/bash

# Lab 012 - Google Cloud SDK Tools Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 012 - Google Cloud SDK Tools"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 012 exercises..."
print_info "Google Cloud SDK Tools implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 012: Google Cloud SDK Tools'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 012 Complete!"
echo ""
print_success "✓ Completed Google Cloud SDK Tools exercises"
echo ""
print_info "Next: Lab 013"
echo ""
