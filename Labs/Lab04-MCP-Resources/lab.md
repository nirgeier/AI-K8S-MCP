# Lab 4: Working with MCP Resources

## Overview

In [Lab 3](../Lab03-MCP-Tools/), you mastered the art of creating sophisticated MCP tools that perform actions and return rich content. Now it's time to explore **MCP Resources** - the passive counterpart to tools that provides contextual data for LLMs to read and reference.

Resources are the foundation for giving LLMs access to your knowledge bases, files, databases, and other data sources. Unlike tools that *do* things, resources *are* things - they represent the data itself that LLMs can access for context and reasoning.

---

## Learning Objectives

By the end of this lab, you will:

- Understand the fundamental difference between tools and resources
- Design effective resource URI schemes for different data types
- Implement static and dynamic resources with proper metadata
- Create resource templates for parameterized access
- Build resource subscriptions for real-time updates
- Apply security best practices for resource access
- Combine resources with tools for comprehensive MCP servers
- Test resource implementations thoroughly

---

## Prerequisites

- Completed [Lab 3 - Implementing MCP Tools](../Lab03-MCP-Tools/)
- Understanding of URI / URL patterns and RESTful design
- Familiarity with file systems and data structures
- Basic knowledge of caching and performance optimization

---

## Tools vs. Resources
### The Fundamental Difference

Before diving into implementation, it's crucial to understand when to use tools versus resources. They serve different purposes in the MCP ecosystem.

### Tools: Active Operations
**Tools perform actions and return results based on parameters.**

```typescript
// Tool: Active, parameterized, can have side effects
{
  name: "search_database",
  description: "Search database with custom query",
  inputSchema: {
    properties: {
      query: { type: "string" },
      limit: { type: "number", default: 100 }
    }
  }
}
```

**When to use tools:**

- Data changes frequently or needs computation
- Operations require parameters or user input
- Actions have side effects (create, update, delete)
- Results need processing or transformation

### Resources: Passive Data
**Resources expose existing data that can be read and referenced.**

```typescript
// Resource: Passive, addressable, read-only
{
  uri: "db://users/123/profile",
  name: "User Profile",
  description: "User profile data for ID 123",
  mimeType: "application/json"
}
```

**When to use resources:**

- Data is relatively static or changes predictably
- Direct access to structured data is needed
- Content should be cached or bookmarked
- Data serves as context for LLM reasoning

### Decision Framework

| Scenario          | Use Tool | Use Resource | Why                       |
|-------------------|----------|--------------|---------------------------|
| Current weather   | ✅ Tool   | ❌ Resource   | Data changes constantly   |
| API documentation | ❌ Tool   | ✅ Resource   | Static reference material |
| Database search   | ✅ Tool   | ❌ Resource   | Requires query parameters |
| User profile      | ❌ Tool   | ✅ Resource   | Direct data access needed |
| File contents     | ❌ Tool   | ✅ Resource   | Static file data          |
| Generate report   | ✅ Tool   | ❌ Resource   | Computation required      |

---

## Resource Fundamentals

### Resource Structure

Every MCP resource has a consistent structure with metadata that helps LLMs understand what they're accessing:

```typescript
interface Resource {
  uri: string;           // Unique identifier (like a URL)
  name: string;          // Human-readable title
  description: string;   // What the resource contains
  mimeType?: string;     // Content type (optional but recommended)
}
```

### Resource Content

When a resource is read, it returns structured content:

```typescript
interface ResourceContent {
  contents: Array<{
    uri: string;
    mimeType?: string;
    text?: string;       // For text content
    blob?: string;       // For binary content (base64)
  }>;
}
```

**Key Points:**

- Resources are **read-only** by convention
- Content can be **text** or **binary** (base64 encoded)
- Multiple content items can be returned for complex resources
- `MIME (Multipurpose Internet Mail Extensions) types` help clients handle content appropriately

---

## Designing Resource URI Schemes

Effective URI design is crucial for resource organization and discoverability. A good URI scheme should be:

- **Hierarchical**: Reflects data organization
- **Descriptive**: Self-documenting structure
- **Consistent**: Follows patterns across similar resources
- **Extensible**: Allows for future additions

### Common URI Patterns

#### File System Resources
```
file:///project/src/index.ts
file:///docs/api-reference.md
file:///config/database.json
```

#### Database Resources
```
db://users/123/profile
db://products/category/electronics
db://orders/recent?limit=10
```

#### API Documentation
```
api://petstore/v1/swagger.json
api://github/repos/microsoft/vscode/issues
api://weather/current/london
```

#### Configuration Resources
```
config://app/settings
config://database/connection
config://logging/level
```

### URI Design Best Practices

1. **Use descriptive paths**: `users/active` vs `u/a`
2. **Include identifiers**: `orders/123` vs `current-order`
3. **Support hierarchies**: `docs/api/v1/endpoints`
4. **Use query parameters moderately**: Prefer path segments
5. **Be consistent**: Same patterns for similar resources

---

## Implementing Static Resources

Static resources represent fixed data that doesn't change or changes infrequently. They're perfect for documentation, configuration files, and reference data.

### Complete Static Resource Server

Here's a complete MCP server that exposes static resources:

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as fs from 'fs/promises';
import * as path from 'path';

/**
 * MCP Server exposing static file resources
 */
class StaticResourceServer {
  private server: Server;
  private resourceRoot: string;

