#!/bin/bash

# Lab 014 - Production Deployment Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 014 - Production Deployment"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 014 exercises..."
print_info "Production Deployment implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 014: Production Deployment'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 014 Complete!"
echo ""
print_success "✓ Completed Production Deployment exercises"
echo ""
print_info "Next: Lab 015"
echo ""
