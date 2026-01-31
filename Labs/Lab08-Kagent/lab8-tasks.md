# MCP Lab Tasks - Lab 6: K-Agent

Welcome to Lab 6! In this lab, you'll build a K-Agent - an MCP server specialized for Kubernetes operations with a focus on log collection from all pods.

The exercises build progressively, starting with basic Kubernetes client setup and culminating in a complete log collection system.

---

### Exercise 6.1: K-Agent Project Setup

Create a new MCP server project with Kubernetes dependencies.

??? "Solution"
    ```bash
    # Create project directory
    mkdir k-agent-logs
    cd k-agent-logs

    # Initialize Node.js project
    npm init -y

    # Install dependencies
    npm install @modelcontextprotocol/sdk @kubernetes/client-node
    npm install -D typescript @types/node tsx

    # Create TypeScript configuration
    npx tsc --init --target ES2022 --module NodeNext --moduleResolution NodeNext --esModuleInterop --allowSyntheticDefaultImports --strict --skipLibCheck --forceConsistentCasingInFileNames --outDir ./dist --rootDir ./src

    # Create source directory structure
    mkdir -p src
    ```

### Exercise 6.2: Basic K-Agent Server Structure

Create the basic MCP server structure with Kubernetes client initialization.

??? "Solution"
    ```typescript
    import { Server } from "@modelcontextprotocol/sdk/server/index.js";
    import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
    import * as k8s from '@kubernetes/client-node';

    class KAgentServer {
      private server: Server;
      private k8sConfig: k8s.KubeConfig;
      private k8sCoreApi: k8s.CoreV1Api;

      constructor() {
        this.server = new Server(
          {
            name: "k-agent-logs",
            version: "1.0.0",
          },
          {
            capabilities: {
              tools: {},
            },
          }
        );

        // Initialize Kubernetes client
        this.k8sConfig = new k8s.KubeConfig();
        this.k8sCoreApi = this.k8sConfig.makeApiClient(k8s.CoreV1Api);

        this.setupHandlers();
      }

      private setupHandlers() {
        // Tools will be added in subsequent exercises
      }

      async start() {
        const transport = new StdioServerTransport();
        await this.server.connect(transport);
        console.error("K-Agent server started");
      }
    }

    // Start the server
    const server = new KAgentServer();
    server.start().catch(console.error);
    ```

### Exercise 6.3: Kubernetes Authentication

Implement secure Kubernetes cluster authentication with proper error handling.

??? "Solution"
    ```typescript
    private loadKubeConfig(): void {
      try {
        this.k8sConfig.loadFromDefault();

        // Validate cluster access
        this.validateClusterAccess();
      } catch (error) {
        throw new Error(`Kubernetes configuration error: ${error.message}`);
      }
    }

    private async validateClusterAccess(): Promise<void> {
      try {
        // Test API access by listing namespaces
        await this.k8sCoreApi.listNamespace();
      } catch (error: any) {
        if (error.response?.statusCode === 403) {
          throw new Error('Access denied: Insufficient permissions to access Kubernetes cluster');
        }
        throw new Error(`Cluster access validation failed: ${error.message}`);
      }
    }

    constructor() {
      // ... existing constructor code ...

      // Initialize Kubernetes client
      this.loadKubeConfig();
    }
    ```

### Exercise 6.4: Pod Listing Tool

Implement a tool to list all pods across namespaces with their status.

