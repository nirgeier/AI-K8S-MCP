# Step 8: Expose Services via Ingress

## 8.1 Create Ingress Manifest

Create the file `observability-ingress.yaml` with the following content:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: observability-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: cluster.local
      http:
        paths:
          - path: /prometheus
            pathType: Prefix
            backend:
              service:
                name: prometheus-server
                port:
                  number: 80
          - path: /grafana
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kagent-ui
                port:
                  number: 8080
```

## 8.2 Apply Ingress

```bash
kubectl apply -f observability-ingress.yaml
```

## 8.3 Update Hosts File

### Find the IP

- **Docker Desktop / OrbStack**: Use `127.0.0.1`
- **Minikube**: Run `minikube ip`

### Edit Host File

- **Linux/macOS**: `/etc/hosts`
- **Windows**: `C:\Windows\System32\drivers\etc\hosts`

Add:

```text
127.0.0.1  cluster.local
```

## 8.4 Access Services

- **Kagent Dashboard**: http://cluster.local
- **Grafana**: http://cluster.local/grafana
  - User: `admin`
  - Password: `admin123`
- **Prometheus**: http://cluster.local/prometheus
