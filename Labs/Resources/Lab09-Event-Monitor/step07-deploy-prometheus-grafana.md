# Step 7: Deploy Prometheus & Grafana

## 7.1 Add Helm Repos

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## 7.2 Create Prometheus Config

Create the file `prometheus-config.yaml` with the following content:

```yaml
server:
  baseURL: /prometheus

  # Fix probes to check status at /prometheus/-/ready instead of /-/ready
  readinessProbe:
    httpGet:
      path: /prometheus/-/ready
      port: 9090
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 5
    timeoutSeconds: 4
    failureThreshold: 3
    successThreshold: 1

  livenessProbe:
    httpGet:
      path: /prometheus/-/healthy
      port: 9090
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 3
    successThreshold: 1

extraScrapeConfigs: |
  - job_name: 'mcp-monitor'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_name]
        regex: .*monitor.*
        action: keep
      - source_labels: [__address__]
        regex: ([^:]+)(?::\d+)?
        replacement: ${1}:8000
        target_label: __address__
```

## 7.3 Create Grafana Config

Create the file `grafana-config.yaml` with the following content:

```yaml
adminPassword: admin123
grafana.ini:
  server:
    domain: cluster.local
    root_url: "%(protocol)s://%(domain)s/grafana"
    serve_from_sub_path: true
```

## 7.4 Install Prometheus

```bash
helm upgrade --install prometheus prometheus-community/prometheus -f prometheus-config.yaml
```

## 7.5 Install Grafana

```bash
helm upgrade --install grafana grafana/grafana -f grafana-config.yaml
```

## 7.6 Verify Deployments

```bash
kubectl get pods -n default
kubectl get pods -n ingress-nginx
```