  constructor(resourceRoot: string = './resources') {
    this.resourceRoot = path.resolve(resourceRoot);

    this.server = new Server(
      {
        name: "static-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    // List available resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = await this.discoverResources();
      return { resources };
    });

    // Read specific resource
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.readResource(uri);
      return { contents: [content] };
    });
  }

  private async discoverResources(): Promise<any[]> {
    const resources: any[] = [];

    try {
      const files = await this.walkDirectory(this.resourceRoot);

      for (const file of files) {
        const relativePath = path.relative(this.resourceRoot, file);
        const uri = `file:///${relativePath.replace(/\\/g, '/')}`;
        const mimeType = this.getMimeType(file);

        resources.push({
          uri,
          name: path.basename(file),
          description: `Static file: ${relativePath}`,
          mimeType,
        });
      }
    } catch (error) {
      console.error('Error discovering resources:', error);
    }

    return resources;
  }

  private async readResource(uri: string): Promise<any> {
    // Validate URI format
    if (!uri.startsWith('file:///')) {
      throw new Error(`Invalid URI format: ${uri}`);
    }

    const relativePath = uri.substring('file:///'.length);
    const filePath = path.join(this.resourceRoot, relativePath);

    // Security: Prevent directory traversal
    const resolvedPath = path.resolve(filePath);
    if (!resolvedPath.startsWith(this.resourceRoot)) {
      throw new Error('Access denied: path outside resource root');
    }

    try {
      const content = await fs.readFile(filePath, 'utf8');
      const mimeType = this.getMimeType(filePath);

      return {
        uri,
        mimeType,
        text: content,
      };
    } catch (error) {
      throw new Error(`Failed to read resource: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private async walkDirectory(dir: string): Promise<string[]> {
    const files: string[] = [];

    try {
      const entries = await fs.readdir(dir, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);

        if (entry.isDirectory()) {
          // Skip hidden directories and node_modules
          if (!entry.name.startsWith('.') && entry.name !== 'node_modules') {
            files.push(...await this.walkDirectory(fullPath));
          }
        } else if (entry.isFile()) {
          // Only include certain file types
          const ext = path.extname(entry.name).toLowerCase();
          if (['.md', '.txt', '.json', '.yaml', '.yml', '.js', '.ts', '.css', '.html'].includes(ext)) {
            files.push(fullPath);
          }
        }
      }
    } catch (error) {
      console.error(`Error walking directory ${dir}:`, error);
    }

    return files;
  }

  private getMimeType(filePath: string): string {
    const ext = path.extname(filePath).toLowerCase();

    const mimeTypes: { [key: string]: string } = {
      '.md': 'text/markdown',
      '.txt': 'text/plain',
      '.json': 'application/json',
      '.yaml': 'application/yaml',
      '.yml': 'application/yaml',
      '.js': 'application/javascript',
      '.ts': 'application/typescript',
      '.css': 'text/css',
      '.html': 'text/html',
    };

    return mimeTypes[ext] || 'text/plain';
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error(`Static Resource Server running on stdio (root: ${this.resourceRoot})`);
  }
}

// Main entry point
async function main() {
  const server = new StaticResourceServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

### Testing Static Resources

**Step 1: Create Test Resources**

First, let's create some test files that our static resource server can expose. These files will simulate a typical project structure with documentation, configuration, and general project files.

```bash
# Create the directory structure
mkdir -p resources/docs resources/config

# Create a markdown documentation file
echo "# API Documentation\n\nThis is the API docs." > resources/docs/api.md

# Create a JSON configuration file
echo '{"version": "1.0.0", "env": "development"}' > resources/config/settings.json

# Create a plain text README file
echo "Welcome to our project!" > resources/README.txt
```

**What this creates:**

- `resources/docs/api.md` - A markdown file with API documentation
- `resources/config/settings.json` - A JSON configuration file with version and environment info
- `resources/README.txt` - A plain text file with project information

<br>

**Step 2: Start the Server**

Now start your MCP server using the MCP Inspector. 

This will launch both your server and the testing interface:

```bash
npx @modelcontextprotocol/inspector tsx src/index.ts
```

**What to expect:**

- The MCP Inspector window should open in your browser
- Your server will start and connect via `stdio` transport
- You should see connection confirmation in the terminal
- The inspector interface will show tabs for Resources, Tools, etc.

<br>

**Step 3: Test Resource Discovery**

In the MCP Inspector, navigate to the **Resources** tab to see what resources your server is exposing.

- The MCP Inspector should show resources like:

    - `file:///docs/api.md` - Your API documentation file
    - `file:///config/settings.json` - Your configuration file
    - `file:///README.txt` - Your project README

**What to verify:**

- All three resources should be listed
- Each resource should have a descriptive name and description
- MIME types should be correctly detected (text/markdown, application/json, text/plain)
- URIs should follow the `file://` scheme with proper paths

<br>

**Step 4: Test Resource Reading**

Click on each resource in the list to read its content and verify proper handling.

- Click on `file:///docs/api.md`:

    - Should display: "# API Documentation\n\nThis is the API docs."
    - MIME type should be: text/markdown

- Click on `file:///config/settings.json`:

    - Should display: {"version": "1.0.0", "env": "development"}
    - MIME type should be: application/json

- Click on `file:///README.txt`:

    - Should display: "Welcome to our project!"
    - MIME type should be: text/plain

**Error Testing:**

- Try reading a non-existent resource like `file:///does-not-exist.txt`
- Should show an appropriate error message
- Verify the server handles invalid URIs gracefully

**What to learn:**

- Resources provide direct access to file content
- MIME types help clients handle different content types
- Error handling is important for robust resource servers
- The inspector provides a complete testing environment

---

## Implementing Dynamic Resources

Dynamic resources generate content on-demand based on parameters or current state. They're useful for live data, computed views, and parameterized access.

### Resource Templates

Resource templates allow parameterized URIs using `{parameter}` syntax:

```typescript
// Template definition
{
  uriTemplate: "db://users/{userId}/profile",
  name: "User Profile",
  description: "Profile data for a specific user",
  mimeType: "application/json"
}

// Generated URIs
"db://users/123/profile"
"db://users/456/profile"
```

### Complete Dynamic Resource Server

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListResourceTemplatesRequestSchema,
  ResourceTemplate,
} from "@modelcontextprotocol/sdk/types.js";

/**
 * MCP Server with dynamic resources and templates
 */
class DynamicResourceServer {
  private server: Server;

  // Mock data store
  private users = [
    { id: 1, name: "Alice Johnson", email: "alice@example.com", role: "admin" },
    { id: 2, name: "Bob Smith", email: "bob@example.com", role: "user" },
    { id: 3, name: "Charlie Brown", email: "charlie@example.com", role: "user" },
  ];

  private products = [
    { id: 1, name: "Laptop", price: 999.99, category: "Electronics" },
    { id: 2, name: "Book", price: 19.99, category: "Education" },
    { id: 3, name: "Coffee Mug", price: 12.50, category: "Kitchen" },
  ];

  constructor() {
    this.server = new Server(
      {
        name: "dynamic-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    // List resource templates
    this.server.setRequestHandler(ListResourceTemplatesRequestSchema, async () => {
      const templates: ResourceTemplate[] = [
        {
          uriTemplate: "db://users/{userId}/profile",
          name: "User Profile",
          description: "Profile information for a specific user",
          mimeType: "application/json",
        },
        {
          uriTemplate: "db://products/{productId}/details",
          name: "Product Details",
          description: "Detailed information about a product",
          mimeType: "application/json",
        },
        {
          uriTemplate: "db://stats/{category}/summary",
          name: "Category Statistics",
          description: "Statistical summary for a product category",
          mimeType: "application/json",
        },
      ];

      return { resourceTemplates: templates };
    });

    // List available resources (dynamic)
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources: any[] = [];

      // Add user resources
      for (const user of this.users) {
        resources.push({
          uri: `db://users/${user.id}/profile`,
          name: `User: ${user.name}`,
          description: `Profile for ${user.name}`,
          mimeType: "application/json",
        });
      }

      // Add product resources
      for (const product of this.products) {
        resources.push({
          uri: `db://products/${product.id}/details`,
          name: `Product: ${product.name}`,
          description: `${product.category} - $${product.price}`,
          mimeType: "application/json",
        });
      }

      // Add category stats
      const categories = [...new Set(this.products.map(p => p.category))];
      for (const category of categories) {
        resources.push({
          uri: `db://stats/${category}/summary`,
          name: `${category} Statistics`,
          description: `Summary statistics for ${category}`,
          mimeType: "application/json",
        });
      }

      return { resources };
    });

    // Read specific resource
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.generateResourceContent(uri);
      return { contents: [content] };
    });
  }

  private async generateResourceContent(uri: string): Promise<any> {
    const parts = uri.split('/');

    if (parts[0] === 'db:' && parts[1] === '') {
      const type = parts[2];
      const id = parts[3];
      const action = parts[4];

      switch (type) {
        case 'users':
          if (action === 'profile') {
            const user = this.users.find(u => u.id === parseInt(id));
            if (!user) throw new Error(`User ${id} not found`);

            return {
              uri,
              mimeType: "application/json",
              text: JSON.stringify({
                user,
                metadata: {
                  lastUpdated: new Date().toISOString(),
                  source: "dynamic-resource-server"
                }
              }, null, 2),
            };
          }
          break;

        case 'products':
          if (action === 'details') {
            const product = this.products.find(p => p.id === parseInt(id));
            if (!product) throw new Error(`Product ${id} not found`);

            return {
              uri,
              mimeType: "application/json",
              text: JSON.stringify({
                product,
                metadata: {
                  lastUpdated: new Date().toISOString(),
                  inStock: Math.random() > 0.3 // Simulate stock status
                }
              }, null, 2),
            };
          }
          break;

        case 'stats':
          if (action === 'summary') {
            const category = id;
            const categoryProducts = this.products.filter(p => p.category === category);

            if (categoryProducts.length === 0) {
              throw new Error(`Category '${category}' not found`);
            }

            const stats = {
              category,
              totalProducts: categoryProducts.length,
              averagePrice: categoryProducts.reduce((sum, p) => sum + p.price, 0) / categoryProducts.length,
              priceRange: {
                min: Math.min(...categoryProducts.map(p => p.price)),
                max: Math.max(...categoryProducts.map(p => p.price)),
              },
              generatedAt: new Date().toISOString(),
            };

            return {
              uri,
              mimeType: "application/json",
              text: JSON.stringify(stats, null, 2),
            };
          }
          break;
      }
    }

    throw new Error(`Unknown resource URI: ${uri}`);
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Dynamic Resource Server running on stdio");
  }
}

