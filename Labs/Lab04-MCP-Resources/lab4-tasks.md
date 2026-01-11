# MCP Lab Tasks - Lab 4

Welcome to the MCP Lab Tasks section! 

This comprehensive collection of hands-on exercises will help you master the Model Context Protocol through practical implementation.

Each lab has 15 exercises designed to build your skills progressively. Try to solve each exercise on your own before clicking the solution dropdown.


---


### Exercise 4.1: Static Text Resource

Create a simple text resource that returns static content.

??? "Solution"
    ```typescript
    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://static/welcome") {
        return {
          contents: [{
            uri: "mcp://static/welcome",
            mimeType: "text/plain",
            text: "Welcome to MCP Resources!"
          }]
        };
      }
    });
    ```

### Exercise 4.2: File System Resource

Implement a resource that reads files from the file system.

??? "Solution"
    ```typescript
    import { readFileSync } from "fs";
    import { extname } from "path";

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri.startsWith("file://")) {
        const filePath = uri.replace("file://", "");

        try {
          const content = readFileSync(filePath, "utf-8");
          const mimeType = getMimeType(filePath);

          return {
            contents: [{
              uri,
              mimeType,
              text: content
            }]
          };
        } catch (error) {
          throw new Error(`Failed to read file: ${error.message}`);
        }
      }
    });

    function getMimeType(filePath: string): string {
      const ext = extname(filePath).toLowerCase();
      const mimeTypes: Record<string, string> = {
        '.txt': 'text/plain',
        '.json': 'application/json',
        '.js': 'application/javascript',
        '.ts': 'application/typescript',
        '.md': 'text/markdown'
      };
      return mimeTypes[ext] || 'text/plain';
    }
    ```

### Exercise 4.3: Dynamic Resource

Create a resource that generates content dynamically.

??? "Solution"
    ```typescript
    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri.startsWith("mcp://dynamic/time")) {
        const now = new Date();
        const timeString = now.toISOString();

        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify({
              timestamp: timeString,
              unix: Math.floor(now.getTime() / 1000)
            })
          }]
        };
      }
    });
    ```

### Exercise 4.4: Database Resource

Implement a resource that queries a database.

??? "Solution"
    ```typescript
    import sqlite3 from "sqlite3";

    const db = new sqlite3.Database(':memory:');

    // Initialize database
    db.serialize(() => {
      db.run("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)");
      db.run("INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com')");
      db.run("INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com')");
    });

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://db/users") {
        return new Promise((resolve, reject) => {
          db.all("SELECT * FROM users", [], (err, rows) => {
            if (err) {
              reject(new Error(`Database error: ${err.message}`));
            } else {
              resolve({
                contents: [{
                  uri,
                  mimeType: "application/json",
                  text: JSON.stringify(rows, null, 2)
                }]
              });
            }
          });
        });
      }
    });
    ```

### Exercise 4.5: API Resource

Create a resource that fetches data from an external API.

