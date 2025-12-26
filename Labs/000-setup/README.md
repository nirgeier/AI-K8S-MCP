<a href="https://github.com/CodeWizard-IL/Kagent/actions/workflows/000-setup.yaml" target="_blank">
  <img src="https://github.com/CodeWizard-IL/Kagent/actions/workflows/000-setup.yaml/badge.svg" alt="Lab 000-setup">
</a>

---

# Lab 000 - Environment Setup

* Welcome to `K-Agent` Labs! 
* In this first lab, you'll set up your development environment with all the tools needed for the `K-Agent` infrastructure. 
* This lab covers `Docker`, `Kubernetes`, and the `K-Agent` labs environment container.

---

<img src="../assets/images/tldr.png" style="width:100px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">


<div class="grid cards" markdown style="text-align: center;border-radius: 20px;">

- ![](../assets/images/docker.png)
  ```bash
  cd docker && docker-compose up -d
  ```

- ![](../assets/images/killercoda.png){: .height-64px}<br/><br/>
  <a target="_blank" href="https://killercoda.com/codewizard/scenario/Kagent">Launch on KillerCoda</a>

</div>

---

#### What you'll learn in this lab:

- Install and configure required tools (Docker, kubectl, Helm, Ollama, MCP Inspector, K-Agent etc.)
- Build and run the K-Agent labs environment (Docker container or locally)
- Verify Kubernetes cluster connectivity 
- Prepare the MCP server setup

---

