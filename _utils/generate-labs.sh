#!/bin/bash

# =============================================================================
# K-Agent Labs - Generate Remaining Lab Structures
# =============================================================================
# This script creates the structure for labs 003-014
# =============================================================================

set -e

ROOT_DIR="/Users/orni/Code-Wizard/Kagent/Kagent_codewizard/Kagent/"
cd "$ROOT_DIR"

# Lab definitions (number, name, description)
declare -a LABS=(
    "003|python-server|Build Python MCP servers with FastMCP"
    "004|k8s-deploy|Deploy MCP servers to Kubernetes"
    "005|kubectl-tool|Create a kubectl integration tool"
    "006|cluster-inspector|Monitor cluster health and resources"
    "007|helm-tool|Integrate Helm for package management"
    "008|postgres-tool|Build database integration tools"
    "009|configmap-secrets|Manage K8s configurations and secrets"
    "010|mcp-remote|Set up remote MCP server communication"
    "011|gcp-gke|Deploy to Google Kubernetes Engine"
    "012|gcp-tools|Integrate Google Cloud SDK tools"
    "013|security-rbac|Implement security and RBAC"
    "014|production-ready|Production deployment and observability"
)

# Create lab directories and basic files
for lab_info in "${LABS[@]}"; do
    IFS='|' read -r num name desc <<< "$lab_info"
    
    LAB_DIR="Labs/${num}-${name}"
    mkdir -p "$LAB_DIR"
    
    echo "Creating $LAB_DIR..."
    
    # Create README.md
    cat > "$LAB_DIR/README.md" << 'EOF'
<a href="https://github.com/CodeWizard-IL/Kagent/actions/workflows/NUM-NAME.yaml" target="_blank">
  <img src="https://github.com/CodeWizard-IL/Kagent/actions/workflows/NUM-NAME.yaml/badge.svg" alt="Lab NUM-NAME">
</a>

---

# Lab NUM - DESC

**What you'll learn:**
- ${desc} concepts and architecture
- Hands-on implementation
- Best practices and patterns

**Estimated time:** 10-15 minutes

---

## Pre-Requirements

- Completed previous labs
- K-Agent labs environment running

---

## 01. Introduction

This lab covers ${desc,,}.

---

## 02. Key Concepts

[Content to be expanded based on lab focus]

---

## 03. Hands-on Exercise

### Exercise 1: Basic Setup

\`\`\`bash
# Connect to container
docker exec -it kagent-controller bash

# Navigate to labs directory
cd /labs-scripts
\`\`\`

### Exercise 2: Implementation

[Specific exercises for this lab]

---

## 04. Verification

Verify your implementation:

\`\`\`bash
# Run validation commands
\`\`\`

---

## 05. Key Takeaways

!!! success "What You Learned"
    - ✓ Core concepts of ${desc,,}
    - ✓ Hands-on implementation
    - ✓ Testing and validation

---

## 06. Next Steps

Continue to the next lab to build on these concepts.

---

<!-- Navigation Links -->
[Previous: Lab $(printf "%03d" $((10#$num - 1)))](../ $(printf "%03d" $((10#$num - 1)))-*/) | [Next: Lab $(printf "%03d" $((10#$num + 1)))](../$(printf "%03d" $((10#$num + 1)))-*/)
EOF

    # Create _demo.sh
    cat > "$LAB_DIR/_demo.sh" << EOF
#!/bin/bash

# =============================================================================
# Lab ${num} - ${desc} Demo Script
# =============================================================================

set -e

ROOT_FOLDER=\$(git rev-parse --show-toplevel)/
source "\$ROOT_FOLDER/_utils/common.sh"

print_header "Lab ${num} - ${desc}"

# Ensure labs environment is running
cd "\$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab ${num} exercises..."

# Lab-specific demonstrations
print_info "Lab ${num}: ${desc}"
print_info "Implementation in progress..."

# Summary
print_header "Lab ${num} Complete!"
echo ""
print_success "✓ Completed ${desc,,} exercises"
echo ""
print_info "Next: Lab $(printf "%03d" $((10#$num + 1)))"
echo ""
EOF

    chmod +x "$LAB_DIR/_demo.sh"
    
    echo "✓ Created $LAB_DIR"
done

echo ""
echo "All lab structures created successfully!"
echo "Labs can now be expanded with specific content."
