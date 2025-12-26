#!/usr/bin/env python3
"""
K-Agent Labs Structure Generator
Creates all lab directories, README files, demo scripts, and MKdocs configuration
"""

import os
from pathlib import Path

# Base directory
BASE_DIR = Path("/Users/orni/Code-Wizard/Kagent/Kagent_codewizard/Kagent/")

# Lab definitions
LABS = [
    ("003", "python-server", "Python MCP Server with FastMCP"),
    ("004", "k8s-deploy", "Deploy MCP to Kubernetes"),
    ("005", "kubectl-tool", "Kubectl Integration Tool"),
    ("006", "cluster-inspector", "Cluster Health Inspector"),
    ("007", "helm-tool", "Helm Package Management"),
    ("008", "postgres-tool", "PostgreSQL Database Tool"),
    ("009", "configmap-secrets", "ConfigMaps and Secrets"),
    ("010", "mcp-remote", "Remote MCP Server"),
    ("011", "gcp-gke", "Google Kubernetes Engine"),
    ("012", "gcp-tools", "Google Cloud SDK Tools"),
    ("013", "security-rbac", "Security and RBAC"),
    ("014", "production-ready", "Production Deployment"),
]

def create_lab_structure():
    """Create all lab directories and files"""
    labs_dir = BASE_DIR / "Labs"
    
    for num, name, title in LABS:
        lab_dir = labs_dir / f"{num}-{name}"
        lab_dir.mkdir(parents=True, exist_ok=True)
        
        # Create README.md
        readme_content = f"""<a href="https://github.com/CodeWizard-IL/Kagent/actions/workflows/{num}-{name}.yaml" target="_blank">
  <img src="https://github.com/CodeWizard-IL/Kagent/actions/workflows/{num}-{name}.yaml/badge.svg" alt="Lab {num}-{name}">
</a>

---

# Lab {num} - {title}

**What you'll learn:**
- {title} concepts and implementation
- Hands-on exercises with K-Agent
- Best practices and patterns

**Estimated time:** 10-15 minutes

---

## Pre-Requirements

- Completed [Lab {int(num)-1:03d}](../{int(num)-1:03d}-*/)
- K-Agent labs environment running

---

## 01. Introduction

This lab focuses on {title.lower()}.

---

## 02. Setup

```bash
# Connect to container
docker exec -it kagent-controller bash

# Navigate to labs directory
cd /labs-scripts
```

---

## 03. Hands-on Exercise

### Exercise 1: Core Implementation

[Lab-specific content]

---

## 04. Verification

```bash
# Verify your implementation
```

---

## 05. Key Takeaways

!!! success "What You Learned"
    - ✓ {title} implementation
    - ✓ Practical hands-on experience
    - ✓ Testing and validation

---

## 06. Next Steps

Continue to Lab {int(num)+1:03d} to build on these concepts.

---

<!-- Navigation Links -->
[Previous: Lab {int(num)-1:03d}](../{int(num)-1:03d}-*/) | [Next: Lab {int(num)+1:03d}](../{int(num)+1:03d}-*/)
"""
        
        with open(lab_dir / "README.md", "w") as f:
            f.write(readme_content)
        
        # Create _demo.sh
        demo_content = f"""#!/bin/bash

# Lab {num} - {title} Demo Script

set -e

ROOT_FOLDER=$(git rev-parse --show-toplevel)/
source "$ROOT_FOLDER/_utils/common.sh"

print_header "Lab {num} - {title}"

# Ensure labs environment is running
cd "$ROOT_FOLDER/labs-environment"
if ! docker_compose ps | grep -q "Up"; then
    print_info "Starting labs environment..."
    docker_compose up -d
    sleep 5
fi

print_step "Running Lab {num} exercises..."
print_info "{title} implementation"

# Lab-specific demonstrations
docker exec kagent-controller bash -c "
echo 'Lab {num}: {title}'
echo 'Exercises in progress...'
"

# Summary
print_header "Lab {num} Complete!"
echo ""
print_success "✓ Completed {title} exercises"
echo ""
print_info "Next: Lab {int(num)+1:03d}"
echo ""
"""
        
        demo_file = lab_dir / "_demo.sh"
        with open(demo_file, "w") as f:
            f.write(demo_content)
        demo_file.chmod(0o755)
        
        print(f"✓ Created {lab_dir.name}")