// Main entry point
async function main() {
  const server = new DynamicResourceServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

### Testing Dynamic Resources

**Step 1: Start the Server**

```bash
npx @modelcontextprotocol/inspector tsx src/index.ts
```

**Step 2: Test Resource Templates**

- Check that templates are listed: `db://users/{userId}/profile`, etc.

**Step 3: Test Resource Discovery**

- Should show individual resources for users, products, and categories

**Step 4: Test Resource Reading**

- Try `db://users/1/profile` - should return user data
- Try `db://products/2/details` - should return product data
- Try `db://stats/Electronics/summary` - should return category stats
- Test invalid URIs to verify error handling

---

## Resource Subscriptions for Live Updates

Resource subscriptions enable real-time updates when resource content changes. This is essential for live data, monitoring dashboards, and collaborative environments.

### Subscription Implementation

```typescript
// Enable subscriptions in server capabilities
{
  capabilities: {
    resources: {
      subscribe: true  // Enable subscription support
    },
  },
}
```

### Complete Subscription Server

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  SubscribeRequestSchema,
  UnsubscribeRequestSchema,
  ResourceUpdatedNotificationSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
 * MCP Server with resource subscriptions for live updates
 */
class SubscriptionResourceServer {
  private server: Server;
  private subscribers: Map<string, Set<string>> = new Map(); // uri -> sessionIds
  private updateInterval: NodeJS.Timeout | null = null;

  // Simulated live data
  private metrics = {
    activeUsers: 42,
    serverLoad: 0.65,
    responseTime: 120,
    errorRate: 0.02,
  };

  constructor() {
    this.server = new Server(
      {
        name: "subscription-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {
            subscribe: true,
          },
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
    this.startMetricsSimulation();
  }

  private setupHandlers(): void {
    // List resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: "metrics://server/active-users",
            name: "Active Users",
            description: "Current number of active users",
            mimeType: "application/json",
          },
          {
            uri: "metrics://server/load",
            name: "Server Load",
            description: "Current server load percentage",
            mimeType: "application/json",
          },
          {
            uri: "metrics://server/response-time",
            name: "Response Time",
            description: "Average response time in milliseconds",
            mimeType: "application/json",
          },
          {
            uri: "metrics://server/error-rate",
            name: "Error Rate",
            description: "Current error rate percentage",
            mimeType: "application/json",
          },
        ],
      };
    });

    // Read resource
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = this.getMetricContent(uri);
      return { contents: [content] };
    });

    // Subscribe to resource updates
    this.server.setRequestHandler(SubscribeRequestSchema, async (request) => {
      const uri = request.params.uri;

      if (!this.subscribers.has(uri)) {
        this.subscribers.set(uri, new Set());
      }

      // In a real implementation, you'd get the session ID from the request
      // For this example, we'll use a mock session ID
      const sessionId = "mock-session";
      this.subscribers.get(uri)!.add(sessionId);

      console.error(`Subscribed to ${uri} (session: ${sessionId})`);

      return {};
    });

    // Unsubscribe from resource updates
    this.server.setRequestHandler(UnsubscribeRequestSchema, async (request) => {
      const uri = request.params.uri;
      const sessionId = "mock-session"; // Would come from request in real implementation

      if (this.subscribers.has(uri)) {
        this.subscribers.get(uri)!.delete(sessionId);

        if (this.subscribers.get(uri)!.size === 0) {
          this.subscribers.delete(uri);
        }
      }

      console.error(`Unsubscribed from ${uri} (session: ${sessionId})`);

      return {};
    });
  }

  private getMetricContent(uri: string): any {
    const metricName = uri.split('/').pop();

    if (!metricName || !(metricName in this.metrics)) {
      throw new Error(`Unknown metric: ${metricName}`);
    }

    const value = (this.metrics as any)[metricName];

    return {
      uri,
      mimeType: "application/json",
      text: JSON.stringify({
        metric: metricName,
        value,
        timestamp: new Date().toISOString(),
        unit: this.getMetricUnit(metricName),
      }, null, 2),
    };
  }

  private getMetricUnit(metricName: string): string {
    const units: { [key: string]: string } = {
      activeUsers: "users",
      serverLoad: "percentage",
      responseTime: "milliseconds",
      errorRate: "percentage",
    };
    return units[metricName] || "unit";
  }

  private startMetricsSimulation(): void {
    // Simulate changing metrics every 5 seconds
    this.updateInterval = setInterval(() => {
      // Randomly update metrics
      this.metrics.activeUsers += Math.floor(Math.random() * 10) - 5;
      this.metrics.activeUsers = Math.max(0, this.metrics.activeUsers);

      this.metrics.serverLoad = Math.random() * 0.5 + 0.3; // 0.3 to 0.8
      this.metrics.responseTime = 100 + Math.random() * 100; // 100-200ms
      this.metrics.errorRate = Math.random() * 0.05; // 0-5%

      // Notify subscribers of updates
      this.notifySubscribers();
    }, 5000);
  }

  private notifySubscribers(): void {
    for (const [uri, sessionIds] of this.subscribers) {
      if (sessionIds.size > 0) {
        // Send notification to all subscribers of this resource
        this.server.notification(ResourceUpdatedNotificationSchema, {
          uri,
        });

        console.error(`Notified ${sessionIds.size} subscribers of ${uri} update`);
      }
    }
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      if (this.updateInterval) {
        clearInterval(this.updateInterval);
      }
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Subscription Resource Server running on stdio");
  }
}

