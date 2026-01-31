````markdown
# Step 01: Prerequisites and Environment Setup

## Prerequisites Checklist

Before starting the K-Agent lab, ensure you have the following:

### Required Tools

1. **Node.js 18+** - JavaScript runtime
   ```bash
   node --version  # Should be v18 or higher
   ```
````

2. **npm** - Package manager

   ```bash
   npm --version
   ```

3. **kubectl** - Kubernetes CLI

   ```bash
   kubectl version --client
   ```

4. **A Running Kubernetes Cluster**
   - Docker Desktop with Kubernetes enabled
   - Minikube
   - Kind
   - OrbStack
   - Cloud-managed (EKS, GKE, AKS)

### Verify Cluster Access

```bash
# Check cluster connectivity
kubectl cluster-info

# List all namespaces
kubectl get namespaces

# List pods across all namespaces
kubectl get pods --all-namespaces

# Check your current context
kubectl config current-context
```

### Expected Output

```
Kubernetes control plane is running at https://127.0.0.1:6443
CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Troubleshooting

**No cluster found:**

```bash
# For Docker Desktop - Enable Kubernetes in Preferences
# For Minikube
minikube start

# For Kind
kind create cluster

# For OrbStack - Enable Kubernetes in settings
```

**kubectl not configured:**

```bash
# Check kubeconfig location
echo $KUBECONFIG
ls -la ~/.kube/config

# Set the context
kubectl config use-context <your-context-name>
```

```

```
