#!/bin/bash

# =============================================================================
# K-Agent Labs - Cluster Initialization
# =============================================================================
# This script detects and initializes the appropriate Kubernetes cluster
# =============================================================================

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# Functions
# =============================================================================

start_minikube() {
    print_step "Starting Minikube cluster..."
    
    if minikube status >/dev/null 2>&1; then
        print_info "Minikube is already running"
    else
        minikube start --driver=docker --cpus=2 --memory=4096
        print_success "Minikube started successfully"
    fi
    
    # Set context
    kubectl config use-context minikube
    print_success "Kubectl context set to minikube"
}

start_kind() {
    print_step "Starting Kind cluster..."
    
    local CLUSTER_NAME="kagent-lab"
    
    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        print_info "Kind cluster '${CLUSTER_NAME}' already exists"
    else
        kind create cluster --name "${CLUSTER_NAME}"
        print_success "Kind cluster '${CLUSTER_NAME}' created successfully"
    fi
    
    # Set context
    kubectl config use-context "kind-${CLUSTER_NAME}"
    print_success "Kubectl context set to kind-${CLUSTER_NAME}"
}

start_docker_desktop() {
    print_step "Checking Docker Desktop Kubernetes..."
    
    # Check if Kubernetes is enabled in Docker Desktop
    if kubectl config get-contexts docker-desktop >/dev/null 2>&1; then
        kubectl config use-context docker-desktop
        print_success "Using Docker Desktop Kubernetes"
    else
        print_error "Docker Desktop Kubernetes is not enabled"
        print_info "Please enable Kubernetes in Docker Desktop settings"
        return 1
    fi
}

check_gke() {
    print_step "Checking GKE cluster..."
    
    local CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")
    
    if [[ "$CURRENT_CONTEXT" == *"gke"* ]] || [[ "$CURRENT_CONTEXT" == *"google"* ]]; then
        print_success "Using GKE cluster: $CURRENT_CONTEXT"
        
        # Verify connectivity
        if kubectl cluster-info >/dev/null 2>&1; then
            print_success "GKE cluster is accessible"
        else
            print_error "Cannot connect to GKE cluster"
            return 1
        fi
    else
        print_error "No GKE cluster configured"
        print_info "Please configure GKE cluster using: gcloud container clusters get-credentials <cluster-name>"
        return 1
    fi
}

init_k3s() {
    print_step "Checking K3s cluster..."
    
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        print_success "Using K3s cluster"
    else
        print_error "K3s is not installed"
        print_info "Install K3s: curl -sfL https://get.k3s.io | sh -"
        return 1
    fi
}

detect_and_init_cluster() {
    print_header "Kubernetes Cluster Initialization"
    
    # Check if a cluster is already configured
    local CURRENT_CLUSTER=$(detect_k8s_cluster)
    
    case "$CURRENT_CLUSTER" in
        minikube)
            print_info "Minikube cluster detected"
            start_minikube
            ;;
        kind)
            print_info "Kind cluster detected"
            # Kind cluster already exists, just verify
            kubectl cluster-info >/dev/null 2>&1 || start_kind
            ;;
        docker-desktop)
            print_info "Docker Desktop cluster detected"
            start_docker_desktop
            ;;
        gke)
            print_info "GKE cluster detected"
            check_gke
            ;;
        k3s)
            print_info "K3s cluster detected"
            init_k3s
            ;;
        none|unknown)
            # No cluster detected, try to start one
            print_info "No Kubernetes cluster detected, attempting to start one..."
            
            if command -v kind >/dev/null 2>&1; then
                print_info "Found Kind, using it for local cluster"
                start_kind
            elif command -v minikube >/dev/null 2>&1; then
                print_info "Found Minikube, using it for local cluster"
                start_minikube
            elif kubectl config get-contexts docker-desktop >/dev/null 2>&1; then
                print_info "Found Docker Desktop, using it for local cluster"
                start_docker_desktop
            else
                print_error "No Kubernetes cluster available"
                print_info "Please install one of: Kind, Minikube, or enable Docker Desktop Kubernetes"
                return 1
            fi
            ;;
    esac
    
    # Verify cluster is accessible
    print_step "Verifying cluster connectivity..."
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "Cluster is accessible"
        
        # Display cluster info
        echo ""
        print_info "Cluster Information:"
        kubectl cluster-info | head -3
        echo ""
        print_info "Current Context: $(kubectl config current-context)"
        print_info "Cluster Type: $(detect_k8s_cluster)"
        echo ""
    else
        print_error "Cannot connect to Kubernetes cluster"
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parse arguments
    local FORCE_TYPE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minikube)
                FORCE_TYPE="minikube"
                shift
                ;;
            --kind)
                FORCE_TYPE="kind"
                shift
                ;;
            --docker-desktop)
                FORCE_TYPE="docker-desktop"
                shift
                ;;
            --gke)
                FORCE_TYPE="gke"
                shift
                ;;
            --k3s)
                FORCE_TYPE="k3s"
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --minikube        Force use of Minikube"
                echo "  --kind            Force use of Kind"
                echo "  --docker-desktop  Force use of Docker Desktop"
                echo "  --gke             Force use of GKE"
                echo "  --k3s             Force use of K3s"
                echo "  --help, -h        Show this help message"
                echo ""
                echo "If no option is specified, the script will auto-detect the cluster type."
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Force specific cluster type if requested
    if [ -n "$FORCE_TYPE" ]; then
        case "$FORCE_TYPE" in
            minikube)
                start_minikube
                ;;
            kind)
                start_kind
                ;;
            docker-desktop)
                start_docker_desktop
                ;;
            gke)
                check_gke
                ;;
            k3s)
                init_k3s
                ;;
        esac
    else
        detect_and_init_cluster
    fi
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
