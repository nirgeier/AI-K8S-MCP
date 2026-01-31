````markdown
# Step 02: Project Setup

## Create the K-Agent Project Directory

```bash
# Create project directory
mkdir k-agent-logs
cd k-agent-logs
```
````

## Initialize package.json

Create a `package.json` file with the following content:

```json
{
  "name": "k-agent-logs",
  "version": "1.0.0",
  "description": "K-Agent MCP server for Kubernetes log collection",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/index.ts",
    "start": "node dist/index.js"
  },
  "keywords": ["kubernetes", "mcp", "logs", "monitoring"],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "dependencies": {
    "@kubernetes/client-node": "^1.4.0",
    "@modelcontextprotocol/sdk": "^1.25.2"
  },
  "devDependencies": {
    "@types/node": "^25.0.3",
    "tsx": "^4.21.0",
    "typescript": "^5.9.3"
  }
}
```

## Install Dependencies

```bash
npm install
```

This installs:

- **@kubernetes/client-node** - Official Kubernetes client for Node.js
- **@modelcontextprotocol/sdk** - MCP SDK for building servers
- **tsx** - TypeScript execution for development
- **typescript** - TypeScript compiler

## Create Project Structure

```bash
mkdir -p src
touch src/index.ts
```

Your project should now look like:

```
k-agent-logs/
├── node_modules/
├── src/
│   └── index.ts
├── package.json
└── package-lock.json
```

```

```