??? "Solution"
    ```typescript
    private setupHandlers() {
      // Tools list handler
      this.server.setRequestHandler("tools/list", async () => {
        return {
          tools: [
            {
              name: "list_pods",
              description: "List all pods across namespaces with their status",
              inputSchema: {
                type: "object",
                properties: {
                  namespace: {
                    type: "string",
                    description: "Optional: Filter by specific namespace"
                  }
                }
              }
            }
          ]
        };
      });

      // Tools call handler
      this.server.setRequestHandler("tools/call", async (request) => {
        const { name, arguments: args } = request.params;

        switch (name) {
          case "list_pods":
            return await this.handleListPods(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      });
    }

    private async handleListPods(args: any) {
      try {
        const namespace = args?.namespace;
        const pods = namespace
          ? await this.k8sCoreApi.listNamespacedPod(namespace)
          : await this.k8sCoreApi.listPodForAllNamespaces();

        const podInfo = pods.body.items.map(pod => ({
          name: pod.metadata?.name,
          namespace: pod.metadata?.namespace,
          status: pod.status?.phase,
          containers: pod.spec?.containers?.length || 0
        }));

        return {
          content: [{
            type: "text",
            text: `Found ${podInfo.length} pods:\n${podInfo.map(p =>
              `- ${p.namespace}/${p.name}: ${p.status} (${p.containers} containers)`
            ).join('\n')}`
          }]
        };
      } catch (error: any) {
        throw this.handleK8sError(error);
      }
    }

    private handleK8sError(error: any): Error {
      if (error.response?.statusCode === 403) {
        return new Error('Access denied: Insufficient permissions to access Kubernetes resources');
      }

      if (error.response?.statusCode === 404) {
        return new Error('Resource not found: The specified namespace may not exist');
      }

      return new Error(`Kubernetes operation failed: ${error.message}`);
    }
    ```

### Exercise 6.5: Single Pod Log Collection

Implement log collection from a specific pod.

??? "Solution"
    ```typescript
    // Add to tools list
    {
      name: "get_pod_logs",
      description: "Get logs from a specific pod",
      inputSchema: {
        type: "object",
        properties: {
          namespace: {
            type: "string",
            description: "Namespace of the pod"
          },
          podName: {
            type: "string",
            description: "Name of the pod"
          },
          tailLines: {
            type: "number",
            description: "Number of recent log lines to retrieve",
            default: 100
          }
        },
        required: ["namespace", "podName"]
      }
    }

    // Add to tools call handler
    case "get_pod_logs":
      return await this.handleGetPodLogs(args);

    private async handleGetPodLogs(args: any) {
      const { namespace, podName, tailLines = 100 } = args;

      try {
        const logResponse = await this.k8sCoreApi.readNamespacedPodLog(
          podName,
          namespace,
          undefined, // container
          false, // follow
          undefined, // previous
          undefined, // sinceSeconds
          undefined, // sinceTime
          tailLines, // tailLines
          undefined, // timestamps
          undefined // limitBytes
        );

        return {
          content: [{
            type: "text",
            text: `Logs from pod ${namespace}/${podName}:\n\n${logResponse.body}`
          }]
        };
      } catch (error: any) {
        throw this.handleK8sError(error);
      }
    }
    ```

### Exercise 6.6: Multi-Pod Log Collection

Extend the system to collect logs from all pods in a namespace.

??? "Solution"
    ```typescript
    // Add to tools list
    {
      name: "collect_namespace_logs",
      description: "Collect logs from all pods in a namespace",
      inputSchema: {
        type: "object",
        properties: {
          namespace: {
            type: "string",
            description: "Namespace to collect logs from"
          },
          tailLines: {
            type: "number",
            description: "Number of recent log lines per pod",
            default: 50
          }
        },
        required: ["namespace"]
      }
    }

    // Add to tools call handler
    case "collect_namespace_logs":
      return await this.handleCollectNamespaceLogs(args);

    private async handleCollectNamespaceLogs(args: any) {
      const { namespace, tailLines = 50 } = args;

      try {
        // Get all pods in namespace
        const podsResponse = await this.k8sCoreApi.listNamespacedPod(namespace);
        const pods = podsResponse.body.items.filter(pod =>
          pod.status?.phase === 'Running' || pod.status?.phase === 'Succeeded'
        );

        if (pods.length === 0) {
          return {
            content: [{
              type: "text",
              text: `No running pods found in namespace ${namespace}`
            }]
          };
        }

        const allLogs: string[] = [];

        for (const pod of pods) {
          const podName = pod.metadata?.name!;
          try {
            const logResponse = await this.k8sCoreApi.readNamespacedPodLog(
              podName,
              namespace,
              undefined,
              false,
              undefined,
              undefined,
              undefined,
              tailLines
            );

            allLogs.push(`=== ${podName} ===\n${logResponse.body}\n`);
          } catch (error: any) {
            allLogs.push(`=== ${podName} ===\nError retrieving logs: ${error.message}\n`);
          }
        }

        return {
          content: [{
            type: "text",
            text: `Logs from ${pods.length} pods in namespace ${namespace}:\n\n${allLogs.join('\n')}`
          }]
        };
      } catch (error: any) {
        throw this.handleK8sError(error);
      }
    }
    ```