// Main entry point
async function main() {
  const server = new SubscriptionResourceServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

### Testing Subscriptions

**Step 1: Start the Server**

```bash
npx @modelcontextprotocol/inspector tsx src/index.ts
```

**Step 2: Test Basic Resource Reading**

- Read metrics like `metrics://server/active-users`
- Verify they return current values

**Step 3: Test Subscriptions**

- Subscribe to a metric resource:

    - In the MCP Inspector Resources tab, find a metric resource (e.g., `metrics://server/active-users`)
    - Click the "Subscribe" button next to the resource
    - You should see a confirmation that subscription was successful

- Watch the MCP Inspector for update notifications every 5 seconds:

    - Keep the Resources tab open
    - Look for notification messages in the inspector interface
    - The metric values should update automatically every 5 seconds
    - You can also check the console/logs for subscription update messages

- Unsubscribe and verify notifications stop:

    - Click the "Unsubscribe" button for the same resource
    - Confirm that update notifications cease
    - The metric values should stop updating in the interface

---

## Security and Access Control

Resource security is critical, especially when exposing sensitive data or system information.

### Access Control Patterns

#### 1. Path-Based Authorization

```typescript
private checkResourceAccess(uri: string, userId?: string): boolean {
  // Allow access to own profile
  if (uri.startsWith(`users/${userId}/`)) {
    return true;
  }

  // Restrict admin resources
  if (uri.startsWith('admin/') && !this.isAdmin(userId)) {
    return false;
  }

  // Public resources
  if (uri.startsWith('public/')) {
    return true;
  }

  return false;
}
```

**How it works:** This method checks if a user has permission to access a resource based on the URI path. It grants access to user-specific resources (like their own profile), restricts admin-only resources unless the user has admin privileges, allows public resources for everyone, and denies access by default for any other paths.

<br>

#### 2. Content Filtering

```typescript
private filterSensitiveContent(content: any, userRole: string): any {
  if (userRole !== 'admin') {
    // Remove sensitive fields for non-admin users
    const { password, ssn, ...filtered } = content;
    return filtered;
  }
  return content;
}
```

**How it works:** This function removes sensitive information from resource content based on user roles. For non-admin users, it uses object destructuring to exclude sensitive fields like passwords and social security numbers, returning a filtered version of the data. Admin users see the complete, unfiltered content.

<br>

#### 3. Rate Limiting

```typescript
private rateLimiter = new Map<string, { count: number; resetTime: number }>();

private checkRateLimit(identifier: string, maxRequests: number = 100): boolean {
  const now = Date.now();
  const windowMs = 60000; // 1 minute

  const record = this.rateLimiter.get(identifier);

  if (!record || now > record.resetTime) {
    this.rateLimiter.set(identifier, { count: 1, resetTime: now + windowMs });
    return true;
  }

  if (record.count >= maxRequests) {
    return false;
  }

  record.count++;
  return true;
}
```

**How it works:** This implements a sliding window rate limiter using a Map to track request counts per identifier (like user ID or IP address). It allows up to `maxRequests` (default 100) within a 1-minute window. When the limit is exceeded, it returns false to block the request. The window resets automatically after the time period expires.

---

## Combining Resources with Tools

**The most powerful MCP servers combine resources and tools to provide a comprehensive functionality!**

### Complete Hybrid Server

The following example demonstrates a server that combines both resources and tools, showing how they work together to provide comprehensive functionality. 

The server maintains a document store that can be both read as resources and modified through tools.

```typescript title="Hybrid Server Class"
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListToolsRequestSchema,
  CallToolRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
 * MCP Server combining resources and tools
 */
class HybridServer {
  private server: Server;
  private documents: Map<string, any> = new Map();

  constructor() {
    this.server = new Server(
      {
        name: "hybrid-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},  // Enable resource capabilities
          tools: {},      // Enable tool capabilities
        },
      }
    );

    // Initialize some sample documents
    this.documents.set("doc1", {
      id: "doc1",
      title: "Getting Started Guide",
      content: "This is a comprehensive guide to getting started...",
      tags: ["tutorial", "beginner"],
      created: new Date().toISOString(),
    });

    this.setupHandlers();
    this.setupErrorHandling();
  }
```



**Key setup points:**

- The server declares both `resources: {}` and `tools: {}` capabilities
- A Map is used to store documents in memory
- Sample data is initialized to demonstrate functionality

<br>

```typescript title="Setup Handlers Method"
  private setupHandlers(): void {
    // Resource handlers - provide read-only access to documents
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = Array.from(this.documents.entries()).map(([id, doc]) => ({
        uri: `docs://documents/${id}`,
        name: doc.title,
        description: `Document: ${doc.title}`,
        mimeType: "application/json",
      }));

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = this.readDocument(uri);
      return { contents: [content] };
    });

    // Tool handlers - provide write operations for documents
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "create_document",
            description: "Create a new document",
            inputSchema: {
              type: "object",
              properties: {
                title: { type: "string" },
                content: { type: "string" },
                tags: {
                  type: "array",
                  items: { type: "string" },
                  default: [],
                },
              },
              required: ["title", "content"],
            },
          },
          {
            name: "search_documents",
            description: "Search documents by content or tags",
            inputSchema: {
              type: "object",
              properties: {
                query: { type: "string" },
                tag: { type: "string" },
                limit: { type: "number", default: 10 },
              },
            },
          },
          {
            name: "update_document",
            description: "Update an existing document",
            inputSchema: {
              type: "object",
              properties: {
                id: { type: "string" },
                title: { type: "string" },
                content: { type: "string" },
                tags: { type: "array", items: { type: "string" } },
              },
              required: ["id"],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case "create_document":
          return this.createDocument(args);

        case "search_documents":
          return this.searchDocuments(args);

        case "update_document":
          return this.updateDocument(args);

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }
```

**Resource vs Tool handlers:**

- **Resources** expose existing documents for reading (`docs://documents/{id}`)
- **Tools** provide operations to create, search, and update documents
- Resources are passive (read-only), tools are active (perform actions)

<br>

```typescript title="Read Document Method"
  private readDocument(uri: string): any {
    const match = uri.match(/^docs:\/\/documents\/(.+)$/);
    if (!match) throw new Error(`Invalid document URI: ${uri}`);

    const id = match[1];
    const doc = this.documents.get(id);

    if (!doc) throw new Error(`Document not found: ${id}`);

    return {
      uri,
      mimeType: "application/json",
      text: JSON.stringify(doc, null, 2),
    };
  }
```

**Resource reading:** Parses the URI to extract the document ID, retrieves the document from the Map, and returns it as JSON content.

<br>

```typescript title="Create Document Method"
  private createDocument(args: any): any {
    const id = `doc${Date.now()}`;
    const doc = {
      id,
      title: args.title,
      content: args.content,
      tags: args.tags || [],
      created: new Date().toISOString(),
      modified: new Date().toISOString(),
    };

    this.documents.set(id, doc);

    return {
      content: [
        {
          type: "text",
          text: `Document created successfully!\n\nID: ${id}\nTitle: ${doc.title}\nURI: docs://documents/${id}`,
        },
      ],
    };
  }