??? "Solution"
    ```typescript
    import fetch from "node-fetch";

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri.startsWith("mcp://api/github/")) {
        const repo = uri.replace("mcp://api/github/", "");

        try {
          const response = await fetch(`https://api.github.com/repos/${repo}`);
          const data = await response.json();

          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify({
                name: data.name,
                description: data.description,
                stars: data.stargazers_count,
                language: data.language
              }, null, 2)
            }]
          };
        } catch (error) {
          throw new Error(`API request failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 4.6: Configuration Resource

Implement a resource that provides configuration data.

??? "Solution"
    ```typescript
    const config = {
      app: {
        name: "MCP Server",
        version: "1.0.0",
        environment: process.env.NODE_ENV || "development"
      },
      database: {
        host: process.env.DB_HOST || "localhost",
        port: parseInt(process.env.DB_PORT || "5432")
      },
      features: {
        tools: true,
        resources: true,
        prompts: false
      }
    };

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://config/app") {
        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(config, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.7: Log Resource

Create a resource that provides access to application logs.

??? "Solution"
    ```typescript
    import { readFileSync } from "fs";

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://logs/application") {
        try {
          const logs = readFileSync("app.log", "utf-8");
          return {
            contents: [{
              uri,
              mimeType: "text/plain",
              text: logs
            }]
          };
        } catch (error) {
          // Return empty logs if file doesn't exist
          return {
            contents: [{
              uri,
              mimeType: "text/plain",
              text: "No logs available"
            }]
          };
        }
      }
    });
    ```

### Exercise 4.8: Metrics Resource

Implement a resource that provides system metrics.

??? "Solution"
    ```typescript
    import { cpus, freemem, totalmem } from "os";

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://metrics/system") {
        const metrics = {
          cpu: {
            cores: cpus().length,
            model: cpus()[0].model
          },
          memory: {
            free: freemem(),
            total: totalmem(),
            used: totalmem() - freemem(),
            usagePercent: ((totalmem() - freemem()) / totalmem() * 100).toFixed(2)
          },
          uptime: process.uptime()
        };

        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(metrics, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.9: Template Resource

Create a resource that renders templates with data.

??? "Solution"
    ```typescript
    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri.startsWith("mcp://template/")) {
        const templateName = uri.replace("mcp://template/", "");
        const templates: Record<string, string> = {
          welcome: "Hello {{name}}! Welcome to {{app}}.",
          status: "Service {{service}} is {{status}}."
        };

        const template = templates[templateName];
        if (!template) {
          throw new Error(`Template '${templateName}' not found`);
        }

        // Simple template rendering (in real app, use a proper template engine)
        const rendered = template
          .replace("{{name}}", "User")
          .replace("{{app}}", "MCP Server")
          .replace("{{service}}", "Database")
          .replace("{{status}}", "running");

        return {
          contents: [{
            uri,
            mimeType: "text/plain",
            text: rendered
          }]
        };
      }
    });
    ```

### Exercise 4.10: Cache Resource

Implement a resource with caching capabilities.

??? "Solution"
    ```typescript
    const cache = new Map<string, { data: any; timestamp: number }>();
    const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://cache/random") {
        const cached = cache.get(uri);
        const now = Date.now();

        if (cached && (now - cached.timestamp) < CACHE_TTL) {
          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify({ value: cached.data, cached: true }, null, 2)
            }]
          };
        }

        // Generate new random value
        const randomValue = Math.random();
        cache.set(uri, { data: randomValue, timestamp: now });

        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify({ value: randomValue, cached: false }, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.11: Directory Listing Resource

Create a resource that lists directory contents.

??? "Solution"
    ```typescript
    import { readdirSync, statSync } from "fs";
    import { join } from "path";

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri.startsWith("mcp://fs/dir/")) {
        const dirPath = uri.replace("mcp://fs/dir/", "/");

        try {
          const items = readdirSync(dirPath).map(item => {
            const fullPath = join(dirPath, item);
            const stats = statSync(fullPath);

            return {
              name: item,
              type: stats.isDirectory() ? "directory" : "file",
              size: stats.size,
              modified: stats.mtime.toISOString()
            };
          });

          return {
            contents: [{
              uri,
              mimeType: "application/json",
              text: JSON.stringify(items, null, 2)
            }]
          };
        } catch (error) {
          throw new Error(`Failed to list directory: ${error.message}`);
        }
      }
    });
    ```

### Exercise 4.12: Environment Resource

Implement a resource that provides environment information.

??? "Solution"
    ```typescript
    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://env/variables") {
        const envVars = Object.keys(process.env)
          .filter(key => !key.includes("SECRET") && !key.includes("PASSWORD"))
          .reduce((obj, key) => {
            obj[key] = process.env[key];
            return obj;
          }, {} as Record<string, string | undefined>);

        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(envVars, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.13: Health Check Resource

Create a resource that provides health status.

??? "Solution"
    ```typescript
    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://health/status") {
        const health = {
          status: "healthy",
          timestamp: new Date().toISOString(),
          uptime: process.uptime(),
          memory: process.memoryUsage(),
          version: process.version
        };

        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(health, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.14: Version Resource

Implement a resource that provides version information.

??? "Solution"
    ```typescript
    const packageInfo = {
      name: "mcp-server",
      version: "1.0.0",
      description: "Model Context Protocol Server",
      dependencies: {
        "@modelcontextprotocol/sdk": "^0.4.0"
      }
    };

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://version/info") {
        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(packageInfo, null, 2)
          }]
        };
      }
    });
    ```

### Exercise 4.15: Documentation Resource

Create a resource that serves documentation.

??? "Solution"
    ```typescript
    const documentation = {
      title: "MCP Server Documentation",
      version: "1.0.0",
      endpoints: {
        tools: "/tools",
        resources: "/resources",
        prompts: "/prompts"
      },
      examples: {
        tool_call: {
          method: "tools/call",
          params: {
            name: "example_tool",
            arguments: { param: "value" }
          }
        }
      }
    };

    server.setRequestHandler("resources/read", async (request) => {
      const { uri } = request.params;

      if (uri === "mcp://docs/api") {
        return {
          contents: [{
            uri,
            mimeType: "application/json",
            text: JSON.stringify(documentation, null, 2)
          }]
        };
      }
    });
    ```