### Exercise 6.7: All-Namespace Log Collection

Implement the core feature: collect logs from all pods across all namespaces.

??? "Solution"
    ```typescript
    // Add to tools list
    {
      name: "collect_all_logs",
      description: "Collect logs from all pods across all namespaces",
      inputSchema: {
        type: "object",
        properties: {
          tailLines: {
            type: "number",
            description: "Number of recent log lines per pod",
            default: 25
          },
          maxPods: {
            type: "number",
            description: "Maximum number of pods to collect logs from",
            default: 50
          }
        }
      }
    }

    // Add to tools call handler
    case "collect_all_logs":
      return await this.handleCollectAllLogs(args);

    private async handleCollectAllLogs(args: any) {
      const { tailLines = 25, maxPods = 50 } = args;

      try {
        // Get all pods across all namespaces
        const podsResponse = await this.k8sCoreApi.listPodForAllNamespaces();
        const pods = podsResponse.body.items
          .filter(pod =>
            pod.status?.phase === 'Running' || pod.status?.phase === 'Succeeded'
          )
          .slice(0, maxPods); // Limit for performance

        if (pods.length === 0) {
          return {
            content: [{
              type: "text",
              text: "No running pods found in the cluster"
            }]
          };
        }

        const allLogs: string[] = [];
        let processedCount = 0;

        for (const pod of pods) {
          const podName = pod.metadata?.name!;
          const namespace = pod.metadata?.namespace!;

          try {
            const logResponse = await this.k8sCoreApi.readNamespacedPodLog(
              podName,
              namespace,
              undefined,
              false,
              undefined,
              undefined,
              undefined,
              tailLines
            );

            allLogs.push(`=== ${namespace}/${podName} ===\n${logResponse.body}\n`);
            processedCount++;
          } catch (error: any) {
            allLogs.push(`=== ${namespace}/${podName} ===\nError retrieving logs: ${error.message}\n`);
          }
        }

        const summary = `Collected logs from ${processedCount} out of ${pods.length} pods (limited to ${maxPods} max)\n\n`;

        return {
          content: [{
            type: "text",
            text: summary + allLogs.join('\n')
          }]
        };
      } catch (error: any) {
        throw this.handleK8sError(error);
      }
    }
    ```

### Exercise 6.8: Log Filtering and Search

Add filtering capabilities to search through logs.