## Pre-Requirements

  | Tool Name                | CentOS                                           | Windows                                                      |
  | :----------------------- | :----------------------------------------------- | :----------------------------------------------------------- |
  | **Visual Studio Code**   | `sudo yum install code`                          | [Download Installer](https://code.visualstudio.com/)         |
  | **Python 3**             | `sudo yum install python3`                       | [Download Installer](https://www.python.org/)                |
  | **Node.js**              | `sudo yum install -y nodejs`                     | [Download Installer](https://nodejs.org/)                    |
  | **Git**                  | `sudo yum install git`                           | [Download Installer](https://git-scm.com/)                   |
  | **Docker**               | `sudo yum install docker-ce`                     | [Download Docker Desktop](https://www.docker.com/)           |
  | **Kubernetes (kubectl)** | `sudo yum install -y kubectl`                    | [Installation Docs](https://kubernetes.io/docs/tasks/tools/) |
  | **Ollama**               | `curl -fsSL https://ollama.com/install.sh \| sh` | [Download Installer](https://ollama.ai/)                     |
  | **MCP Inspector**        | `npm install -g @modelcontextprotocol/inspector` | `npm install -g @modelcontextprotocol/inspector`             |

---

## 01. Prerequisites Installation

### 🐳 Docker Installation

=== " macOS"

    ```bash
    # Install Docker Desktop
    brew install --cask docker
    
    # Start Docker Desktop from Applications
    # Or use command line:
    open /Applications/Docker.app
    ```

=== "🐧 Linux (Ubuntu/Debian)"

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

=== "🐧 Linux (CentOS)"

    ```bash
    # Set up the repository
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    # Install Docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    # Start Docker
    sudo systemctl start docker
    # Add user to docker group
    sudo usermod -aG docker $USER
    # Restart session or run:
    newgrp docker

    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # Docker is pre-installed in Cloud Shell
    docker --version
    ```

### ☸️ kubectl Installation

=== " macOS"

    ```bash
    brew install kubectl
    ```

=== "🐧 Linux (Ubuntu/Debian)"

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

=== "🐧 Linux (CentOS)"

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # kubectl is pre-installed
    kubectl version --client
    ```

### ⚓ Helm Installation

=== " macOS"

    ```bash
    brew install helm
    ```

=== "🐧 Linux (Ubuntu/Debian)"

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```

=== "🐧 Linux (CentOS)"

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # Helm is pre-installed
    helm version
    ```

### 🐙 Git Installation

=== " macOS"

    ```bash
    brew install git
    ```

=== "🐧 Linux (Ubuntu/Debian)"

    ```bash
    sudo apt-get install -y git
    ```

=== "🐧 Linux (CentOS)"

    ```bash
    sudo yum install -y git
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # Git is pre-installed
    git --version
    ```

### 🐍 Python3 Installation

=== " macOS"

    ```bash
    brew install python
    ``` 

=== "🐧 Linux (Ubuntu/Debian)"

    ```bash
    sudo apt-get install -y python3 python3-pip
    ```

=== "🐧 Linux (CentOS)"

    ```bash
    sudo yum install -y python3 python3-pip
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # Python3 is pre-installed
    python3 --version
    ```

### 📦 Node.js Installation

=== " macOS"

    ```bash
    brew install node
    ```

=== "🐧 Linux (Ubuntu/Debian)"
    ```bash
    sudo apt-get install -y nodejs npm
    ``` 

=== "🐧 Linux (CentOS)"

    ```bash
    sudo yum install -y nodejs npm
    ```
=== "☁️ GCP Cloud Shell"

    ```bash
    # Node.js is pre-installed
    node --version
    ```
 
### 🤖 Ollama Installation

=== " macOS"

    ```bash
    brew install ollama
    
    # Start Ollama service
    ollama serve
    ``` 
=== "🐧 Linux (Ubuntu/Debian)"
    ```bash
    curl -fsSL https://ollama.ai/install.sh | sh
    
    # Start Ollama service
    ollama serve
    ```
=== "🐧 Linux (CentOS)"
    ```bash
    curl -fsSL https://ollama.ai/install.sh | sh

    # Start Ollama service
    ollama serve
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    # Ollama is not supported in Cloud Shell
    echo "Ollama is not supported in Cloud Shell"
    ```
    
### 🔍 MCP Inspector Installation

=== " macOS"

    ```bash
    npm install -g @modelcontextprotocol/inspector
    ```

=== "🐧 Linux (Ubuntu/Debian)"
    ```bash
    npm install -g @modelcontextprotocol/inspector
    ```

=== "🐧 Linux (CentOS)"
    ```bash
    npm install -g @modelcontextprotocol/inspector
    ```

=== "☁️ GCP Cloud Shell"
    ```bash
    npm install -g @modelcontextprotocol/inspector
    ``` 

### Kubernetes Cluster Setup (minikube)

=== " macOS"

    ```bash
    brew install minikube
    ``` 
=== "🐧 Linux (Ubuntu/Debian)"
    ```bash
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    ``` 
=== "🐧 Linux (CentOS)"
    ```bash
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    ```
=== "☁️ GCP Cloud Shell"

    ```bash
    # Minikube is already installed in Cloud Shell
    minikube version
    ```

### Kubernetes Cluster Setup (kind)

=== " macOS"

    ```bash
    brew install kind
    ``` 

=== "🐧 Linux (Ubuntu/Debian)"
    ```bash
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    ```

=== "🐧 Linux (CentOS)"
    ```bash
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    ```

=== "☁️ GCP Cloud Shell"

    ```bash
    Kind is not supported in Cloud Shell - Use minikube instead
    ``` 

---

## 02. Verify Tools Installation

* Verify that all the tools are installed
```bash
# Verify Docker
docker --version
# Verify kubectl
kubectl version --client
# Verify Helm
helm version
# Verify Git
git --version
# Verify Python3
python3 --version
# Verify Node.js
node --version
# Verify Ollama (if installed)
ollama --version
# Verify MCP Inspector
mcp-inspector --version 
# Verify Kind (if installed)
kind --version
# Verify Minikube (if installed)
minikube version
# Verify Cluster Info (if cluster is running)
kubectl cluster-info
```

---

## 03. Install the K-Agent 

* The `K-Agent` labs environment is the fundamental building block for all labs.
* Its an Open Source framework to write MCP tools and interact with Kubernetes clusters.

=== " macOS" 
    ```bash
    brew install kagent
    ```
=== "🐧 Linux (Ubuntu/Debian)" 
    ```bash
    curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
=== "🐧 Linux (CentOS)" 
    ```bash
    curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
    ```
=== "☁️ GCP Cloud Shell" 
    ```bash
    curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
    ```

#### Verifty K-Agent Installation

  ```bash
  kagent version
  ```

---

## 04. Ollama Setup

* Ollama will be used as our LLLM model for the labs.
* Ollama is a local LLM server that allows you to run large language models on your machine.
* Ollama supports various models, for example: Qwen and Llama.
* We will ise the `qwen3-coder` model which is optimized for coding tasks or the `gpt-oos` model.  


!!! info "Pulling Models (Ollama)"
    * Pulling models can take a while depending on your internet speed and system performance.
    * You can skip this step and return to it later when needed.

#### Setup Ollama models

```bash
# Start Ollama service
ollama serve

# In a new terminal, pull the qwen3-coder model (optimized for coding tasks)
ollama pull qwen3-coder:30b

# Alternatively, pull the gpt-oos model
ollama pull gpt-oos:7b

# Verify
ollama list
```

### Pull a Model

```bash
# In a new terminal, pull the qwen3-coder model (optimized for coding tasks)
ollama pull qwen3-coder:30b

# Verify
ollama list
```

---

## 07. Hands-on Exercise

* Let's verify your setup by running a simple test.

#### Task 01: Check Cluster Information

  ```bash

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

