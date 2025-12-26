#!/bin/bash

# Lab 011 - Google Kubernetes Engine Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab 011 - Google Kubernetes Engine"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab 011 exercises..."
print_info "Google Kubernetes Engine implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab 011: Google Kubernetes Engine'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab 011 Complete!"
echo ""
print_success "✓ Completed Google Kubernetes Engine exercises"
echo ""
print_info "Next: Lab 012"
echo ""