??? "Solution"
    ```typescript
    // Add to tools list
    {
      name: "search_logs",
      description: "Search for specific patterns in pod logs",
      inputSchema: {
        type: "object",
        properties: {
          namespace: {
            type: "string",
            description: "Namespace to search in (optional)"
          },
          pattern: {
            type: "string",
            description: "Text pattern to search for"
          },
          caseSensitive: {
            type: "boolean",
            description: "Whether search should be case sensitive",
            default: false
          },
          tailLines: {
            type: "number",
            description: "Number of recent log lines to search through",
            default: 100
          }
        },
        required: ["pattern"]
      }
    }

    // Add to tools call handler
    case "search_logs":
      return await this.handleSearchLogs(args);

    private async handleSearchLogs(args: any) {
      const { namespace, pattern, caseSensitive = false, tailLines = 100 } = args;

      try {
        const podsResponse = namespace
          ? await this.k8sCoreApi.listNamespacedPod(namespace)
          : await this.k8sCoreApi.listPodForAllNamespaces();

        const runningPods = podsResponse.body.items.filter(pod =>
          pod.status?.phase === 'Running' || pod.status?.phase === 'Succeeded'
        );

        const matches: string[] = [];
        const flags = caseSensitive ? 'g' : 'gi';
        const regex = new RegExp(pattern, flags);

        for (const pod of runningPods) {
          const podName = pod.metadata?.name!;
          const podNamespace = pod.metadata?.namespace!;

          try {
            const logResponse = await this.k8sCoreApi.readNamespacedPodLog(
              podName,
              podNamespace,
              undefined,
              false,
              undefined,
              undefined,
              undefined,
              tailLines
            );

            const logs = logResponse.body;
            const lines = logs.split('\n');

            const matchingLines = lines
              .map((line, index) => ({ line, index }))
              .filter(({ line }) => regex.test(line))
              .map(({ line, index }) => `  Line ${index + 1}: ${line}`);

            if (matchingLines.length > 0) {
              matches.push(`=== ${podNamespace}/${podName} ===`);
              matches.push(...matchingLines);
              matches.push('');
            }
          } catch (error) {
            // Skip pods where we can't read logs
          }
        }

        if (matches.length === 0) {
          return {
            content: [{
              type: "text",
              text: `No logs matching pattern "${pattern}" found`
            }]
          };
        }

        return {
          content: [{
            type: "text",
            text: `Found ${matches.length} matches for pattern "${pattern}":\n\n${matches.join('\n')}`
          }]
        };
      } catch (error: any) {
        throw this.handleK8sError(error);
      }
    }
    ```

### Exercise 6.9: Resource Integration

Create MCP resources for recent log summaries.

??? "Solution"
    ```typescript
    constructor() {
      this.server = new Server(
        {
          name: "k-agent-logs",
          version: "1.0.0",
        },
        {
          capabilities: {
            tools: {},
            resources: {},
          },
        }
      );

      // ... rest of constructor
    }

    private setupHandlers() {
      // ... existing tools setup ...

      // Resources handlers
      this.server.setRequestHandler("resources/list", async () => {
        return {
          resources: [
            {
              uri: "logs://cluster/summary",
              name: "Cluster Logs Summary",
              description: "Summary of recent logs from all pods",
              mimeType: "application/json"
            }
          ]
        };
      });

      this.server.setRequestHandler("resources/read", async (request) => {
        const { uri } = request.params;

        if (uri === "logs://cluster/summary") {
          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify(await this.getClusterLogsSummary(), null, 2)
            }]
          };
        }

        throw new Error(`Resource not found: ${uri}`);
      });
    }

    private async getClusterLogsSummary() {
      try {
        const podsResponse = await this.k8sCoreApi.listPodForAllNamespaces();
        const pods = podsResponse.body.items;

        const summary = {
          timestamp: new Date().toISOString(),
          totalPods: pods.length,
          runningPods: pods.filter(p => p.status?.phase === 'Running').length,
          namespaces: [...new Set(pods.map(p => p.metadata?.namespace))].length,
          podStatusCounts: pods.reduce((acc, pod) => {
            const phase = pod.status?.phase || 'Unknown';
            acc[phase] = (acc[phase] || 0) + 1;
            return acc;
          }, {} as Record<string, number>)
        };

        return summary;
      } catch (error: any) {
        return {
          error: `Failed to get cluster summary: ${error.message}`,
          timestamp: new Date().toISOString()
        };
      }
    }
    ```

### Exercise 6.10: Error Handling and Validation

Implement comprehensive error handling and input validation.

