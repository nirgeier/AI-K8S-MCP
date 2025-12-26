# K-Agent Labs

> Comprehensive hands-on labs for learning the K-Agent framework, Model Context Protocol (MCP), and Kubernetes integration.

[![Deploy MKdocs](https://github.com/CodeWizard-IL/Kagent/actions/workflows/deploy-mkdocs.yml/badge.svg)](https://github.com/CodeWizard-IL/Kagent/actions/workflows/deploy-mkdocs.yml)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/CodeWizard-IL/Kagent.git
cd Kagent/

# Build and start the labs environment
cd labs-environment
export TARGET_PLATFORM=$(uname -m | sed 's/x86_64/linux\/amd64/g' | sed 's/arm64/linux\/arm64/g')
echo "TARGET_PLATFORM=$TARGET_PLATFORM" > .env
echo "ROOT_FOLDER=$(pwd)/.." >> .env
docker compose up -d

# Start with Lab 000
cd ../Labs/000-setup
bash _demo.sh
```

## 📚 Labs Overview

| Lab | Title | Duration | Status |
|-----|-------|----------|--------|
| [000](Labs/000-setup/) | Environment Setup | 15 min | ✅ |
| [001](Labs/001-mcp-basics/) | MCP Basics | 10 min | ✅ |
| [002](Labs/002-python-server/) | Python MCP Server | 12 min | 🚧 |
| [003](Labs/003-typescript-server/) | TypeScript MCP Server | 15 min | ✅ |
| [004](Labs/004-k8s-deploy/) | Kubernetes Deployment | 15 min | 🚧 |
| [005](Labs/005-kubectl-tool/) | Kubectl Tool | 12 min | 🚧 |
| [006](Labs/006-cluster-inspector/) | Cluster Inspector | 12 min | 🚧 |
| [007](Labs/007-helm-tool/) | Helm Integration | 12 min | 🚧 |
| [008](Labs/008-postgres-tool/) | PostgreSQL Tool | 15 min | 🚧 |
| [009](Labs/009-configmap-secrets/) | ConfigMaps & Secrets | 12 min | 🚧 |
| [010](Labs/010-mcp-remote/) | Remote MCP Server | 12 min | 🚧 |
| [011](Labs/011-gcp-gke/) | Google GKE | 15 min | 🚧 |
| [012](Labs/012-gcp-tools/) | GCP SDK Tools | 12 min | 🚧 |
| [013](Labs/013-security-rbac/) | Security & RBAC | 15 min | 🚧 |
| [014](Labs/014-production-ready/) | Production Deployment | 15 min | 🚧 |

**Total Duration:** ~3 hours

## 🎯 What You'll Learn

- **Model Context Protocol (MCP)**: Understand the standardized protocol for AI-tool communication
- **MCP Server Development**: Build MCP servers with TypeScript and Python
- **Kubernetes Integration**: Deploy and manage MCP servers in Kubernetes
- **Tool Development**: Create custom tools for kubectl, Helm, databases, and cloud services
- **Cloud Deployment**: Deploy to Google Kubernetes Engine (GKE)
- **Security**: Implement RBAC and secrets management
- **Production**: Observability, scaling, and production best practices

## 🛠️ Prerequisites

### Required
- **Docker** (Docker Desktop, Podman, or compatible)
- **kubectl** - Kubernetes CLI
- **Helm 3** - Kubernetes package manager
- **Git** - Version control

### Kubernetes Cluster (choose one)
- **Kind** (recommended for local development)
- **Minikube**
- **Docker Desktop Kubernetes**
- **Google GKE** (for cloud deployment)

### Optional
- **Ollama** - For AI model integration (Labs 012-013)

## 📦 Project Structure

```
/
├── Labs/                      # Lab markdown files and exercises
│   ├── 000-setup/
│   ├── 001-mcp-basics/
│   ├── 002-python-server/
│   ├── 003-typescript-server/
│   └── ...
├── labs-environment/          # Unified Docker environment
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   ├── entrypoint.sh
│   └── src/                   # Sample MCP server code
├── _utils/                    # Utility scripts
│   ├── common.sh              # Shared functions
│   └── init-cluster.sh        # Cluster initialization
├── mkdocs/                    # MKdocs configuration
│   ├── 01-mkdocs-site.yml
│   ├── 02-mkdocs-theme.yml
│   ├── ...
│   ├── requirements.txt
│   └── scripts/
│       └── init_site.sh       # Site build script
├── .github/workflows/         # CI/CD workflows
│   ├── 000-setup.yaml
│   ├── ...
│   └── deploy-mkdocs.yml
└── runtime/                   # Generated at runtime
    ├── labs-scripts/
    ├── .ssh/
    └── .kube/
```

## 🌐 Online Documentation

Access the full documentation at: [https://codewizard-il.github.io/Kagent/](https://codewizard-il.github.io/Kagent/)

### Build Documentation Locally

```bash
cd 

# Build and serve
chmod +x mkdocs/scripts/init_site.sh
bash mkdocs/scripts/init_site.sh --serve

# Or manually with Python
python3 -m venv .venv
source .venv/bin/activate
pip install -r mkdocs/requirements.txt
mkdocs serve
```

## 🧪 Running Labs

### Interactive Mode

```bash
# Start the labs environment
cd labs-environment
docker compose up -d

# Connect to the container
docker exec -it kagent-controller bash

# Inside the container, navigate to lab exercises
cd /labs-scripts
```

### Automated Demo Scripts

Each lab includes a `_demo.sh` script that runs all exercises automatically:

```bash
# Run a specific lab
cd Labs/001-mcp-basics
bash _demo.sh
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Model Context Protocol](https://modelcontextprotocol.io/) - The MCP specification
- [Kubernetes](https://kubernetes.io/) - Container orchestration
- [MKdocs Material](https://squidfunk.github.io/mkdocs-material/) - Documentation theme

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/CodeWizard-IL/Kagent/issues)
- **Discussions**: [GitHub Discussions](https://github.com/CodeWizard-IL/Kagent/discussions)

---

**Built with ❤️ for the K-Agent community**
