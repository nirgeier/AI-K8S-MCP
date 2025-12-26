<a href="https://github.com/CodeWizard-IL/Kagent/actions/workflows/000-setup.yaml" target="_blank">
  <img src="https://github.com/CodeWizard-IL/Kagent/actions/workflows/000-setup.yaml/badge.svg" alt="Lab 000-setup">
</a>

---

# Lab 000 - Environment Setup

Welcome to K-Agent Labs! In this first lab, you'll set up your development environment with all the tools needed for the K-Agent framework. This lab covers Docker, Kubernetes, and the K-Agent labs environment container.

**What you'll learn:**

- Install and configure required tools (Docker, kubectl, Helm)
- Build and run the K-Agent labs environment
- Verify Kubernetes cluster connectivity
- Test the MCP server setup

**Estimated time:** 15 minutes

---

## Pre-Requirements

- Linux, macOS, or Windows with WSL2
- At least 4GB RAM available for containers
- Internet connection for downloading tools

---

## 01. Prerequisites Installation

### Docker Installation

=== "macOS"

    ```bash
    # Install Docker Desktop
    brew install --cask docker
    
    # Start Docker Desktop from Applications
    # Or use command line:
    open /Applications/Docker.app
    ```

=== "Linux (Ubuntu/Debian)"

    ```bash
    # Update package index
    sudo apt-get update
    
    # Install Docker
    curl -fsSL https://get.docker.com | sh
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Restart session or run:
    newgrp docker
    ```

=== "GCP Cloud Shell"

    ```bash
    # Docker is pre-installed in Cloud Shell
    docker --version
    ```

### kubectl Installation

=== "macOS"

    ```bash
    brew install kubectl
    ```

=== "Linux"

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

=== "GCP Cloud Shell"

    ```bash
    # kubectl is pre-installed
    kubectl version --client
    ```

### Helm Installation

=== "macOS"

    ```bash
    brew install helm
    ```

=== "Linux / Cloud Shell"

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```

### Git Installation

=== "macOS"

    ```bash
    brew install git
    ```

=== "Linux"

    ```bash
    sudo apt-get install -y git
    ```

---

## 02. Clone the Repository

```bash
# Clone the K-Agent Labs repository
git clone https://github.com/CodeWizard-IL/Kagent.git

# Navigate to the labs directory
cd Kagent/
```

---

## 03. Setup Kubernetes Cluster

You need a Kubernetes cluster for these labs. Choose one of the following options:

### Option 1: Kind (Recommended for local development)

```bash
# Install Kind
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a Kind cluster
kind create cluster --name kagent-lab

# Verify cluster
kubectl cluster-info --context kind-kagent-lab
```

### Option 2: Minikube

```bash
# Install Minikube
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker --cpus=2 --memory=4096

# Verify cluster
kubectl cluster-info
```

### Option 3: Docker Desktop Kubernetes

```bash
# Enable Kubernetes in Docker Desktop:
# Docker Desktop → Settings → Kubernetes → Enable Kubernetes

# Verify cluster
kubectl config use-context docker-desktop
kubectl cluster-info
```

### Option 4: GKE (Google Kubernetes Engine)

```bash
# Create a GKE cluster (requires GCP account)
gcloud container clusters create kagent-lab \
    --zone=us-central1-a \
    --num-nodes=2 \
    --machine-type=e2-medium

# Get credentials
gcloud container clusters get-credentials kagent-lab --zone=us-central1-a

# Verify cluster
kubectl cluster-info
```

---

## 04. Build the K-Agent Labs Environment

The K-Agent labs environment is a Docker container with all tools pre-installed (Node.js, Python, kubectl, Helm, Docker CLI).

```bash
# Navigate to labs-environment directory
cd labs-environment

# Detect platform and create .env file
export TARGET_PLATFORM=$(uname -m | sed 's/x86_64/linux\/amd64/g' | sed 's/arm64/linux\/arm64/g' | sed 's/aarch64/linux\/arm64/g')
echo "TARGET_PLATFORM=$TARGET_PLATFORM" > .env
echo "ROOT_FOLDER=$(git rev-parse --show-toplevel)/" >> .env

# Create runtime directories
mkdir -p ../runtime/labs-scripts
mkdir -p ../runtime/.ssh

# Build the environment
docker compose build

# Start the container
docker compose up -d

