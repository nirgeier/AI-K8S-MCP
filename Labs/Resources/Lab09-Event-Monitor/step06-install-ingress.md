# Step 6: Install NGINX Ingress Controller

## 6.1 Install via Helm

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

## 6.2 Verify Installation

```bash
kubectl get pods -n ingress-nginx
```
