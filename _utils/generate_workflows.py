#!/usr/bin/env python3
"""
Generate GitHub Actions workflow files for all labs
"""

import os
from pathlib import Path

BASE_DIR = Path("/Users/orni/Code-Wizard/Kagent/Kagent_codewizard/Kagent/")
WORKFLOWS_DIR = BASE_DIR / ".github" / "workflows"

LABS = [
    ("000", "setup"),
    ("001", "mcp-basics"),
    ("002", "typescript-server"),
    ("003", "python-server"),
    ("004", "k8s-deploy"),
    ("005", "kubectl-tool"),
    ("006", "cluster-inspector"),
    ("007", "helm-tool"),
    ("008", "postgres-tool"),
    ("009", "configmap-secrets"),
    ("010", "mcp-remote"),
    ("011", "gcp-gke"),
    ("012", "gcp-tools"),
    ("013", "security-rbac"),
    ("014", "production-ready"),
]

def create_lab_workflow(num, name):
    """Create a GitHub Actions workflow for a lab"""
    content = f"""name: Lab {num} - {name.replace('-', ' ').title()}

on:
  push:
    branches: [main, develop]
    paths:
      - '/Labs/{num}-{name}/**'
      - '/_utils/**'
      - '/labs-environment/**'
  pull_request:
    branches: [main, develop]
    paths:
      - '/Labs/{num}-{name}/**'
      - '/_utils/**'
      - '/labs-environment/**'
  workflow_dispatch:

jobs:
  test-lab-{num}:
    name: Test Lab {num}
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Set up Kind
        uses: helm/kind-action@v1.8.0
        with:
          cluster_name: kagent-lab
      
      - name: Verify Kubernetes cluster
        run: |
          kubectl cluster-info
          kubectl get nodes
      
      - name: Build labs environment
        working-directory: /labs-environment
        run: |
          docker compose build
      
      - name: Load image to Kind
        run: |
          kind load docker-image kagent-lab-environment:latest --name kagent-lab
      
      - name: Run lab demo script
        working-directory: /Labs/{num}-{name}
        run: |
          chmod +x _demo.sh
          bash _demo.sh
      
      - name: Collect logs on failure
        if: failure()
        run: |
          docker compose logs || true
          kubectl get all --all-namespaces || true
"""
    
    workflow_file = WORKFLOWS_DIR / f"{num}-{name}.yaml"
    with open(workflow_file, "w") as f:
        f.write(content)
    
    print(f"✓ Created workflow: {num}-{name}.yaml")

def create_deploy_workflow():
    """Create GitHub Pages deployment workflow"""
    content = """name: Deploy MKdocs to GitHub Pages

on:
  push:
    branches: [main]
    paths:
      - '/Labs/**'
      - '/mkdocs/**'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    name: Deploy to GitHub Pages
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Cache pip packages
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('/mkdocs/requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-
      
      - name: Install dependencies
        run: |
          pip install -r /mkdocs/requirements.txt
      
      - name: Configure Git
        run: |
          git config user.name github-actions[bot]
          git config user.email github-actions[bot]@users.noreply.github.com
      
      - name: Generate mkdocs.yml
        working-directory: 
        run: |
          cat mkdocs/01-mkdocs-site.yml \\
              mkdocs/02-mkdocs-theme.yml \\
              mkdocs/03-mkdocs-extra.yml \\
              mkdocs/04-mkdocs-plugins.yml \\
              mkdocs/05-mkdocs-extensions.yml \\
              mkdocs/06-mkdocs-nav.yml > mkdocs.yml
      
      - name: Build and deploy
        working-directory: 
        run: |
          mkdocs gh-deploy --force --clean --verbose
"""
    
    workflow_file = WORKFLOWS_DIR / "deploy-mkdocs.yml"
    with open(workflow_file, "w") as f:
        f.write(content)
    
    print("✓ Created workflow: deploy-mkdocs.yml")

if __name__ == "__main__":
    print("=" * 60)
    print("GitHub Actions Workflow Generator")
    print("=" * 60)
    print()
    
    # Create workflows directory
    WORKFLOWS_DIR.mkdir(parents=True, exist_ok=True)
    
    # Create lab workflows
    for num, name in LABS:
        create_lab_workflow(num, name)
    
    print()
    
    # Create deployment workflow
    create_deploy_workflow()
    
    print()
    print("=" * 60)
    print("✓ All workflows created successfully!")
    print("=" * 60)
