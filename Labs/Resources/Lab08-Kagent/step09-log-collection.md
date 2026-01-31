````markdown
# Step 09: Log Collection Implementation

## Implement Log Collection Methods

Add these methods to your class:

```typescript
private async handleCollectPodLogs(args: any) {
  const { namespace, podName, tailLines = 100 } = args;

  if (!namespace) {
    throw new Error("Namespace is required");
  }

  const logs = await this.collectPodLogs(namespace, podName, tailLines);

  return {
    content: [
      {
        type: "text",
        text: logs
      }
    ]
  };
}

private async collectPodLogs(
  namespace: string,
  podName?: string,
  tailLines: number = 100
): Promise<string> {
  // Get pods - either specific or all in namespace
  const pods = podName
    ? await this.getPods(namespace).then(pods =>
        pods.filter(p => p.metadata?.name === podName)
      )
    : await this.getPods(namespace);

  const allLogs: string[] = [];

  for (const pod of pods) {
    if (!pod.metadata?.name) continue;

    // Iterate through all containers in the pod
    const containers = pod.spec?.containers || [];
    for (const container of containers) {
      try {
        const logs = await this.getPodLogs(
          namespace,
          pod.metadata.name,
          container.name,
          tailLines
        );
        allLogs.push(`=== ${pod.metadata.name}/${container.name} ===\n${logs}\n`);
      } catch (error) {
        allLogs.push(
          `=== ${pod.metadata.name}/${container.name} ===\n` +
          `Error retrieving logs: ${error instanceof Error ? error.message : String(error)}\n`
        );
      }
    }
  }

  return allLogs.join('\n');
}

private async getPodLogs(
  namespace: string,
  podName: string,
  containerName: string,
  tailLines: number
): Promise<string> {
  try {
    const response = await this.k8sCoreApi.readNamespacedPodLog({
      name: podName,
      namespace: namespace,
      container: containerName,
      tailLines: tailLines,
      timestamps: true
    });
    return response || '';
  } catch (error) {
    throw this.handleK8sError(error);
  }
}
```
````

## Method Breakdown

### handleCollectPodLogs

1. Destructure arguments with default values
2. Validate required namespace
3. Call `collectPodLogs()` orchestrator
4. Return formatted result

### collectPodLogs (Orchestrator)

Flow:

```
1. Get pods (filtered or all)
2. For each pod:
   a. For each container:
      - Try to get logs
      - Add to result (success or error)
3. Join all logs with separators
```

### getPodLogs

Kubernetes API parameters:

| Parameter    | Description                                        |
| ------------ | -------------------------------------------------- |
| `name`       | Pod name                                           |
| `namespace`  | Pod namespace                                      |
| `container`  | Container name (required for multi-container pods) |
| `tailLines`  | Number of lines from end                           |
| `timestamps` | Include timestamps                                 |

## Example Output

```
=== nginx-deployment-abc123/nginx ===
2024-01-15T10:30:45.123Z GET /api/health 200 5ms
2024-01-15T10:30:46.456Z GET /api/status 200 3ms

=== redis-master-xyz789/redis ===
1:C 15 Jan 10:30:45.789 * Redis starting
1:C 15 Jan 10:30:45.790 * Ready to accept connections
```

```

```