```

**Tool implementation:** Creates a new document with a timestamp-based ID, stores it in the Map, and returns success information including the new document's URI.

<br>

```typescript title="Search Documents Method"
  private searchDocuments(args: any): any {
    let results = Array.from(this.documents.values());

    if (args.query) {
      const query = args.query.toLowerCase();
      results = results.filter(doc =>
        doc.title.toLowerCase().includes(query) ||
        doc.content.toLowerCase().includes(query)
      );
    }

    if (args.tag) {
      results = results.filter(doc => doc.tags.includes(args.tag));
    }

    const limit = args.limit || 10;
    results = results.slice(0, limit);

    const formatted = results.map(doc => ({
      id: doc.id,
      title: doc.title,
      tags: doc.tags,
      uri: `docs://documents/${doc.id}`,
    }));

    return {
      content: [
        {
          type: "text",
          text: `Found ${results.length} documents:\n\n${formatted.map(doc =>
            `📄 ${doc.title} (${doc.tags.join(', ')})\n   URI: ${doc.uri}`
          ).join('\n\n')}`,
        },
      ],
    };
  }
```

**Search tool:** Filters documents by query string or tag, limits results, and returns formatted text output with document URIs for easy access.

<br>

```typescript title="Update Document Method"
  private updateDocument(args: any): any {
    const doc = this.documents.get(args.id);
    if (!doc) throw new Error(`Document not found: ${args.id}`);

    if (args.title) doc.title = args.title;
    if (args.content) doc.content = args.content;
    if (args.tags) doc.tags = args.tags;
    doc.modified = new Date().toISOString();

    return {
      content: [
        {
          type: "text",
          text: `Document updated successfully!\n\nID: ${doc.id}\nTitle: ${doc.title}\nModified: ${doc.modified}`,
        },
      ],
    };
  }
```

**Update tool:** Modifies existing document fields and updates the modification timestamp, providing feedback about the changes made.

<br>

**How resources and tools complement each other:**

- **Resources** provide passive access: LLMs can read documents at `docs://documents/{id}`
- **Tools** enable active operations: LLMs can create, search, and update documents
- **Integration**: Tools can reference resources in their responses (e.g., "Read the new document at docs://documents/123")
- **Workflow**: Create documents with tools, then read them as resources for context

---

## Hands-On Exercises

### Exercise 1: File System Resource Server

Create a tool that:

- Exposes a directory as MCP resources
- Supports different file types (text, JSON, Markdown)
- Implements proper security (no directory traversal)
- Includes file metadata (size, modified date)

