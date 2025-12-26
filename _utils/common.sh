#!/bin/bash

# =============================================================================
# K-Agent Labs - Common Utilities
# =============================================================================
# This script provides shared functions and variables for all lab scripts
# =============================================================================

# Color definitions for terminal output
export COLOR_OFF='\033[0m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'

# Bold colors
export BOLD_RED='\033[1;31m'
export BOLD_GREEN='\033[1;32m'
export BOLD_YELLOW='\033[1;33m'
export BOLD_BLUE='\033[1;34m'
export BOLD_CYAN='\033[1;36m'

# =============================================================================
# Directory Structure
# =============================================================================

# Get the root folder of the repository
export ROOT_FOLDER=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
export RUNTIME_FOLDER=${ROOT_FOLDER}/runtime
export LABS_SCRIPTS_FOLDER=${RUNTIME_FOLDER}/labs-scripts

# =============================================================================
# Print Functions
# =============================================================================

print_header() {
    echo -e "${BOLD_CYAN}============================================================${COLOR_OFF}"
    echo -e "${BOLD_CYAN}$1${COLOR_OFF}"
    echo -e "${BOLD_CYAN}============================================================${COLOR_OFF}"
}

print_info() {
    echo -e "${CYAN}ℹ  $1${COLOR_OFF}"
}

print_success() {
    echo -e "${BOLD_GREEN}✓  $1${COLOR_OFF}"
}

print_warning() {
    echo -e "${YELLOW}⚠  $1${COLOR_OFF}"
}

print_error() {
    echo -e "${BOLD_RED}✗  $1${COLOR_OFF}"
}

print_step() {
    echo -e "${BOLD_YELLOW}▶  $1${COLOR_OFF}"
}

# =============================================================================
# Docker Compose Compatibility
# =============================================================================

docker_compose() {
    # Check for Docker Compose V2 (docker compose)
    if docker compose version >/dev/null 2>&1; then
        docker compose "$@"
    # Fallback to Docker Compose V1 (docker-compose)
    elif command -v docker-compose >/dev/null 2>&1; then
        docker-compose "$@"
    else
        print_error "Docker Compose not found. Please install Docker Compose."
        return 1
    fi
}

# =============================================================================
# Platform Detection
# =============================================================================

detect_platform() {
    local OS=$(uname -s)
    local ARCH=$(uname -m)

    if [ "$OS" = "Darwin" ]; then
        # macOS - Check for ARM64 kernel
        if uname -v | grep -q 'RELEASE_ARM64'; then
            echo "linux/arm64"
        # Check for Rosetta translation
        elif sysctl -n sysctl.proc_translated 2>/dev/null | grep -q '1'; then
            echo "linux/arm64"
        else
            case $ARCH in
                "x86_64") echo "linux/amd64" ;;
                "arm64")  echo "linux/arm64" ;;
                *) 
                    print_error "Unsupported architecture: $ARCH"
                    exit 1
                    ;;
            esac
        fi
    else
        # Linux/other systems
        case $ARCH in
            "x86_64")  echo "linux/amd64" ;;
            "aarch64") echo "linux/arm64" ;;
            "arm64")   echo "linux/arm64" ;;
            *) 
                print_error "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
    fi
}

# =============================================================================
# Kubernetes Cluster Detection
# =============================================================================

detect_k8s_cluster() {
    # Check if kubectl is available
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "none"
        return 1
    fi

    # Get current context
    local CONTEXT=$(kubectl config current-context 2>/dev/null)
    
    if [ -z "$CONTEXT" ]; then
        echo "none"
        return 1
    fi

    # Detect cluster type based on context name
    case "$CONTEXT" in
        *minikube*)
            echo "minikube"
            ;;
        *kind*)
            echo "kind"
            ;;
        *k3*)
            echo "k3s"
            ;;
        *gke*|*google*)
            echo "gke"
            ;;
        docker-desktop)
            echo "docker-desktop"
            ;;
        *)
            # Try to detect from server URL
            local SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null)
            if [[ "$SERVER" == *"googleapis.com"* ]]; then
                echo "gke"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# =============================================================================
# Image Loading for Local Clusters
# =============================================================================

load_image_to_cluster() {
    local IMAGE_NAME=$1
    local CLUSTER_TYPE=$(detect_k8s_cluster)

    print_step "Loading image $IMAGE_NAME to $CLUSTER_TYPE cluster..."

    case "$CLUSTER_TYPE" in
        minikube)
            if command -v minikube >/dev/null 2>&1; then
                minikube image load "$IMAGE_NAME"
                print_success "Image loaded to Minikube"
            else
                print_error "Minikube command not found"
                return 1
            fi
            ;;
        kind)
            if command -v kind >/dev/null 2>&1; then
                kind load docker-image "$IMAGE_NAME"
                print_success "Image loaded to Kind"
            else
                print_error "Kind command not found"
                return 1
            fi
            ;;
        docker-desktop)
            print_info "Docker Desktop uses local images directly"
            ;;
        gke|unknown)
            print_info "Remote cluster detected - image must be in container registry"
            ;;
        none)
            print_error "No Kubernetes cluster detected"
            return 1
            ;;
    esac
}

# =============================================================================
# Wait for Deployment
# =============================================================================

