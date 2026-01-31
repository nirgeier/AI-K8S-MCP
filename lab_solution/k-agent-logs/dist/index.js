"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const k8s = __importStar(require("@kubernetes/client-node"));
class KAgentServer {
    k8sConfig;
    k8sAppsApi;
    k8sCoreApi;
    server;
    constructor() {
        // Initialize Kubernetes configuration
        this.k8sConfig = new k8s.KubeConfig();
        try {
            this.k8sConfig.loadFromDefault();
        }
        catch (error) {
            console.error("Warning: Could not load Kubernetes configuration. Make sure kubectl is configured.");
            console.error("Error:", error instanceof Error ? error.message : String(error));
        }
        this.k8sAppsApi = this.k8sConfig.makeApiClient(k8s.AppsV1Api);
        this.k8sCoreApi = this.k8sConfig.makeApiClient(k8s.CoreV1Api);
        // Initialize MCP server
        this.server = new index_js_1.Server({
            name: "k-agent-logs",
            version: "1.0.0",
        }, {
            capabilities: {
                tools: {},
                resources: {},
            },
        });
        this.setupHandlers();
    }
    setupHandlers() {
        // List available tools
        this.server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => {
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
                    },
                    {
                        name: "collect_pod_logs",
                        description: "Collect logs from all containers in specified pods",
                        inputSchema: {
                            type: "object",
                            properties: {
                                namespace: {
                                    type: "string",
                                    description: "Namespace to collect logs from"
                                },
                                podName: {
                                    type: "string",
                                    description: "Specific pod name (optional - collects from all if not specified)"
                                },
                                tailLines: {
                                    type: "number",
                                    description: "Number of recent log lines to retrieve",
                                    default: 100
                                }
                            },
                            required: ["namespace"]
                        }
                    }
                ]
            };
        });
        // Handle tool calls
        this.server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
            const { name, arguments: args } = request.params;
            try {
                switch (name) {
                    case "list_pods":
                        return await this.handleListPods(args);
                    case "collect_pod_logs":
                        return await this.handleCollectPodLogs(args);
                    default:
                        throw new types_js_1.McpError(types_js_1.ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
                }
            }
            catch (error) {
                throw new types_js_1.McpError(types_js_1.ErrorCode.InternalError, `Tool execution failed: ${error instanceof Error ? error.message : String(error)}`);
            }
        });
    }
    async handleListPods(args) {
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
    async handleCollectPodLogs(args) {
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
    async collectPodLogs(namespace, podName, tailLines = 100) {
        const pods = podName
            ? await this.getPods(namespace).then(pods => pods.filter(p => p.metadata?.name === podName))
            : await this.getPods(namespace);
        const allLogs = [];
        for (const pod of pods) {
            if (!pod.metadata?.name)
                continue;
            const containers = pod.spec?.containers || [];
            for (const container of containers) {
                try {
                    const logs = await this.getPodLogs(namespace, pod.metadata.name, container.name, tailLines);
                    allLogs.push(`=== ${pod.metadata.name}/${container.name} ===\n${logs}\n`);
                }
                catch (error) {
                    allLogs.push(`=== ${pod.metadata.name}/${container.name} ===\nError retrieving logs: ${error instanceof Error ? error.message : String(error)}\n`);
                }
            }
        }
        return allLogs.join('\n');
    }
    async getPods(namespace) {
        try {
            if (namespace) {
                const response = await this.k8sCoreApi.listNamespacedPod({ namespace });
                return response.items || [];
            }
            else {
                const response = await this.k8sCoreApi.listPodForAllNamespaces();
                return response.items || [];
            }
        }
        catch (error) {
            throw this.handleK8sError(error);
        }
    }
    async getPodLogs(namespace, podName, containerName, tailLines) {
        try {
            const response = await this.k8sCoreApi.readNamespacedPodLog({
                name: podName,
                namespace: namespace,
                container: containerName,
                tailLines: tailLines,
                timestamps: true
            });
            return response || '';
        }
        catch (error) {
            throw this.handleK8sError(error);
        }
    }
    handleK8sError(error) {
        if (error.response?.statusCode === 403) {
            return new Error('Access denied: Insufficient permissions to access Kubernetes resources');
        }
        if (error.response?.statusCode === 404) {
            return new Error('Resource not found: The specified pod or namespace may not exist');
        }
        return new Error(`Kubernetes operation failed: ${error.message}`);
    }
    async run() {
        const transport = new stdio_js_1.StdioServerTransport();
        await this.server.connect(transport);
        console.error("K-Agent MCP server running on stdio");
    }
}
// Run the server
const server = new KAgentServer();
server.run().catch(console.error);
//# sourceMappingURL=index.js.map