??? "Solution"
    ```typescript
    private validateToolArguments(toolName: string, args: any): void {
      switch (toolName) {
        case 'list_pods':
          if (args?.namespace && typeof args.namespace !== 'string') {
            throw new Error('namespace must be a string');
          }
          break;

        case 'get_pod_logs':
          if (!args?.namespace || typeof args.namespace !== 'string') {
            throw new Error('namespace is required and must be a string');
          }
          if (!args?.podName || typeof args.podName !== 'string') {
            throw new Error('podName is required and must be a string');
          }
          if (args?.tailLines && (typeof args.tailLines !== 'number' || args.tailLines < 1)) {
            throw new Error('tailLines must be a positive number');
          }
          break;

        case 'collect_namespace_logs':
          if (!args?.namespace || typeof args.namespace !== 'string') {
            throw new Error('namespace is required and must be a string');
          }
          if (args?.tailLines && (typeof args.tailLines !== 'number' || args.tailLines < 1)) {
            throw new Error('tailLines must be a positive number');
          }
          break;

        case 'collect_all_logs':
          if (args?.tailLines && (typeof args.tailLines !== 'number' || args.tailLines < 1)) {
            throw new Error('tailLines must be a positive number');
          }
          if (args?.maxPods && (typeof args.maxPods !== 'number' || args.maxPods < 1)) {
            throw new Error('maxPods must be a positive number');
          }
          break;

        case 'search_logs':
          if (!args?.pattern || typeof args.pattern !== 'string') {
            throw new Error('pattern is required and must be a string');
          }
          if (args?.namespace && typeof args.namespace !== 'string') {
            throw new Error('namespace must be a string');
          }
          break;
      }
    }

    // Update tools call handler to include validation
    this.server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      // Validate arguments
      this.validateToolArguments(name, args);

      switch (name) {
        // ... existing cases
      }
    });
    ```

### Exercise 6.11: Package Configuration

Create proper package.json and tsconfig.json for the K-Agent.

??? "Solution"
    **package.json:**
    ```json
    {
      "name": "k-agent-logs",
      "version": "1.0.0",
      "description": "K-Agent MCP server for Kubernetes log collection",
      "main": "dist/index.js",
      "scripts": {
        "build": "tsc",
        "start": "node dist/index.js",
        "dev": "tsx src/index.ts",
        "test": "echo \"No tests specified\""
      },
      "keywords": ["mcp", "kubernetes", "logs", "monitoring"],
      "author": "Your Name",
      "license": "MIT",
      "dependencies": {
        "@kubernetes/client-node": "^0.20.0",
        "@modelcontextprotocol/sdk": "^0.5.0"
      },
      "devDependencies": {
        "@types/node": "^20.0.0",
        "tsx": "^4.0.0",
        "typescript": "^5.0.0"
      }
    }
    ```

    **tsconfig.json:**
    ```json
    {
      "compilerOptions": {
        "target": "ES2022",
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "esModuleInterop": true,
        "allowSyntheticDefaultImports": true,
        "strict": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "outDir": "./dist",
        "rootDir": "./src",
        "declaration": true,
        "declarationMap": true,
        "sourceMap": true
      },
      "include": ["src/**/*"],
      "exclude": ["node_modules", "dist"]
    }
    ```

### Exercise 6.12: Docker Configuration

Create a Dockerfile for containerized deployment.

??? "Solution"
    ```dockerfile
    FROM node:18-alpine

    # Install kubectl
    RUN apk add --no-cache curl && \
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
        rm kubectl && \
        kubectl version --client

    WORKDIR /app

    # Copy package files
    COPY package*.json ./
    COPY tsconfig.json ./

    # Install dependencies
    RUN npm ci --only=production && npm cache clean --force

    # Copy source code
    COPY src/ ./src/

    # Build TypeScript
    RUN npm run build

    # Create non-root user
    RUN addgroup -g 1001 -S nodejs && \
        adduser -S kagent -u 1001

    # Change ownership
    RUN chown -R kagent:nodejs /app
    USER kagent

    EXPOSE 3000

    CMD ["npm", "start"]
    ```

### Exercise 6.13: Testing the K-Agent

Create a test script to verify all functionality.