def create_mkdocs_structure():
    """Create MKdocs configuration files"""
    mkdocs_dir = BASE_DIR / "mkdocs"
    mkdocs_dir.mkdir(parents=True, exist_ok=True)
    
    scripts_dir = mkdocs_dir / "scripts"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    
    # Create 01-mkdocs-site.yml
    site_yml = """site_name: K-Agent Labs
site_url: https://codewizard-il.github.io/Kagent/
site_description: Hands-on labs for the K-Agent framework
site_author: K-Agent Labs
docs_dir: ../Labs
site_dir: ../mkdocs-site

repo_name: CodeWizard-IL/Kagent
repo_url: https://github.com/CodeWizard-IL/Kagent
edit_uri: edit/main//Labs/
"""
    
    with open(mkdocs_dir / "01-mkdocs-site.yml", "w") as f:
        f.write(site_yml)
    
    # Create 02-mkdocs-theme.yml
    theme_yml = """theme:
  name: material
  language: en
  palette:
    scheme: slate
    primary: indigo
    accent: indigo
  font:
    text: Roboto
    code: Roboto Mono
  icon:
    logo: material/kubernetes
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - navigation.tracking
    - search.suggest
    - search.highlight
    - content.code.copy
    - content.code.annotate
    - content.code.select
"""
    
    with open(mkdocs_dir / "02-mkdocs-theme.yml", "w") as f:
        f.write(theme_yml)
    
    # Create 03-mkdocs-extra.yml
    extra_yml = """extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/CodeWizard-IL/Kagent
"""
    
    with open(mkdocs_dir / "03-mkdocs-extra.yml", "w") as f:
        f.write(extra_yml)
    
    # Create 04-mkdocs-plugins.yml
    plugins_yml = """plugins:
  - search
  - git-revision-date-localized:
      enable_creation_date: true
  - print-site
"""
    
    with open(mkdocs_dir / "04-mkdocs-plugins.yml", "w") as f:
        f.write(plugins_yml)
    
    # Create 05-mkdocs-extensions.yml
    extensions_yml = """markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.emoji:
      emoji_index: !!python/name:material.extensions.emoji.twemoji
      emoji_generator: !!python/name:material.extensions.emoji.to_svg
  - admonition
  - pymdownx.details
  - attr_list
  - md_in_html
  - def_list
  - footnotes
  - tables
  - toc:
      permalink: true
"""
    
    with open(mkdocs_dir / "05-mkdocs-extensions.yml", "w") as f:
        f.write(extensions_yml)
    
    # Create 06-mkdocs-nav.yml (will be generated dynamically)
    nav_yml = """nav:
  - Home: index.md
  - Welcome: welcome.md
  - Labs:
      - 000 - Setup: 000-setup/README.md
      - 001 - MCP Basics: 001-mcp-basics/README.md
      - 002 - TypeScript Server: 002-typescript-server/README.md
      - 003 - Python Server: 003-python-server/README.md
      - 004 - K8s Deploy: 004-k8s-deploy/README.md
      - 005 - Kubectl Tool: 005-kubectl-tool/README.md
      - 006 - Cluster Inspector: 006-cluster-inspector/README.md
      - 007 - Helm Tool: 007-helm-tool/README.md
      - 008 - Postgres Tool: 008-postgres-tool/README.md
      - 009 - ConfigMap Secrets: 009-configmap-secrets/README.md
      - 010 - MCP Remote: 010-mcp-remote/README.md
      - 011 - GCP GKE: 011-gcp-gke/README.md
      - 012 - GCP Tools: 012-gcp-tools/README.md
      - 013 - Security RBAC: 013-security-rbac/README.md
      - 014 - Production Ready: 014-production-ready/README.md
"""
    
    with open(mkdocs_dir / "06-mkdocs-nav.yml", "w") as f:
        f.write(nav_yml)
    
    # Create requirements.txt
    requirements = """mkdocs>=1.5.0
mkdocs-material>=9.4.0
mkdocs-git-revision-date-localized-plugin>=1.2.0
mkdocs-print-site-plugin>=2.3.0
pymdown-extensions>=10.3.0
"""
    
    with open(mkdocs_dir / "requirements.txt", "w") as f:
        f.write(requirements)
    
    print("✓ Created MKdocs configuration files")