# Check container status
docker compose ps
```

---

## 05. Verify Installation

Let's verify that everything is working correctly.

### Test Container Access

```bash
# Connect to the container
docker exec -it kagent-controller bash
```
```bash
# Inside the container, verify tools:
node --version
python --version
kubectl version --client
helm version
docker --version

# Exit container
exit
```

### Test Kubernetes Connectivity

```bash
# Copy kubeconfig to runtime directory (if needed)
mkdir -p $(git rev-parse --show-toplevel)//runtime/.kube
cp ~/.kube/config $(git rev-parse --show-toplevel)//runtime/.kube/config

# Test kubectl from container
docker exec kagent-controller kubectl get nodes
docker exec kagent-controller kubectl get pods -A
```

### Test MCP Server

```bash
# Build the MCP server
docker exec kagent-controller bash -c "cd /app && npm install && npm run build"

# The server is now ready for use in subsequent labs
```

---

## 06. Optional: Ollama Setup

Ollama is needed for AI-powered tools in later labs (012-013). It runs on your host machine.

!!! info "Ollama is Optional"
    You can skip this step and return to it later when needed.

### Install Ollama

=== "macOS"

    ```bash
    brew install ollama
    
    # Start Ollama service
    ollama serve
    ```

=== "Linux"

    ```bash
    curl -fsSL https://ollama.ai/install.sh | sh
    
    # Start Ollama service
    ollama serve
    ```

### Pull a Model

```bash
# In a new terminal, pull the qwen3-coder model (optimized for coding tasks)
ollama pull qwen3-coder:30b

# Verify
ollama list
```

### Test Connectivity from Container

```bash
# Test Ollama from container (using host network)
docker exec kagent-controller curl http://host.docker.internal:11434/api/tags

# On Linux, you may need to use:
docker exec kagent-controller curl http://172.17.0.1:11434/api/tags
```

---

## 07. Hands-on Exercise

Let's verify your setup by running a simple test.

**Exercise 1: Check Cluster Information**

```bash
# Use the utility scripts
cd $(git rev-parse --show-toplevel)/

# Initialize cluster
bash _utils/init-cluster.sh

# Check cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

**Exercise 2: Test Container Environment**

```bash
# Start labs environment if not running
cd labs-environment
docker compose up -d

# Execute commands in container
docker exec kagent-controller bash -c "
echo '=== Environment Check ==='
echo 'Node.js:' \$(node --version)
echo 'Python:' \$(python --version)
echo 'kubectl:' \$(kubectl version --client --short)
echo 'Helm:' \$(helm version --short)
echo '========================='
"
```

**Expected Output:**
```
=== Environment Check ===
Node.js: v18.x.x
Python: Python 3.10.x
kubectl: Client Version: v1.28.x
Helm: v3.13.x
=========================
```

---

## 08. Troubleshooting

!!! warning "Container Won't Start"
    If the container fails to start, check:
    ```bash
    docker compose logs
    docker images | grep kagent
    docker ps -a
    ```

!!! warning "Kubectl Not Working in Container"
    If kubectl commands fail in the container:
    ```bash
    # Verify kubeconfig is mounted correctly
    docker exec kagent-controller ls -la /root/.kube/
    
    # Try copying kubeconfig again
    cp ~/.kube/config $(git rev-parse --show-toplevel)//runtime/.kube/config
    
    # Restart container
    cd labs-environment
    docker compose restart
    ```

!!! warning "Platform Issues (M1/M2 Mac)"
    If you encounter platform errors:
    ```bash
    # Verify platform in .env file
    cat labs-environment/.env
    
    # Should show: TARGET_PLATFORM=linux/arm64
    # If not, update it manually
    ```

---

## 09. Cleanup (Optional)

To clean up your environment:

```bash
# Stop and remove containers
cd labs-environment
docker compose down

# Remove images (optional)
docker rmi kagent-lab-environment:latest

# Delete Kind cluster (if using Kind)
kind delete cluster --name kagent-lab

# Delete Minikube cluster (if using Minikube)
minikube delete
```

---

## 10. Next Steps

Congratulations! Your K-Agent labs environment is ready.

**What's next:**
- [Lab 001 - MCP Basics](../001-mcp-basics/) - Learn about the Model Context Protocol
- Understanding MCP tools and communication patterns
- Building your first MCP tool

---

<!-- Navigation Links -->
[Previous: Welcome](../welcome/) | [Next: Lab 001 - MCP Basics](../001-mcp-basics/)
