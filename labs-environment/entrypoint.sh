#!/bin/bash

# =============================================================================
# K-Agent Labs Environment - Entrypoint Script
# =============================================================================

set -e

# =============================================================================
# Generate SSH Key if not exists
# =============================================================================

if [ ! -f /root/.ssh/id_rsa ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -C "kagent-lab@localhost"
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "SSH key generated"
fi

# =============================================================================
# Start SSH Server
# =============================================================================

echo "Starting SSH server..."
/usr/sbin/sshd

# =============================================================================
# Configure kubectl if kubeconfig exists
# =============================================================================

if [ -f /root/.kube/config ]; then
    echo "Kubeconfig found, testing connectivity..."
    if kubectl cluster-info >/dev/null 2>&1; then
        echo "✓ Kubernetes cluster is accessible"
        kubectl get nodes 2>/dev/null | head -5 || true
    else
        echo "⚠ Kubeconfig found but cluster not accessible"
    fi
else
    echo "ℹ No kubeconfig found at /root/.kube/config"
    echo "  Mount your kubeconfig to enable kubectl access"
fi

# =============================================================================
# Display environment information
# =============================================================================

echo ""
echo "==============================================="
echo "K-Agent Labs Environment Ready"
echo "==============================================="
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python --version)"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'N/A')"
echo "Helm: $(helm version --short 2>/dev/null || echo 'N/A')"
echo "Docker: $(docker --version 2>/dev/null || echo 'N/A')"
echo "==============================================="
echo "Working Directory: $(pwd)"
echo "==============================================="
echo ""

# =============================================================================
# Execute command or start bash
# =============================================================================

if [ $# -eq 0 ]; then
    # No command provided, start interactive bash
    exec bash
else
    # Execute provided command
    exec "$@"
fi