def create_welcome_and_index():
    """Create welcome and index pages"""
    labs_dir = BASE_DIR / "Labs"
    
    # Create index.md
    index_content = """# K-Agent Labs

Welcome to K-Agent Labs! This comprehensive hands-on learning experience will guide you through the K-Agent framework, Model Context Protocol (MCP), and Kubernetes integration.

## Labs Overview

| Lab | Title | Description | Duration |
|-----|-------|-------------|----------|
| [000](000-setup/) | Environment Setup | Install tools and build labs environment | 15 min |
| [001](001-mcp-basics/) | MCP Basics | Learn the Model Context Protocol | 10 min |
| [002](002-typescript-server/) | TypeScript MCP Server | Build MCP servers with TypeScript | 15 min |
| [003](003-python-server/) | Python MCP Server | Build MCP servers with Python/FastMCP | 12 min |
| [004](004-k8s-deploy/) | Kubernetes Deployment | Deploy MCP servers to K8s | 15 min |
| [005](005-kubectl-tool/) | Kubectl Tool | Create kubectl integration tool | 12 min |
| [006](006-cluster-inspector/) | Cluster Inspector | Monitor cluster health | 12 min |
| [007](007-helm-tool/) | Helm Integration | Manage packages with Helm | 12 min |
| [008](008-postgres-tool/) | PostgreSQL Tool | Database integration | 15 min |
| [009](009-configmap-secrets/) | ConfigMaps & Secrets | K8s configuration management | 12 min |
| [010](010-mcp-remote/) | Remote MCP Server | Remote server communication | 12 min |
| [011](011-gcp-gke/) | Google GKE | Deploy to Google Cloud | 15 min |
| [012](012-gcp-tools/) | GCP SDK Tools | Google Cloud integration | 12 min |
| [013](013-security-rbac/) | Security & RBAC | Security best practices | 15 min |
| [014](014-production-ready/) | Production Deployment | Observability and scaling | 15 min |

**Total Duration:** ~3 hours

## Quick Start

1. Start with [Lab 000 - Environment Setup](000-setup/)
2. Follow the labs in order
3. Complete hands-on exercises
4. Build progressively complex MCP tools

## Support

- [GitHub Repository](https://github.com/CodeWizard-IL/Kagent)
- [Report Issues](https://github.com/CodeWizard-IL/Kagent/issues)
"""
    
    with open(labs_dir / "index.md", "w") as f:
        f.write(index_content)
    
    # Create welcome.md
    welcome_content = """# Welcome to K-Agent Labs

## What is K-Agent?

**K-Agent** is a Kubernetes-native Model Context Protocol (MCP) server framework that enables AI assistants to interact with Kubernetes clusters and various cloud services through standardized tools.

## Architecture

```mermaid
graph TB
    A[AI Assistant] -->|MCP Protocol| B[K-Agent Server]
    B --> C[Kubernetes Cluster]
    B --> D[Cloud Services]
    B --> E[Databases]
    B --> F[External APIs]
    
    C --> C1[Pods]
    C --> C2[Deployments]
    C --> C3[Services]
    
    D --> D1[GCP]
    D --> D2[Storage]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e8f5e8
    style D fill:#ffe8f5
    style E fill:#f5e8ff
    style F fill:#fff5e8
```

## Quick Start Options

=== "Local Docker"
    
    ```bash
    git clone https://github.com/CodeWizard-IL/Kagent.git
    cd Kagent/
    cd labs-environment
    docker compose up -d
    ```

=== "GCP Cloud Shell"
    
    ```bash
    git clone https://github.com/CodeWizard-IL/Kagent.git
    cd Kagent/
    bash Labs/000-setup/_demo.sh
    ```

=== "Killercoda"
    
    Access the K-Agent Labs environment directly in your browser (coming soon).

## Prerequisites

### Required Tools

- **Docker** - Container runtime
- **kubectl** - Kubernetes CLI
- **Helm** - Kubernetes package manager
- **Git** - Version control

### Optional Tools

- **Ollama** - Local AI models (for labs 012-013)
  
  **Installation:**
  === "macOS"
      ```bash
      brew install ollama
      ollama serve
      ```
  
  === "Linux"
      ```bash
      curl -fsSL https://ollama.ai/install.sh | sh
      ollama serve
      ```
  
  **Connect from Container:**
  ```bash
  # Test connectivity
  docker exec kagent-controller curl http://host.docker.internal:11434/api/tags
  ```

## How It Works

1. **Setup Environment** - Build the unified labs container with all tools
2. **Learn MCP** - Understand the Model Context Protocol
3. **Build Tools** - Create MCP tools with TypeScript and Python
4. **Deploy to K8s** - Run MCP servers in Kubernetes
5. **Advanced Integration** - Connect to cloud services and databases
6. **Production** - Deploy production-ready MCP servers

## Key Features

- 🚀 **15 Hands-on Labs** - Progressive learning path
- 🐳 **Docker-based** - Consistent environment across platforms
- ☸️ **Kubernetes-native** - Real-world K8s deployments
- 🌥️ **Cloud-ready** - GCP integration included
- 🔐 **Security-focused** - RBAC and secrets management
- 📊 **Production-ready** - Observability and scaling patterns

## Getting Started

Begin your journey with [Lab 000 - Environment Setup](000-setup/)!

---

**Estimated Total Time:** 3 hours  
**Difficulty Level:** Intermediate  
**Prerequisites:** Basic knowledge of Docker, Kubernetes, and programming
"""
    
    with open(labs_dir / "welcome.md", "w") as f:
        f.write(welcome_content)
    
    print("✓ Created index.md and welcome.md")

if __name__ == "__main__":
    print("=" * 60)
    print("K-Agent Labs Structure Generator")
    print("=" * 60)
    print()
    
    create_lab_structure()
    print()
    create_mkdocs_structure()
    print()
    create_welcome_and_index()
    print()
    print("=" * 60)
    print("✓ All structures created successfully!")
    print("=" * 60)