<details>
<summary>💡 Solution: File System Resource Server</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "create_file_resource_server",
  description: "Create an MCP server that exposes a directory as resources",
  inputSchema: {
    type: "object",
    properties: {
      directory: {
        type: "string",
        description: "Directory path to expose as resources",
        default: "./files"
      },
      allowedExtensions: {
        type: "array",
        description: "File extensions to include",
        items: { type: "string" },
        default: [".md", ".txt", ".json", ".yaml", ".yml"]
      },
      maxFileSize: {
        type: "number",
        description: "Maximum file size in bytes",
        default: 1048576
      }
    },
    required: ["directory"]
  }
}
```

Implementation:

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import * as fs from 'fs/promises';
import * as path from 'path';

class FileSystemResourceServer {
  private server: Server;
  private rootDir: string;
  private allowedExtensions: string[];
  private maxFileSize: number;

  constructor(rootDir: string = './files', allowedExtensions: string[] = ['.md', '.txt', '.json', '.yaml', '.yml'], maxFileSize: number = 1048576) {
    this.rootDir = path.resolve(rootDir);
    this.allowedExtensions = allowedExtensions;
    this.maxFileSize = maxFileSize;

    this.server = new Server(
      {
        name: "filesystem-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = await this.discoverFiles();
      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.readFile(uri);
      return { contents: [content] };
    });
  }

  private async discoverFiles(): Promise<any[]> {
    const resources: any[] = [];

    try {
      const files = await this.walkDirectory(this.rootDir);

      for (const file of files) {
        const relativePath = path.relative(this.rootDir, file);
        const uri = `file:///${relativePath.replace(/\\/g, '/')}`;
        const stats = await fs.stat(file);
        const mimeType = this.getMimeType(file);

        resources.push({
          uri,
          name: path.basename(file),
          description: `File: ${relativePath} (${this.formatFileSize(stats.size)})`,
          mimeType,
        });
      }
    } catch (error) {
      console.error('Error discovering files:', error);
    }

    return resources;
  }

  private async readFile(uri: string): Promise<any> {
    if (!uri.startsWith('file:///')) {
      throw new Error(`Invalid URI format: ${uri}`);
    }

    const relativePath = uri.substring('file:///'.length);
    const filePath = path.join(this.rootDir, relativePath);

    // Security: Prevent directory traversal
    const resolvedPath = path.resolve(filePath);
    if (!resolvedPath.startsWith(this.rootDir)) {
      throw new Error('Access denied: path outside allowed directory');
    }

    // Check if file extension is allowed
    const ext = path.extname(filePath).toLowerCase();
    if (!this.allowedExtensions.includes(ext)) {
      throw new Error(`File type not allowed: ${ext}`);
    }

    try {
      const stats = await fs.stat(filePath);

      // Check file size
      if (stats.size > this.maxFileSize) {
        throw new Error(`File too large: ${stats.size} bytes (max: ${this.maxFileSize})`);
      }

      const content = await fs.readFile(filePath, 'utf8');
      const mimeType = this.getMimeType(filePath);

      return {
        uri,
        mimeType,
        text: content,
      };
    } catch (error) {
      throw new Error(`Failed to read file: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private async walkDirectory(dir: string): Promise<string[]> {
    const files: string[] = [];

    try {
      const entries = await fs.readdir(dir, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);

        if (entry.isDirectory()) {
          // Skip hidden directories
          if (!entry.name.startsWith('.')) {
            files.push(...await this.walkDirectory(fullPath));
          }
        } else if (entry.isFile()) {
          const ext = path.extname(entry.name).toLowerCase();
          if (this.allowedExtensions.includes(ext)) {
            files.push(fullPath);
          }
        }
      }
    } catch (error) {
      console.error(`Error walking directory ${dir}:`, error);
    }

    return files;
  }

  private getMimeType(filePath: string): string {
    const ext = path.extname(filePath).toLowerCase();
    const mimeTypes: { [key: string]: string } = {
      '.md': 'text/markdown',
      '.txt': 'text/plain',
      '.json': 'application/json',
      '.yaml': 'application/yaml',
      '.yml': 'application/yaml',
    };
    return mimeTypes[ext] || 'text/plain';
  }

  private formatFileSize(bytes: number): string {
    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return `${size.toFixed(1)} ${units[unitIndex]}`;
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error(`File System Resource Server running (root: ${this.rootDir})`);
  }
}

// Main entry point
async function main() {
  const server = new FileSystemResourceServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

Testing - Create test files and test the server:

```bash
mkdir -p files/docs files/data
echo "# API Documentation" > files/docs/api.md
echo '{"version": "1.0.0"}' > files/data/config.json
echo "Simple text file" > files/docs/notes.txt
```

Test with MCP Inspector to verify file discovery and reading.

</details>


### Exercise 2: REST API Resource Server

Create a tool that:

- Exposes REST API endpoints as resources
- Supports query parameters in URIs
- Handles authentication and rate limiting
- Caches responses appropriately

<details>
<summary>💡 Solution: REST API Resource Server</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "create_api_resource_server",
  description: "Create an MCP server that exposes REST API endpoints as resources",
  inputSchema: {
    type: "object",
    properties: {
      baseUrl: {
        type: "string",
        description: "Base URL of the API to expose",
        format: "uri"
      },
      apiKey: {
        type: "string",
        description: "API key for authentication"
      },
      cacheEnabled: {
        type: "boolean",
        description: "Enable response caching",
        default: true
      },
      cacheTTL: {
        type: "number",
        description: "Cache TTL in seconds",
        default: 300
      },
      rateLimit: {
        type: "number",
        description: "Requests per minute limit",
        default: 60
      }
    },
    required: ["baseUrl"]
  }
}
```

Implementation

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListResourceTemplatesRequestSchema,
  ResourceTemplate,
} from "@modelcontextprotocol/sdk/types.js";
import axios, { AxiosResponse } from 'axios';

interface CacheEntry {
  data: any;
  timestamp: number;
  ttl: number;
}

class APIResourceServer {
  private server: Server;
  private baseUrl: string;
  private apiKey?: string;
  private cache: Map<string, CacheEntry> = new Map();
  private cacheEnabled: boolean;
  private cacheTTL: number;
  private rateLimit: number;
  private requestCounts: Map<string, { count: number; resetTime: number }> = new Map();

  constructor(baseUrl: string, apiKey?: string, cacheEnabled: boolean = true, cacheTTL: number = 300, rateLimit: number = 60) {
    this.baseUrl = baseUrl.replace(/\/$/, ''); // Remove trailing slash
    this.apiKey = apiKey;
    this.cacheEnabled = cacheEnabled;
    this.cacheTTL = cacheTTL;
    this.rateLimit = rateLimit;

    this.server = new Server(
      {
        name: "api-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
    this.startCacheCleanup();
  }

  private setupHandlers(): void {
    this.server.setRequestHandler(ListResourceTemplatesRequestSchema, async () => {
      const templates: ResourceTemplate[] = [
        {
          uriTemplate: "api://users/{userId}",
          name: "User Profile",
          description: "User profile data from API",
          mimeType: "application/json",
        },
        {
          uriTemplate: "api://posts/{postId}",
          name: "Post Details",
          description: "Post details from API",
          mimeType: "application/json",
        },
        {
          uriTemplate: "api://search?q={query}&type={type}",
          name: "Search Results",
          description: "Search API results",
          mimeType: "application/json",
        },
      ];

      return { resourceTemplates: templates };
    });

    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      // For demonstration, we'll provide some example resources
      // In a real implementation, you might fetch these from the API
      const resources = [
        {
          uri: "api://status",
          name: "API Status",
          description: "Current API status and health",
          mimeType: "application/json",
        },
        {
          uri: "api://info",
          name: "API Information",
          description: "API metadata and capabilities",
          mimeType: "application/json",
        },
      ];

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.fetchAPIResource(uri);
      return { contents: [content] };
    });
  }

  private async fetchAPIResource(uri: string): Promise<any> {
    // Check rate limit
    if (!this.checkRateLimit()) {
      throw new Error("Rate limit exceeded. Please try again later.");
    }

    // Check cache first
    if (this.cacheEnabled) {
      const cached = this.getCached(uri);
      if (cached) {
        return {
          uri,
          mimeType: "application/json",
          text: JSON.stringify({
            ...cached,
            cached: true,
            cacheAge: Math.floor((Date.now() - cached._cacheTimestamp) / 1000),
          }, null, 2),
        };
      }
    }

    try {
      const apiPath = this.uriToAPIPath(uri);
      const url = `${this.baseUrl}${apiPath}`;

      const headers: any = {
        'User-Agent': 'MCP-API-Resource-Server/1.0',
      };

      if (this.apiKey) {
        headers['Authorization'] = `Bearer ${this.apiKey}`;
        // Or: headers['X-API-Key'] = this.apiKey;
      }

      const response: AxiosResponse = await axios.get(url, {
        headers,
        timeout: 10000,
      });

      const data = {
        ...response.data,
        _metadata: {
          statusCode: response.status,
          url: url,
          fetchedAt: new Date().toISOString(),
          contentType: response.headers['content-type'],
        }
      };

      // Cache the response
      if (this.cacheEnabled) {
        this.setCache(uri, data);
      }

      return {
        uri,
        mimeType: "application/json",
        text: JSON.stringify(data, null, 2),
      };

    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response) {
          throw new Error(`API Error ${error.response.status}: ${error.response.statusText}`);
        } else if (error.code === 'ECONNREFUSED') {
          throw new Error(`Cannot connect to API: ${this.baseUrl}`);
        } else {
          throw new Error(`Network error: ${error.message}`);
        }
      } else {
        throw new Error(`Failed to fetch API resource: ${error instanceof Error ? error.message : 'Unknown error'}`);
      }
    }
  }

  private uriToAPIPath(uri: string): string {
    if (!uri.startsWith('api://')) {
      throw new Error(`Invalid API URI: ${uri}`);
    }

    const path = uri.substring('api://'.length);

    // Handle special cases
    if (path === 'status') return '/status';
    if (path === 'info') return '/info';

    // Handle template URIs
    if (path.startsWith('users/')) {
      const userId = path.substring('users/'.length);
      return `/users/${userId}`;
    }

    if (path.startsWith('posts/')) {
      const postId = path.substring('posts/'.length);
      return `/posts/${postId}`;
    }

    if (path.startsWith('search?')) {
      // Convert query parameters
      const queryString = path.substring('search?'.length);
      return `/search?${queryString}`;
    }

    // Default: use path as-is
    return `/${path}`;
  }

  private checkRateLimit(): boolean {
    const now = Date.now();
    const windowMs = 60000; // 1 minute
    const key = 'global'; // In a real app, use user/session ID

    const record = this.requestCounts.get(key);

    if (!record || now > record.resetTime) {
      this.requestCounts.set(key, { count: 1, resetTime: now + windowMs });
      return true;
    }

    if (record.count >= this.rateLimit) {
      return false;
    }

    record.count++;
    return true;
  }

  private getCached(uri: string): any | null {
    const cached = this.cache.get(uri);
    if (!cached) return null;

    if (Date.now() - cached.timestamp > cached.ttl * 1000) {
      this.cache.delete(uri);
      return null;
    }

    return cached.data;
  }

  private setCache(uri: string, data: any): void {
    this.cache.set(uri, {
      data: { ...data, _cacheTimestamp: Date.now() },
      timestamp: Date.now(),
      ttl: this.cacheTTL,
    });
  }

  private startCacheCleanup(): void {
    // Clean up expired cache entries every 5 minutes
    setInterval(() => {
      const now = Date.now();
      for (const [uri, entry] of this.cache.entries()) {
        if (now - entry.timestamp > entry.ttl * 1000) {
          this.cache.delete(uri);
        }
      }
    }, 5 * 60 * 1000);
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error(`API Resource Server running (API: ${this.baseUrl})`);
  }
}

