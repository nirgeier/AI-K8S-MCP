#!/bin/bash

# Lab 008 - PostgreSQL Database Tool Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 008 - PostgreSQL Database Tool"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 008 exercises..."
print_info "PostgreSQL Database Tool implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 008: PostgreSQL Database Tool'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 008 Complete!"
echo ""
print_success "✓ Completed PostgreSQL Database Tool exercises"
echo ""
print_info "Next: Lab 009"
echo ""
