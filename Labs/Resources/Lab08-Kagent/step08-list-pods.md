````markdown
# Step 08: List Pods Implementation

## Implement handleListPods Method

Add the following methods to your class:

```typescript
private async handleListPods(args: any) {
  const namespace = args?.namespace;
  const pods = await this.getPods(namespace);

  const podList = pods.map(pod => ({
    name: pod.metadata?.name || 'unknown',
    namespace: pod.metadata?.namespace || 'unknown',
    status: pod.status?.phase || 'unknown',
    containers: pod.spec?.containers?.map(c => c.name) || []
  }));

  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(podList, null, 2)
      }
    ]
  };
}

private async getPods(namespace?: string): Promise<k8s.V1Pod[]> {
  try {
    if (namespace) {
      const response = await this.k8sCoreApi.listNamespacedPod({ namespace });
      return response.items || [];
    } else {
      const response = await this.k8sCoreApi.listPodForAllNamespaces();
      return response.items || [];
    }
  } catch (error) {
    throw this.handleK8sError(error);
  }
}

private handleK8sError(error: any): Error {
  if (error.response?.statusCode === 403) {
    return new Error('Access denied: Insufficient permissions to access Kubernetes resources');
  }

  if (error.response?.statusCode === 404) {
    return new Error('Resource not found: The specified pod or namespace may not exist');
  }

  return new Error(`Kubernetes operation failed: ${error.message}`);
}
```
````

## Method Breakdown

### handleListPods

1. Extract optional `namespace` from arguments
2. Call `getPods()` to fetch pod list
3. Transform pods to simplified format
4. Return JSON-formatted result

### getPods

| Scenario          | API Call                           |
| ----------------- | ---------------------------------- |
| With namespace    | `listNamespacedPod({ namespace })` |
| Without namespace | `listPodForAllNamespaces()`        |

### handleK8sError

Translates Kubernetes API errors to user-friendly messages:

| Status Code | Meaning            |
| ----------- | ------------------ |
| 403         | Permission denied  |
| 404         | Resource not found |
| Other       | Generic K8s error  |

## Example Output

```json
[
  {
    "name": "nginx-deployment-abc123",
    "namespace": "default",
    "status": "Running",
    "containers": ["nginx"]
  },
  {
    "name": "redis-master-xyz789",
    "namespace": "production",
    "status": "Running",
    "containers": ["redis"]
  }
]
```

```

```