// Main entry point
async function main() {
  // Example: JSONPlaceholder API
  const server = new APIResourceServer('https://jsonplaceholder.typicode.com');
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

Testing - Test the server with the JSONPlaceholder API:

```bash
# Start the server
npx @modelcontextprotocol/inspector tsx src/index.ts
```

Test these resources in the MCP Inspector:

```javascript
// API status
{ uri: "api://status" }

// API info
{ uri: "api://info" }

// User profiles (using templates)
{ uri: "api://users/1" }
{ uri: "api://users/2" }

// Posts
{ uri: "api://posts/1" }

// Search (if supported by API)
{ uri: "api://search?q=lorem&type=post" }
```

</details>


### Exercise 3: Database Resource Server

Create a tool that:

- Exposes database tables as resources
- Supports parameterized queries via URI templates
- Implements read-only access for security
- Provides metadata about table schemas

<details>
<summary>💡 Solution: Database Resource Server</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "create_database_resource_server",
  description: "Create an MCP server that exposes database tables as resources",
  inputSchema: {
    type: "object",
    properties: {
      databasePath: {
        type: "string",
        description: "Path to SQLite database file",
        default: "./data.db"
      },
      allowedTables: {
        type: "array",
        description: "Tables to expose as resources",
        items: { type: "string" },
        default: []
      },
      readOnly: {
        type: "boolean",
        description: "Enforce read-only access",
        default: true
      },
      maxRows: {
        type: "number",
        description: "Maximum rows to return per query",
        default: 1000
      }
    },
    required: ["databasePath"]
  }
}
```

Implementation

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListResourceTemplatesRequestSchema,
  ResourceTemplate,
} from "@modelcontextprotocol/sdk/types.js";
import Database from 'better-sqlite3';
import * as fs from 'fs/promises';
import * as path from 'path';

interface TableInfo {
  name: string;
  columns: Array<{
    name: string;
    type: string;
    notnull: number;
    pk: number;
  }>;
  rowCount: number;
}

class DatabaseResourceServer {
  private server: Server;
  private dbPath: string;
  private allowedTables: string[];
  private readOnly: boolean;
  private maxRows: number;
  private db: Database.Database | null = null;

  constructor(dbPath: string = './data.db', allowedTables: string[] = [], readOnly: boolean = true, maxRows: number = 1000) {
    this.dbPath = path.resolve(dbPath);
    this.allowedTables = allowedTables;
    this.readOnly = readOnly;
    this.maxRows = maxRows;

    this.server = new Server(
      {
        name: "database-resource-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    this.server.setRequestHandler(ListResourceTemplatesRequestSchema, async () => {
      const templates: ResourceTemplate[] = [
        {
          uriTemplate: "db://tables/{tableName}/schema",
          name: "Table Schema",
          description: "Schema information for a database table",
          mimeType: "application/json",
        },
        {
          uriTemplate: "db://tables/{tableName}/data?limit={limit}&offset={offset}",
          name: "Table Data",
          description: "Data from a database table with pagination",
          mimeType: "application/json",
        },
        {
          uriTemplate: "db://tables/{tableName}/records/{id}",
          name: "Table Record",
          description: "Specific record from a database table",
          mimeType: "application/json",
        },
        {
          uriTemplate: "db://query?sql={sql}&params={params}",
          name: "Custom Query",
          description: "Execute a custom SELECT query",
          mimeType: "application/json",
        },
      ];

      return { resourceTemplates: templates };
    });

    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources: any[] = [];

      try {
        await this.ensureDatabase();
        const tables = this.getTableInfo();

        for (const table of tables) {
          // Table schema resource
          resources.push({
            uri: `db://tables/${table.name}/schema`,
            name: `${table.name} Schema`,
            description: `Schema for table ${table.name} (${table.columns.length} columns)`,
            mimeType: "application/json",
          });

          // Table data resource
          resources.push({
            uri: `db://tables/${table.name}/data?limit=100`,
            name: `${table.name} Data`,
            description: `Data from table ${table.name} (${table.rowCount} rows)`,
            mimeType: "application/json",
          });
        }

        // Database info resource
        resources.push({
          uri: "db://info",
          name: "Database Info",
          description: "Database metadata and statistics",
          mimeType: "application/json",
        });

      } catch (error) {
        console.error('Error listing resources:', error);
      }

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.readDatabaseResource(uri);
      return { contents: [content] };
    });
  }

  private async ensureDatabase(): Promise<void> {
    if (this.db) return;

    // Check if database file exists
    try {
      await fs.access(this.dbPath, fs.constants.R_OK);
    } catch {
      throw new Error(`Database file not found: ${this.dbPath}`);
    }

    // Open database in read-only mode if specified
    this.db = new Database(this.dbPath, { readonly: this.readOnly });
  }

  private getTableInfo(): TableInfo[] {
    if (!this.db) throw new Error('Database not initialized');

    const tables: TableInfo[] = [];

    // Get all tables
    const tableNames = this.db.prepare(`
      SELECT name FROM sqlite_master 
      WHERE type='table' AND name NOT LIKE 'sqlite_%'
    `).all() as Array<{ name: string }>;

    for (const { name } of tableNames) {
      // Check if table is allowed
      if (this.allowedTables.length > 0 && !this.allowedTables.includes(name)) {
        continue;
      }

      // Get column info
      const columns = this.db.prepare(`PRAGMA table_info(${name})`).all() as any[];

      // Get row count
      const rowCount = (this.db.prepare(`SELECT COUNT(*) as count FROM ${name}`).get() as any).count;

      tables.push({
        name,
        columns: columns.map(col => ({
          name: col.name,
          type: col.type,
          notnull: col.notnull,
          pk: col.pk,
        })),
        rowCount,
      });
    }

    return tables;
  }

  private async readDatabaseResource(uri: string): Promise<any> {
    await this.ensureDatabase();

    if (!uri.startsWith('db://')) {
      throw new Error(`Invalid database URI: ${uri}`);
    }

    const path = uri.substring('db://'.length);

    if (path === 'info') {
      return this.getDatabaseInfo();
    }

    if (path.startsWith('tables/')) {
      return this.readTableResource(path.substring('tables/'.length));
    }

    if (path.startsWith('query?')) {
      return this.executeCustomQuery(path.substring('query?'.length));
    }

    throw new Error(`Unknown database resource: ${uri}`);
  }

  private getDatabaseInfo(): any {
    if (!this.db) throw new Error('Database not initialized');

    const tables = this.getTableInfo();
    const dbStats = this.db.prepare(`
      SELECT 
        COUNT(*) as tableCount,
        SUM(
          (SELECT COUNT(*) FROM sqlite_master WHERE type='index') +
          (SELECT COUNT(*) FROM pragma_table_info(name))
        ) as totalColumns
      FROM sqlite_master 
      WHERE type='table' AND name NOT LIKE 'sqlite_%'
    `).get() as any;

    return {
      uri: "db://info",
      mimeType: "application/json",
      text: JSON.stringify({
        database: {
          path: this.dbPath,
          readOnly: this.readOnly,
          tableCount: dbStats.tableCount,
          totalColumns: dbStats.totalColumns,
        },
        tables: tables.map(t => ({
          name: t.name,
          columns: t.columns.length,
          rows: t.rowCount,
          primaryKey: t.columns.find(c => c.pk)?.name,
        })),
        server: {
          maxRows: this.maxRows,
          allowedTables: this.allowedTables.length > 0 ? this.allowedTables : 'all',
        },
      }, null, 2),
    };
  }

  private readTableResource(tablePath: string): any {
    if (!this.db) throw new Error('Database not initialized');

    const parts = tablePath.split('/');
    const tableName = parts[0];
    const action = parts[1];

    // Validate table access
    if (this.allowedTables.length > 0 && !this.allowedTables.includes(tableName)) {
      throw new Error(`Access denied to table: ${tableName}`);
    }

    switch (action) {
      case 'schema':
        return this.getTableSchema(tableName);

      case 'data':
        const url = new URL(`db://tables/${tablePath}`);
        const limit = parseInt(url.searchParams.get('limit') || '100');
        const offset = parseInt(url.searchParams.get('offset') || '0');
        return this.getTableData(tableName, limit, offset);

      case 'records':
        const recordId = parts[2];
        return this.getTableRecord(tableName, recordId);

      default:
        throw new Error(`Unknown table action: ${action}`);
    }
  }

  private getTableSchema(tableName: string): any {
    if (!this.db) throw new Error('Database not initialized');

    const tables = this.getTableInfo();
    const table = tables.find(t => t.name === tableName);

    if (!table) {
      throw new Error(`Table not found: ${tableName}`);
    }

    return {
      uri: `db://tables/${tableName}/schema`,
      mimeType: "application/json",
      text: JSON.stringify({
        table: tableName,
        columns: table.columns,
        rowCount: table.rowCount,
        indexes: this.getTableIndexes(tableName),
      }, null, 2),
    };
  }

  private getTableData(tableName: string, limit: number, offset: number): any {
    if (!this.db) throw new Error('Database not initialized');

    // Validate limits
    const actualLimit = Math.min(limit, this.maxRows);
    const actualOffset = Math.max(0, offset);

    const query = `SELECT * FROM ${tableName} LIMIT ? OFFSET ?`;
    const rows = this.db.prepare(query).all(actualLimit, actualOffset) as any[];

    return {
      uri: `db://tables/${tableName}/data?limit=${actualLimit}&offset=${actualOffset}`,
      mimeType: "application/json",
      text: JSON.stringify({
        table: tableName,
        query: {
          limit: actualLimit,
          offset: actualOffset,
          totalRows: rows.length,
        },
        data: rows,
      }, null, 2),
    };
  }

  private getTableRecord(tableName: string, recordId: string): any {
    if (!this.db) throw new Error('Database not initialized');

    // Get primary key column
    const columns = this.db.prepare(`PRAGMA table_info(${tableName})`).all() as any[];
    const pkColumn = columns.find(col => col.pk === 1);

    if (!pkColumn) {
      throw new Error(`No primary key found for table: ${tableName}`);
    }

    const query = `SELECT * FROM ${tableName} WHERE ${pkColumn.name} = ?`;
    const row = this.db.prepare(query).get(recordId);

    if (!row) {
      throw new Error(`Record not found: ${tableName}.${pkColumn.name} = ${recordId}`);
    }

    return {
      uri: `db://tables/${tableName}/records/${recordId}`,
      mimeType: "application/json",
      text: JSON.stringify({
        table: tableName,
        primaryKey: {
          column: pkColumn.name,
          value: recordId,
        },
        data: row,
      }, null, 2),
    };
  }

  private executeCustomQuery(queryString: string): any {
    if (!this.db) throw new Error('Database not initialized');

    const url = new URL(`db://query?${queryString}`);
    const sql = url.searchParams.get('sql');
    const params = url.searchParams.get('params');

    if (!sql) {
      throw new Error('SQL parameter required for custom query');
    }

    // Security: Only allow SELECT queries
    if (!sql.trim().toUpperCase().startsWith('SELECT')) {
      throw new Error('Only SELECT queries are allowed for security');
    }

    let queryParams: any[] = [];
    if (params) {
      try {
        queryParams = JSON.parse(params);
      } catch {
        throw new Error('Invalid params JSON');
      }
    }

    const stmt = this.db.prepare(sql + ' LIMIT ?');
    const rows = stmt.all(...queryParams, this.maxRows);

    return {
      uri: `db://query?sql=${encodeURIComponent(sql)}&params=${encodeURIComponent(JSON.stringify(queryParams))}`,
      mimeType: "application/json",
      text: JSON.stringify({
        query: sql,
        parameters: queryParams,
        resultCount: rows.length,
        data: rows,
      }, null, 2),
    };
  }

  private getTableIndexes(tableName: string): any[] {
    if (!this.db) return [];

    try {
      return this.db.prepare(`
        SELECT name, sql 
        FROM sqlite_master 
        WHERE type='index' AND tbl_name=?
      `).all(tableName) as any[];
    } catch {
      return [];
    }
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      if (this.db) {
        this.db.close();
      }
      await this.server.close();
      process.exit(0);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error(`Database Resource Server running (DB: ${this.dbPath})`);
  }
}

