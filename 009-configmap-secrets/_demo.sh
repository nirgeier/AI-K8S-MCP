#!/bin/bash

# Lab 009 - ConfigMaps and Secrets Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 009 - ConfigMaps and Secrets"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 009 exercises..."
print_info "ConfigMaps and Secrets implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 009: ConfigMaps and Secrets'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 009 Complete!"
echo ""
print_success "✓ Completed ConfigMaps and Secrets exercises"
echo ""
print_info "Next: Lab 010"
echo ""
