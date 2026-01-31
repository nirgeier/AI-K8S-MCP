# Step 1: Install Kagent

```bash
# 1.1 Install Kagent CLI
curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash

# Install Kagent Platform
kagent install --profile demo

# 1.3 Verify Installation
kubectl get pods -n kagent
```