// Main entry point
async function main() {
  const server = new DatabaseResourceServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

Testing - First, create a test database:

```bash
sqlite3 test.db << 'EOF'
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  age INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL,
  category TEXT,
  in_stock BOOLEAN DEFAULT 1
);

INSERT INTO users (name, email, age) VALUES 
  ('Alice Johnson', 'alice@example.com', 28),
  ('Bob Smith', 'bob@example.com', 34);

INSERT INTO products (name, price, category, in_stock) VALUES 
  ('Laptop', 999.99, 'Electronics', 1),
  ('Book', 19.99, 'Education', 1);

.quit
EOF
```

Test the server:

```javascript
// Database info
{ uri: "db://info" }

// Table schemas
{ uri: "db://tables/users/schema" }
{ uri: "db://tables/products/schema" }

// Table data
{ uri: "db://tables/users/data?limit=10" }
{ uri: "db://tables/products/data?limit=10" }

// Specific records
{ uri: "db://tables/users/records/1" }
{ uri: "db://tables/products/records/2" }

// Custom query
{ uri: "db://query?sql=SELECT * FROM users WHERE age > ?&params=[25]" }
```

</details>

---

## Key Takeaways

✅ **Resources** provide passive data access for LLMs

✅ **Tools** perform active operations with side effects

✅ **URI schemes** should be hierarchical and descriptive

✅ **Templates** enable parameterized resource access

✅ **Subscriptions** support real-time data updates

✅ **Security** is critical for resource access control

✅ **Caching** improves performance for static resources

✅ **Hybrid servers** combine resources and tools effectively

---

## Next Steps

In [**Lab 5**](../Lab05-MCP-Prompts/), you'll complete your MCP mastery by learning about Prompts:

- Creating reusable prompt templates
- Embedding resources in prompts
- Supporting prompt arguments
- Building complete, production-ready MCP servers

---

**Ready to add prompts to your MCP toolkit? Continue to [Lab 5!](../Lab05-MCP-Prompts/)**