wait_for_deployment() {
    local DEPLOYMENT_NAME=$1
    local NAMESPACE=${2:-default}
    local TIMEOUT=${3:-300}

    print_step "Waiting for deployment $DEPLOYMENT_NAME to be ready..."

    if kubectl wait --for=condition=available \
        --timeout=${TIMEOUT}s \
        deployment/$DEPLOYMENT_NAME \
        -n $NAMESPACE >/dev/null 2>&1; then
        print_success "Deployment $DEPLOYMENT_NAME is ready"
        return 0
    else
        print_error "Deployment $DEPLOYMENT_NAME failed to become ready"
        return 1
    fi
}

# =============================================================================
# Wait for Pod
# =============================================================================

wait_for_pod() {
    local POD_LABEL=$1
    local NAMESPACE=${2:-default}
    local TIMEOUT=${3:-300}

    print_step "Waiting for pod with label $POD_LABEL to be ready..."

    if kubectl wait --for=condition=ready \
        --timeout=${TIMEOUT}s \
        pod -l $POD_LABEL \
        -n $NAMESPACE >/dev/null 2>&1; then
        print_success "Pod with label $POD_LABEL is ready"
        return 0
    else
        print_error "Pod with label $POD_LABEL failed to become ready"
        return 1
    fi
}

# =============================================================================
# Cleanup Resources
# =============================================================================

cleanup_namespace() {
    local NAMESPACE=$1
    
    print_step "Cleaning up namespace $NAMESPACE..."
    
    kubectl delete all --all -n $NAMESPACE 2>/dev/null
    kubectl delete configmap --all -n $NAMESPACE 2>/dev/null
    kubectl delete secret --all -n $NAMESPACE 2>/dev/null
    
    print_success "Namespace $NAMESPACE cleaned up"
}

cleanup_cluster() {
    local CLUSTER_TYPE=$(detect_k8s_cluster)
    
    print_step "Cleaning up cluster resources..."
    
    # Delete all non-system namespaces
    kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | \
        tr ' ' '\n' | \
        grep -v '^kube-' | \
        grep -v '^default$' | \
        xargs -I {} kubectl delete namespace {} 2>/dev/null
    
    # Clean up default namespace
    cleanup_namespace default
    
    print_success "Cluster cleaned up"
}

# =============================================================================
# Build Docker Image
# =============================================================================

build_image() {
    local DOCKERFILE_PATH=$1
    local IMAGE_NAME=$2
    local BUILD_CONTEXT=${3:-.}
    local PLATFORM=$(detect_platform)

    print_step "Building image $IMAGE_NAME for platform $PLATFORM..."

    if docker build \
        --platform "$PLATFORM" \
        -f "$DOCKERFILE_PATH" \
        -t "$IMAGE_NAME" \
        "$BUILD_CONTEXT"; then
        print_success "Image $IMAGE_NAME built successfully"
        return 0
    else
        print_error "Failed to build image $IMAGE_NAME"
        return 1
    fi
}

# =============================================================================
# Check Prerequisites
# =============================================================================

check_command() {
    local CMD=$1
    local NAME=${2:-$CMD}
    
    if command -v "$CMD" >/dev/null 2>&1; then
        print_success "$NAME is installed"
        return 0
    else
        print_error "$NAME is not installed"
        return 1
    fi
}

check_prerequisites() {
    local ALL_OK=true
    
    print_header "Checking Prerequisites"
    
    check_command docker "Docker" || ALL_OK=false
    check_command kubectl "kubectl" || ALL_OK=false
    check_command helm "Helm" || ALL_OK=false
    check_command git "Git" || ALL_OK=false
    
    if [ "$ALL_OK" = true ]; then
        print_success "All prerequisites are met"
        return 0
    else
        print_error "Some prerequisites are missing"
        return 1
    fi
}

# =============================================================================
# Get Pod Name
# =============================================================================

get_pod_name() {
    local LABEL=$1
    local NAMESPACE=${2:-default}
    
    kubectl get pods -n $NAMESPACE -l $LABEL -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

# =============================================================================
# Execute in Pod
# =============================================================================

exec_in_pod() {
    local POD_NAME=$1
    local NAMESPACE=${2:-default}
    shift 2
    local COMMAND="$@"
    
    kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "$COMMAND"
}

# =============================================================================
# Port Forward
# =============================================================================

port_forward() {
    local RESOURCE=$1
    local PORTS=$2
    local NAMESPACE=${3:-default}
    
    print_info "Starting port-forward for $RESOURCE on ports $PORTS"
    print_info "Press Ctrl+C to stop"
    
    kubectl port-forward -n $NAMESPACE $RESOURCE $PORTS
}

# =============================================================================
# Export functions for use in other scripts
# =============================================================================

export -f docker_compose
export -f detect_platform
export -f detect_k8s_cluster
export -f load_image_to_cluster
export -f wait_for_deployment
export -f wait_for_pod
export -f cleanup_namespace
export -f cleanup_cluster
export -f build_image
export -f check_command
export -f check_prerequisites
export -f get_pod_name
export -f exec_in_pod
export -f port_forward
export -f print_header
export -f print_info
export -f print_success
export -f print_warning
export -f print_error
export -f print_step
