#!/bin/bash

# --- VARIABLES ---

# Model to be used by kagent
OLLAMA_MODEL="gpt-oss:20b"

OLLAMA_NS="ollama"
KAGENT_NS="kagent"
OLLAMA_IMAGE="ollama/ollama:latest"
OLLAMA_SVC_NAME="ollama"
DUMMY_SECRET_NAME="kagent-ollama-dummy"

echo "Installing Kagent and setting up Ollama integration..."

# 0. Install Kagent
curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash

export OPENAI_API_KEY="aaa"
kagent install --profile demo

echo "Starting kagent + Ollama integration..."

# 1. Create Namespaces
kubectl create ns $OLLAMA_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns $KAGENT_NS --dry-run=client -o yaml | kubectl apply -f -

# 2. Deploy Ollama (Deployment & Service)
echo "Deploying Ollama to namespace: $OLLAMA_NS..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: $OLLAMA_NS
spec:
  selector:
    matchLabels:
      name: ollama
  template:
    metadata:
      labels:
        name: ollama
    spec:
      containers:
      - name: ollama
        image: $OLLAMA_IMAGE
        ports:
        - name: http
          containerPort: 11434
        resources:
          requests:
            memory: "4Gi"
            cpu: "2"
---
apiVersion: v1
kind: Service
metadata:
  name: $OLLAMA_SVC_NAME
  namespace: $OLLAMA_NS
spec:
  selector:
    name: ollama
  ports:
  - port: 80
    targetPort: 11434
EOF

# 3. Wait for Ollama to be ready
echo "Waiting for Ollama pod to be ready..."
kubectl wait --for=condition=ready pod -l name=ollama -n $OLLAMA_NS --timeout=300s

# 4. Pull the Model
#echo "Pulling model: $OLLAMA_MODEL (this may take a few minutes)..."
#OLLAMA_POD=$(kubectl get pods -n $OLLAMA_NS -l name=ollama -o jsonpath='{.items[0].metadata.name}')
#kubectl exec -n $OLLAMA_NS $OLLAMA_POD -- ollama pull $OLLAMA_MODEL

# 5. Create Dummy Secret in kagent namespace
echo "Creating dummy secret in $KAGENT_NS..."
kubectl create secret generic $DUMMY_SECRET_NAME \
  -n $KAGENT_NS \
  --from-literal=API_KEY=local-ollama \
  --dry-run=client -o yaml | kubectl apply -f -

# 6. Configure kagent ModelConfig
echo "Applying kagent ModelConfig..."
cat <<EOF | kubectl apply -f -
apiVersion: kagent.dev/v1alpha2
kind: ModelConfig
metadata:
  name: default-model-config
  namespace: default
spec:
  provider: Ollama
  model: $OLLAMA_MODEL  # The model already on your laptop
  ollama:
    # Use 'host.docker.internal' for Docker Desktop / Minikube
    host: http://host.docker.internal:11434
EOF

# 7. Create Ingress for Kagent
echo "Creating Ingress for Kagent details..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kagent-ingress
  namespace: $KAGENT_NS
spec:
  rules:
  - host: kagent.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kagent-controller
            port:
              number: 8083
EOF

echo "Setup Complete!"
echo "Model URL: http://${OLLAMA_SVC_NAME}.${OLLAMA_NS}.svc.cluster.local:80"