??? "Solution"
    **test-kagent.js:**
    ```javascript
    const { spawn } = require('child_process');

    async function testKAgent() {
      console.log('Testing K-Agent functionality...\n');

      const server = spawn('node', ['dist/index.js'], {
        stdio: ['pipe', 'pipe', 'pipe']
      });

      // Give server time to start
      await new Promise(resolve => setTimeout(resolve, 2000));

      const tests = [
        {
          name: 'List tools',
          request: {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/list',
            params: {}
          }
        },
        {
          name: 'List pods',
          request: {
            jsonrpc: '2.0',
            id: 2,
            method: 'tools/call',
            params: {
              name: 'list_pods'
            }
          }
        }
      ];

      for (const test of tests) {
        console.log(`Running test: ${test.name}`);

        server.stdin.write(JSON.stringify(test.request) + '\n');

        // Wait for response
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

      server.kill();
      console.log('\nTesting completed!');
    }

    testKAgent().catch(console.error);
    ```

### Exercise 6.14: Production Deployment Manifest

Create Kubernetes deployment manifests for production deployment.

??? "Solution"
    **k8s-deployment.yaml:**
    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: k-agent-sa
      namespace: default
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: k-agent-role
    rules:
    - apiGroups: [""]
      resources: ["pods", "pods/log", "namespaces"]
      verbs: ["get", "list", "watch"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: k-agent-binding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: k-agent-role
    subjects:
    - kind: ServiceAccount
      name: k-agent-sa
      namespace: default
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: k-agent-logs
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: k-agent-logs
      template:
        metadata:
          labels:
            app: k-agent-logs
        spec:
          serviceAccountName: k-agent-sa
          containers:
          - name: k-agent
            image: your-registry/k-agent-logs:latest
            ports:
            - containerPort: 3000
            env:
            - name: NODE_ENV
              value: "production"
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
              limits:
                memory: "512Mi"
                cpu: "500m"
            livenessProbe:
              httpGet:
                path: /health
                port: 3000
              initialDelaySeconds: 30
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /health
                port: 3000
              initialDelaySeconds: 5
              periodSeconds: 5
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: k-agent-service
      namespace: default
    spec:
      selector:
        app: k-agent-logs
      ports:
      - port: 3000
        targetPort: 3000
      type: ClusterIP
    ```

### Exercise 6.15: Complete Integration Test

Create a comprehensive integration test that exercises all K-Agent capabilities.

??? "Solution"
    **integration-test.js:**
    ```javascript
    const { spawn } = require('child_process');
    const fs = require('fs');

    async function runIntegrationTest() {
      console.log('🚀 Starting K-Agent Integration Test\n');

      const server = spawn('node', ['dist/index.js'], {
        stdio: ['pipe', 'pipe', 'inherit']
      });

      let requestId = 1;

      function sendRequest(method, params = {}) {
        const request = {
          jsonrpc: '2.0',
          id: requestId++,
          method,
          params
        };
        server.stdin.write(JSON.stringify(request) + '\n');
      }

      // Wait for server to start
      await new Promise(resolve => setTimeout(resolve, 3000));

      console.log('📋 Testing tools/list...');
      sendRequest('tools/list');

      await new Promise(resolve => setTimeout(resolve, 1000));

      console.log('📋 Testing tools/call - list_pods...');
      sendRequest('tools/call', {
        name: 'list_pods',
        arguments: { namespace: 'default' }
      });

      await new Promise(resolve => setTimeout(resolve, 2000));

      console.log('📋 Testing resources/list...');
      sendRequest('resources/list');

      await new Promise(resolve => setTimeout(resolve, 1000));

      console.log('📋 Testing resources/read...');
      sendRequest('resources/read', {
        uri: 'logs://cluster/summary'
      });

      await new Promise(resolve => setTimeout(resolve, 2000));

      console.log('🔍 Testing search functionality...');
      sendRequest('tools/call', {
        name: 'search_logs',
        arguments: {
          pattern: 'error|Error|ERROR',
          tailLines: 50
        }
      });

      // Wait for all responses
      await new Promise(resolve => setTimeout(resolve, 5000));

      server.kill();
      console.log('\n✅ Integration test completed!');
    }

    // Run the test
    runIntegrationTest().catch(error => {
      console.error('❌ Integration test failed:', error);
      process.exit(1);
    });
    ```
