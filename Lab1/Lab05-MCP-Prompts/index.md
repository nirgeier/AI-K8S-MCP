# Lab 5: MCP Prompts and Integration

## Overview

Congratulations on reaching the final lab!

As you have already mastered tools and resources, now it's time to complete your MCP expertise with **Prompts**.

Prompts are reusable templates that help users and LLMs perform common tasks consistently and effectively. They can embed resources, accept arguments, and create structured workflows that combine the best of human expertise with AI capabilities.

In this lab, you'll learn how to create sophisticated prompt templates, integrate them with resources and tools, and build complete, production-ready MCP servers that showcase all three capabilities working together.

---

## Learning Objectives

By the end of this lab, you will:

- Understand the role of prompts in MCP ecosystems
- Create static and dynamic prompt templates
- Embed resources and arguments in prompts
- Implement prompt handlers with proper validation
- Build complete MCP servers combining all capabilities
- Apply production best practices for deployment
- Debug and troubleshoot complex MCP integrations
- Create reusable prompt libraries for common tasks

---

## Prerequisites

- Completed [Lab 4 - Implementing MCP Resources](../Lab04-MCP-Resources/)
- Understanding of prompt engineering concepts
- Familiarity with template systems and variable substitution
- Experience with complex application architecture

---

## What Makes Prompts Special?

Prompts in MCP are more than just text templates - they're **structured, reusable AI workflows** that:

- **Standardize** common tasks across different users and contexts
- **Combine expertise** from domain specialists with AI capabilities
- **Integrate resources** to provide rich context automatically
- **Accept parameters** to customize behavior dynamically
- **Create consistency** in AI interactions and outputs

### When to Use Prompts vs. Tools

| Use Case | Use Prompt | Use Tool | Why |
|----------|------------|----------|-----|
| Code review | ✅ Prompt | ❌ Tool | Needs structured guidance and context |
| Data analysis | ✅ Prompt | ❌ Tool | Requires analytical reasoning framework |
| Content writing | ✅ Prompt | ❌ Tool | Benefits from style guides and examples |
| API calls | ❌ Prompt | ✅ Tool | Direct action with predictable results |
| Calculations | ❌ Prompt | ✅ Tool | Mathematical precision required |
| Research synthesis | ✅ Prompt | ❌ Tool | Complex reasoning and integration needed |

### Prompt Architecture

```typescript
interface Prompt {
  name: string;              // Unique identifier
  description: string;       // What the prompt does
  arguments?: Argument[];    // Optional parameters
  messages: Message[];       // The actual prompt content
}

interface Argument {
  name: string;              // Parameter name
  description: string;       // What it controls
  required?: boolean;        // Is it mandatory?
}

interface Message {
  role: "user" | "assistant"; // Who says this
  content: Content;          // The message content
}
```

---

## Project Setup

### Step 1: Create Your Project

Let's start by creating a new MCP server project for prompts:

```bash
mkdir my-mcp-prompts-server  # <-- next to the directory created in previous labs
cd my-mcp-prompts-server
npm init -y
```

### Step 2: Install Dependencies

```bash
# Core MCP SDK
npm install @modelcontextprotocol/sdk

# TypeScript and development tools
npm install -D typescript @types/node tsx
```

### Step 3: Configure TypeScript

Create a `tsconfig.json` file with the following content inside the `my-mcp-prompts-server` directory you have just created:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 4: Create Project Structure

```bash
mkdir src     # <-- inside "my-mcp-prompts-server" directory
touch src/index.ts   # and leave it empty for now
```

---

## Creating Your First Prompt Server

### Step 1: Basic Server Setup

Let's create a basic MCP server that exposes prompts. Paste the following inside `src/index.ts`:

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

class PromptServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "mcp-prompts-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          prompts: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    // List available prompts
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
        prompts: [
          {
            name: "hello-prompt",
            description: "A simple greeting prompt",
          },
          {
            name: "code-review",
            description: "Comprehensive code review with best practices",
            arguments: [
              {
                name: "language",
                description: "Programming language (e.g., typescript, python)",
                required: true,
              },
            ],
          },
        ],
      };
    });

    // Get specific prompt
    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      return this.generatePrompt(name, args || {});
    });
  }

  private generatePrompt(name: string, args: Record<string, any>): any {
    switch (name) {
      case "hello-prompt":
        return {
          description: "A simple greeting prompt",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: "Hello! Please introduce yourself and explain what you can help me with today.",
              },
            },
          ],
        };

      case "code-review":
        const language = args.language || "typescript";
        return {
          description: `Code review for ${language}`,
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: `Please perform a comprehensive code review of the following ${language} code. Focus on:

## Code Quality & Best Practices
- **Readability**: Is the code easy to understand?
- **Maintainability**: How easy will this be to modify later?
- **Performance**: Are there any obvious performance issues?
- **Error Handling**: Are errors handled appropriately?

## ${language.toUpperCase()}-Specific Checks
- Follow ${language} conventions and best practices
- Use appropriate design patterns
- Ensure proper type safety (if applicable)

Please provide specific, actionable feedback with examples where possible.`,
              },
            },
          ],
        };

      default:
        throw new Error(`Unknown prompt: ${name}`);
    }
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
    console.error("Prompt Server running on stdio");
  }
}

// Main entry point
async function main() {
  const server = new PromptServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

---

### Step 2: Test Your Server

**Build and run the server:**

```bash
npm run build
npx @modelcontextprotocol/inspector node dist/index.js
```

The MCP Inspector will launch a web interface.

<br>

**Test the prompts in the MCP Inspector UI:**

1. **List prompts**: Click the "Prompts" tab, then click "List Prompts" to see your two prompts ("hello-prompt" and "code-review").

2. **Get hello-prompt**: In the same section, select "Get Prompt", enter "hello-prompt" as the name, and submit to see the greeting prompt content.

3. **Get code-review**: Select "Get Prompt", enter "code-review" as the name, and optionally provide arguments like {"language": "typescript"} in the arguments field, then submit to see the code review prompt.


---

### Step 3: Adding Arguments and Validation

Let's enhance our server with better argument handling. Update your existing `src/index.ts` file to add more arguments to the code-review prompt and include helper methods for dynamic content generation.

**Update the code-review prompt definition in the `ListPromptsRequestSchema` handler:**

```typescript
// Update the code-review prompt definition
{
  name: "code-review",
  description: "Comprehensive code review with best practices",
  arguments: [
    {
      name: "language",
      description: "Programming language (e.g., typescript, python, java)",
      required: true,
    },
    {
      name: "complexity",
      description: "Code complexity level (beginner, intermediate, advanced)",
      required: false,
    },
    {
      name: "focus",
      description: "Review focus areas (comma-separated: quality,security,performance)",
      required: false,
    },
  ],
}
```

<br>

**Update the prompt generation:**

```typescript
case "code-review":
  const language = args.language || "typescript";
  const complexity = args.complexity || "intermediate";
  const focus = args.focus || "quality";

  return {
    description: `Code review for ${language} (${complexity} level, focus: ${focus})`,
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `Please perform a comprehensive code review of the following ${language} code.

**Complexity Level:** ${complexity}
**Focus Areas:** ${focus}

## Review Guidelines

### Code Quality & Best Practices
- **Readability**: Is the code easy to understand?
- **Maintainability**: How easy will this be to modify later?
- **Performance**: Are there any obvious performance issues?

### ${complexity.charAt(0).toUpperCase() + complexity.slice(1)} Level Expectations
${this.getComplexityExpectations(complexity)}

### Focus Area: ${focus.toUpperCase()}
${this.getFocusAreaGuidance(focus)}

Please provide specific, actionable feedback with examples where possible.`,
        },
      },
    ],
  };
```

<br>

**Add helper methods:**

```typescript
private getComplexityExpectations(level: string): string {
  const expectations: { [key: string]: string } = {
    beginner: `- Clear, self-documenting code\n- Basic error handling\n- Simple, understandable logic`,
    intermediate: `- Good separation of concerns\n- Comprehensive error handling\n- Appropriate design patterns\n- Unit test coverage`,
    advanced: `- High performance and scalability\n- Complex architectural patterns\n- Extensive testing (unit, integration, e2e)\n- Advanced optimization techniques`,
  };
  return expectations[level] || "- Standard coding practices";
}

private getFocusAreaGuidance(focus: string): string {
  const guidance: { [key: string]: string } = {
    quality: `**Code Quality Focus:**
- Code readability and maintainability
- Consistent naming conventions
- Proper code organization
- Documentation quality`,
    security: `**Security Focus:**
- Input validation and sanitization
- Authentication and authorization
- Data protection practices
- Common vulnerability patterns`,
    performance: `**Performance Focus:**
- Algorithm efficiency
- Memory usage optimization
- Database query optimization
- Caching strategies`,
  };
  return guidance[focus] || "- General best practices";
}
```

<br>

Here's the complete updated `src/index.ts` with all the above enhancements, just for review purposes:

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

class PromptServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "mcp-prompts-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          prompts: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  private setupHandlers(): void {
    // List available prompts
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
        prompts: [
          {
            name: "hello-prompt",
            description: "A simple greeting prompt",
          },
          {
            name: "code-review",
            description: "Comprehensive code review with best practices",
            arguments: [
              {
                name: "language",
                description: "Programming language (e.g., typescript, python, java)",
                required: true,
              },
              {
                name: "complexity",
                description: "Code complexity level (beginner, intermediate, advanced)",
                required: false,
              },
              {
                name: "focus",
                description: "Review focus areas (comma-separated: quality,security,performance)",
                required: false,
              },
            ],
          },
        ],
      };
    });

    // Get specific prompt
    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      return this.generatePrompt(name, args || {});
    });
  }

  private generatePrompt(name: string, args: Record<string, any>): any {
    switch (name) {
      case "hello-prompt":
        return {
          description: "A simple greeting prompt",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: "Hello! Please introduce yourself and explain what you can help me with today.",
              },
            },
          ],
        };

      case "code-review":
        const language = args.language || "typescript";
        const complexity = args.complexity || "intermediate";
        const focus = args.focus || "quality";

        return {
          description: `Code review for ${language} (${complexity} level, focus: ${focus})`,
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: `Please perform a comprehensive code review of the following ${language} code.

**Complexity Level:** ${complexity}
**Focus Areas:** ${focus}

## Review Guidelines

### Code Quality & Best Practices
- **Readability**: Is the code easy to understand?
- **Maintainability**: How easy will this be to modify later?
- **Performance**: Are there any obvious performance issues?

### ${complexity.charAt(0).toUpperCase() + complexity.slice(1)} Level Expectations
${this.getComplexityExpectations(complexity)}

### Focus Area: ${focus.toUpperCase()}
${this.getFocusAreaGuidance(focus)}

Please provide specific, actionable feedback with examples where possible.`,
              },
            },
          ],
        };

      default:
        throw new Error(`Unknown prompt: ${name}`);
    }
  }

  private getComplexityExpectations(level: string): string {
    const expectations: { [key: string]: string } = {
      beginner: `- Clear, self-documenting code\n- Basic error handling\n- Simple, understandable logic`,
      intermediate: `- Good separation of concerns\n- Comprehensive error handling\n- Appropriate design patterns\n- Unit test coverage`,
      advanced: `- High performance and scalability\n- Complex architectural patterns\n- Extensive testing (unit, integration, e2e)\n- Advanced optimization techniques`,
    };
    return expectations[level] || "- Standard coding practices";
  }

  private getFocusAreaGuidance(focus: string): string {
    const guidance: { [key: string]: string } = {
      quality: `**Code Quality Focus:**
- Code readability and maintainability
- Consistent naming conventions
- Proper code organization
- Documentation quality`,
      security: `**Security Focus:**
- Input validation and sanitization
- Authentication and authorization
- Data protection practices
- Common vulnerability patterns`,
      performance: `**Performance Focus:**
- Algorithm efficiency
- Memory usage optimization
- Database query optimization
- Caching strategies`,
    };
    return guidance[focus] || "- General best practices";
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
    console.error("Prompt Server running on stdio");
  }
}

// Main entry point
async function main() {
  const server = new PromptServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

<br>

#### Test Enhanced Prompts

**Test with different arguments:**

1. **Basic code review** (with default values):
   ```javascript
   { name: "code-review", arguments: { language: "typescript" } }
   ```
   Expected: Returns a prompt with intermediate complexity and quality focus.

2. **Advanced code review with focus**:
   ```javascript
   {
     name: "code-review",
     arguments: {
       language: "python",
       complexity: "advanced",
       focus: "security"
     }
   }
   ```
   Expected: Returns a prompt with advanced complexity expectations and security focus guidance.

**How to test in MCP Inspector:**

1. **Start the server:**
   ```bash
   cd my-mcp-prompts-server
   npm run build
   npx @modelcontextprotocol/inspector node dist/index.js
   ```

2. **Inside MCP Inspector UI, navigate to Prompts:**
      - Click on the "Prompts" tab in the Inspector interface

3. **Test List Prompts:**
      - Click "List Prompts" button
      - Verify you see "hello-prompt" and "code-review" with the updated arguments

4. **Test Get Prompt - Basic:**
      - Select "Get Prompt" from the dropdown or click the button
      - Enter `code-review` in the "Name" field
      - In the "Arguments" field, enter: `{"language": "typescript"}`
      - Click "Send Request"
      - Check that the response includes intermediate complexity and quality focus

5. **Test Get Prompt - Advanced:**
      - Select "Get Prompt" again
      - Enter `code-review` in the "Name" field
      - In the "Arguments" field, enter:
        ```json
        {
          "language": "python",
          "complexity": "advanced",
          "focus": "security"
        }
        ```
      - Click "Send Request"
      - Verify the prompt content includes advanced expectations and security guidance

6. **Test without arguments:**
      - Try `code-review` with no arguments
      - Should use defaults: typescript, intermediate, quality

**Expected Results:**

- The prompt description should reflect the arguments (e.g., "Code review for python (advanced level, focus: security)")
- The prompt content should include the appropriate complexity expectations and focus area guidance
- Helper methods should dynamically insert the correct text based on arguments

---

## Integrating Resources with Prompts

Prompts become more powerful when integrated with resources! 

This allows prompts to dynamically include contextual information from your knowledge base, documentation, or data sources, creating richer and more informed AI interactions.

### Step 1: Add Resource Support

**Create a new project for the resource-prompt server:**

```bash
# Create new directory next to your previous server
mkdir my-resource-prompt-server  # <-- next to the directory created previously
cd my-resource-prompt-server

# Initialize and install dependencies
npm init -y
npm install @modelcontextprotocol/sdk
npm install -D typescript @types/node tsx

# Create TypeScript config (same as before)
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create directory structure
mkdir src # <-- inside "my-resource-prompt-server" directory
```

<br>

**Now create the server file `src/index.ts` with the following content that combines prompts with resources:**

```typescript
import {
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

class ResourcePromptServer {
  private server: Server;
  private knowledgeBase: Map<string, any> = new Map();

  constructor() {
    this.server = new Server(
      {
        name: "resource-prompt-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          prompts: {},
          resources: {},
        },
      }
    );

    this.initializeKnowledgeBase();
    this.setupHandlers();
    this.setupErrorHandling();
  }

  private initializeKnowledgeBase(): void {
    this.knowledgeBase.set("best-practices", {
      title: "Development Best Practices",
      content: `
## Code Quality
- Write self-documenting code
- Use meaningful variable names
- Keep functions small and focused

## Testing
- Write unit tests for all functions
- Include integration tests
- Test edge cases and error conditions
      `,
    });

    this.knowledgeBase.set("security-guidelines", {
      title: "Security Guidelines",
      content: `
## Input Validation
- Validate all user inputs
- Use parameterized queries
- Sanitize HTML content

## Authentication
- Use strong password policies
- Implement multi-factor authentication
      `,
    });
  }

  private setupHandlers(): void {
    // Resource handlers
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = Array.from(this.knowledgeBase.entries()).map(([key, doc]) => ({
        uri: `kb://articles/${key}`,
        name: doc.title,
        description: `Knowledge base: ${doc.title}`,
        mimeType: "text/markdown",
      }));

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = this.readKnowledgeBase(uri);
      return { contents: [content] };
    });

    // Prompt handlers
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
        prompts: [
          {
            name: "contextual-code-review",
            description: "Code review with integrated best practices",
            arguments: [
              {
                name: "language",
                description: "Programming language",
                required: true,
              },
              {
                name: "focusAreas",
                description: "Focus areas (comma-separated)",
                required: false,
              },
            ],
          },
        ],
      };
    });

    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      return this.generatePrompt(name, args || {});
    });
  }

  private readKnowledgeBase(uri: string): any {
    const match = uri.match(/^kb:\/\/articles\/(.+)$/);
    if (!match) throw new Error(`Invalid knowledge base URI: ${uri}`);

    const key = match[1];
    const article = this.knowledgeBase.get(key);

    if (!article) throw new Error(`Article not found: ${key}`);

    return {
      uri,
      mimeType: "text/markdown",
      text: article.content,
    };
  }

  private generatePrompt(name: string, args: Record<string, any>): any {
    switch (name) {
      case "contextual-code-review":
        return this.createContextualCodeReviewPrompt(args);

      default:
        throw new Error(`Unknown prompt: ${name}`);
    }
  }

  private createContextualCodeReviewPrompt(args: Record<string, any>): any {
    const language = args.language || "typescript";
    const focusAreas = args.focusAreas ? args.focusAreas.split(',').map((s: string) => s.trim()) : ["quality"];

    // Fetch relevant knowledge base articles
    let contextContent = "";

    if (focusAreas.includes("quality")) {
      const bestPractices = this.knowledgeBase.get("best-practices");
      if (bestPractices) {
        contextContent += `\n## Development Best Practices\n${bestPractices.content}`;
      }
    }

    if (focusAreas.includes("security")) {
      const securityGuidelines = this.knowledgeBase.get("security-guidelines");
      if (securityGuidelines) {
        contextContent += `\n## Security Guidelines\n${securityGuidelines.content}`;
      }
    }

    return {
      description: `Contextual code review for ${language} with focus on: ${focusAreas.join(', ')}`,
      messages: [
        {
          role: "user",
          content: {
            type: "text",
            text: `Please perform a comprehensive code review of the following ${language} code. Use the integrated knowledge base context to provide informed recommendations.

## Review Context
${contextContent}

## Code to Review
[Insert code here]

## Review Focus Areas
${focusAreas.map(area => `- **${area.charAt(0).toUpperCase() + area.slice(1)}**: Apply relevant guidelines from the context above`).join('\n')}

## Review Structure
1. **Summary**: Overall assessment and key findings
2. **Strengths**: What the code does well
3. **Areas for Improvement**: Specific recommendations with context references
4. **Action Items**: Prioritized list of recommended changes

Please reference specific guidelines from the provided context and explain how they apply to this code.`,
          },
        },
      ],
    };
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
    console.error("Resource-Prompt Server running on stdio");
  }
}
```

---

### Step 2: Test Resource Integration

**Build and run the resource-prompt server:**

```bash
cd my-resource-prompt-server
npm run build
npx @modelcontextprotocol/inspector node dist/index.js
```

**Test the enhanced server inside the MCP Inspector UI:**

1. **Navigate to Resources tab:**
      - Click on the "Resources" tab

2. **List resources:**
      - Click "List Resources" button
      - Verify you see the knowledge base articles ("Development Best Practices" and "Security Guidelines")

3. **Read a resource:**
      - Select "Read Resource" from the dropdown
      - Enter `kb://articles/best-practices` in the "URI" field
      - Click "Send Request"
      - Check that the response includes the full content of the best practices article

4. **Read another resource:**
      - Select "Read Resource" again
      - Enter `kb://articles/security-guidelines` in the "URI" field
      - Click "Send Request"
      - Verify the security guidelines content is returned

5. **Navigate to Prompts tab:**
      - Click on the "Prompts" tab

6. **List prompts:**
      - Click "List Prompts" button
      - Verify you see the "contextual-code-review" prompt with its arguments

7. **Get contextual prompt - Basic:**
      - Select "Get Prompt"
      - Enter `contextual-code-review` in the "Name" field
      - In the "Arguments" field, enter: `{"language": "typescript"}`
      - Click "Send Request"
      - Check that the prompt content includes the best practices from the knowledge base

8. **Get contextual prompt - With focus areas:**
      - Select "Get Prompt" again
      - Enter `contextual-code-review` in the "Name" field
      - In the "Arguments" field, enter:
        ```json
        {
          "language": "python",
          "focusAreas": "quality,security"
        }
        ```
      - Click "Send Request"
      - Verify the prompt includes both best practices and security guidelines from the knowledge base

<br>

**Expected Results:**

- Resources should list the knowledge base articles with proper URIs and descriptions
- Reading resources should return the full markdown content of each article
- Prompts should dynamically include relevant knowledge base content based on the focus areas argument
- The contextual prompt should reference specific guidelines from the integrated resources

---

## Complete MCP Server Integration

Complete MCP server integration combines all three core capabilities - tools, resources, and prompts - into a single server that can perform complex operations and provide rich, contextual AI interactions.

### Step 1: Combine All Capabilities

**Create a new project for the complete MCP server:**

```bash
# Create new directory next to your previous servers
mkdir my-complete-mcp-server
cd my-complete-mcp-server

# Initialize and install dependencies
npm init -y
npm install @modelcontextprotocol/sdk
npm install -D typescript @types/node tsx

# Create TypeScript config (same as before)
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create directory structure
mkdir src
```

<br>

**Now create the server file `src/index.ts`, that combines tools, resources, and prompts, with the following content:**



```typescript
import {
  ListToolsRequestSchema,
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

class CompleteMCPServer {
  private server: Server;
  private knowledgeBase: Map<string, any> = new Map();

  constructor() {
    this.server = new Server(
      {
        name: "complete-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
          prompts: {},
        },
      }
    );

    this.initializeKnowledgeBase();
    this.setupHandlers();
    this.setupErrorHandling();
  }

  private initializeKnowledgeBase(): void {
    this.knowledgeBase.set("development-workflow", {
      title: "Complete Development Workflow",
      content: `
## Development Process
1. Requirements gathering and analysis
2. System design and architecture
3. Implementation with best practices
4. Code review and quality assurance
5. Testing and validation
6. Deployment and monitoring
7. Maintenance and updates
      `,
    });
  }

  private setupHandlers(): void {
    // Tool handlers
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "analyze_codebase",
            description: "Analyze codebase structure and provide insights",
            inputSchema: {
              type: "object",
              properties: {
                path: { type: "string", description: "Path to analyze" },
                analysisType: {
                  type: "string",
                  enum: ["structure", "complexity", "dependencies"],
                  default: "structure"
                },
              },
              required: ["path"],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case "analyze_codebase":
          return this.analyzeCodebase(args);

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });

    // Resource handlers
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = [
        ...Array.from(this.knowledgeBase.entries()).map(([key, doc]) => ({
          uri: `kb://articles/${key}`,
          name: doc.title,
          description: `Knowledge: ${doc.title}`,
          mimeType: "text/markdown",
        })),
      ];

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;
      const content = await this.readResource(uri);
      return { contents: [content] };
    });

    // Prompt handlers
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
        prompts: [
          {
            name: "full-development-workflow",
            description: "Complete development workflow with integrated resources",
            arguments: [
              {
                name: "projectType",
                description: "Type of project (web, api, mobile)",
                required: true,
              },
            ],
          },
          {
            name: "code-quality-assessment",
            description: "Comprehensive code quality assessment using all capabilities",
            arguments: [
              {
                name: "codeSample",
                description: "Code to assess",
                required: true,
              },
            ],
          },
        ],
      };
    });

    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      return this.generateIntegratedPrompt(name, args || {});
    });
  }

  private async analyzeCodebase(args: Record<string, any>): Promise<any> {
    const targetPath = args.path || "./";
    const analysisType = args.analysisType || "structure";

    try {
      const analysis = await this.performCodeAnalysis(targetPath, analysisType);

      return {
        content: [
          {
            type: "text",
            text: `## Codebase Analysis: ${analysisType.toUpperCase()}\n\n${analysis}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Codebase analysis failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private async performCodeAnalysis(targetPath: string, analysisType: string): Promise<string> {
    // Simplified analysis - in real implementation, use proper code analysis tools
    return `### Analysis Results
- **Path**: ${targetPath}
- **Type**: ${analysisType}
- **Status**: Analysis completed successfully

### Recommendations
- Consider organizing files by feature
- Add proper documentation
- Implement consistent coding standards`;
  }

  private async readResource(uri: string): Promise<any> {
    if (uri.startsWith('kb://')) {
      return this.readKnowledgeBase(uri);
    }

    throw new Error(`Unknown resource URI: ${uri}`);
  }

  private readKnowledgeBase(uri: string): any {
    const match = uri.match(/^kb:\/\/articles\/(.+)$/);
    if (!match) throw new Error(`Invalid knowledge base URI: ${uri}`);

    const key = match[1];
    const article = this.knowledgeBase.get(key);

    if (!article) throw new Error(`Article not found: ${key}`);

    return {
      uri,
      mimeType: "text/markdown",
      text: article.content,
    };
  }

  private async generateIntegratedPrompt(name: string, args: Record<string, any>): Promise<any> {
    switch (name) {
      case "full-development-workflow":
        return this.createFullWorkflowPrompt(args);

      case "code-quality-assessment":
        return this.createQualityAssessmentPrompt(args);

      default:
        throw new Error(`Unknown prompt: ${name}`);
    }
  }

  private async createFullWorkflowPrompt(args: Record<string, any>): Promise<any> {
    const projectType = args.projectType || "web";

    const workflowDoc = this.knowledgeBase.get("development-workflow");

    return {
      description: `Complete ${projectType} development workflow`,
      messages: [
        {
          role: "user",
          content: {
            type: "text",
            text: `Guide me through a complete ${projectType} development project.

## Development Workflow Reference
${workflowDoc ? workflowDoc.content : "Standard development practices apply"}

## Project Context
- **Type**: ${projectType}
- **Current Phase**: Planning

Please provide a comprehensive development plan with specific phases, deliverables, and best practices.`,
          },
        },
      ],
    };
  }

  private async createQualityAssessmentPrompt(args: Record<string, any>): Promise<any> {
    const codeSample = args.codeSample || "[Insert code here]";

    // Use tools to analyze the code
    const analysisResult = await this.analyzeCodebase({ path: "./", analysisType: "structure" });

    return {
      description: "Comprehensive code quality assessment",
      messages: [
        {
          role: "user",
          content: {
            type: "text",
            text: `Perform a comprehensive code quality assessment of the following code.

## Code to Assess
\`\`\`
${codeSample}
\`\`\`

## Automated Analysis Results
${analysisResult.content[0].text}

## Assessment Framework

### 1. Code Quality Metrics
- **Readability**: Is the code easy to understand?
- **Maintainability**: How easy will this be to modify?
- **Performance**: Are there any obvious issues?

### 2. Best Practices
- Does it follow coding standards?
- Are there appropriate error handling?
- Is the code well-structured?

### 3. Recommendations
Provide specific, prioritized recommendations for improvement.

Please provide a thorough assessment.`,
          },
        },
      ],
    };
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
    console.error("Complete MCP Server running on stdio");
  }
}
```

---

### Step 2: Test Complete Integration

**Build and run the complete MCP server:**

```bash
cd my-complete-mcp-server
npm run build
npx @modelcontextprotocol/inspector node dist/index.js
```

**Test the complete integration inside the MCP Inspector UI:**

1. **Navigate to Tools tab:**
      - Click on the "Tools" tab

2. **List tools:**
      - Click "List Tools" button
      - Verify you see the "analyze_codebase" tool with its description and input schema

3. **Call tool:**
      - Select "Call Tool" from the dropdown
      - Enter `analyze_codebase` in the "Name" field
      - In the "Arguments" field, enter: `{"path": "./", "analysisType": "structure"}`
      - Click "Send Request"
      - Check that the response includes a codebase analysis with recommendations

4. **Navigate to Resources tab:**
      - Click on the "Resources" tab

5. **List resources:**
      - Click "List Resources" button
      - Verify you see the knowledge base article ("Complete Development Workflow")

6. **Read resource:**
      - Select "Read Resource" from the dropdown
      - Enter `kb://articles/development-workflow` in the "URI" field
      - Click "Send Request"
      - Check that the response includes the full development workflow content

7. **Navigate to Prompts tab:**
      - Click on the "Prompts" tab

8. **List prompts:**
      - Click "List Prompts" button
      - Verify you see the "full-development-workflow" and "code-quality-assessment" prompts with their arguments

9. **Get full development workflow prompt:**
      - Select "Get Prompt"
      - Enter `full-development-workflow` in the "Name" field
      - In the "Arguments" field, enter: `{"projectType": "web"}`
      - Click "Send Request"
      - Check that the prompt content includes the development workflow from the knowledge base

10. **Get code quality assessment prompt:**
      - Select "Get Prompt" again
      - Enter `code-quality-assessment` in the "Name" field
      - In the "Arguments" field, enter: `{"codeSample": "function test() { return true; }"}`
      - Click "Send Request"
      - Verify the prompt includes automated analysis results and assessment framework

<br>

**Expected Results:**

- Tools should list the analysis tool with proper schema and description
- Calling tools should return structured analysis results
- Resources should list knowledge base articles with proper URIs
- Reading resources should return the full markdown content
- Prompts should list integrated prompts with their arguments
- Getting prompts should dynamically include tool results and resource content
- The complete integration should demonstrate all three capabilities working together seamlessly

---

## Hands-On Exercises

### Exercise 1: Custom Prompt Library

**Goal:** Create a specialized prompt library for a specific domain.

**Steps:**

1. Choose a domain (e.g., data science, DevOps, content writing)
2. Create 3-5 domain-specific prompts
3. Add appropriate arguments for customization
4. Include domain-specific resources
5. Test with the MCP Inspector

**Requirements:**

- At least one prompt with required arguments
- At least one prompt with optional arguments
- Include resource integration
- Proper error handling

<details>
<summary>Solution</summary>

Choose data science domain.<br><br>

Create 3 domain-specific prompts: data-exploration, model-training, visualization.<br><br>

Add arguments: dataset (required), focus (optional).<br><br>

Include domain-specific resources: data science best practices.<br><br>

Example code structure:<br><br>

```typescript
// In ListPromptsRequestSchema handler
{
  name: "data-exploration",
  description: "Guide for exploratory data analysis",
  arguments: [
    {
      name: "dataset",
      description: "Dataset description",
      required: true,
    },
    {
      name: "focus",
      description: "Analysis focus (distribution, correlation, outliers)",
      required: false,
    },
  ],
},
{
  name: "model-training",
  description: "Guide for machine learning model training",
  arguments: [
    {
      name: "algorithm",
      description: "ML algorithm (linear, tree, neural)",
      required: true,
    },
    {
      name: "target",
      description: "Target variable",
      required: false,
    },
  ],
},
{
  name: "data-visualization",
  description: "Guide for creating effective data visualizations",
  arguments: [
    {
      name: "chartType",
      description: "Type of chart (bar, line, scatter)",
      required: true,
    },
  ],
}

// In generatePrompt method
case "data-exploration":
  const dataset = args.dataset || "dataset";
  const focus = args.focus || "distribution";
  return {
    description: `Data exploration for ${dataset} focusing on ${focus}`,
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `Perform exploratory data analysis on the ${dataset} dataset.

Focus areas: ${focus}

Guidelines:
- Examine data structure and types
- Check for missing values and outliers
- Analyze distributions and correlations
- Generate summary statistics

Provide insights and recommendations.`,
        },
      },
    ],
  };

// Add resources in initializeKnowledgeBase
this.knowledgeBase.set("data-science-practices", {
  title: "Data Science Best Practices",
  content: `
Data Quality
- Validate data integrity
- Handle missing values appropriately
- Check for data consistency

Analysis Process
- Start with descriptive statistics
- Use visualizations for insights
- Test hypotheses systematically
  `,
});
```

Test with MCP Inspector by listing prompts, getting prompts with different arguments, and verifying resource integration.
</details>

### Exercise 2: Multi-Step Workflow Prompt

**Goal:** Create a prompt that guides users through complex, multi-step processes.

**Steps:**

1. Design a multi-step workflow (e.g., code review → testing → deployment)
2. Create prompts for each step
3. Add logic to chain prompts together
4. Include progress tracking
5. Test the complete workflow

**Requirements:**

- Clear step progression
- State management between steps
- Error handling and recovery
- Progress indicators

<details>
<summary>Solution</summary>

Design a code review to deployment workflow with steps: review, testing, deployment.<br><br>

Create prompts for each step with currentStep argument.<br><br>

Add logic to chain prompts and track progress.<br><br>

Example code structure:

```typescript
// In ListPromptsRequestSchema handler
{
  name: "workflow-step",
  description: "Multi-step development workflow guidance",
  arguments: [
    {
      name: "currentStep",
      description: "Current workflow step (review, testing, deployment)",
      required: true,
    },
    {
      name: "projectType",
      description: "Type of project",
      required: false,
    },
  ],
}

// In generatePrompt method
case "workflow-step":
  const step = args.currentStep || "review";
  const projectType = args.projectType || "web";
  const workflowSteps = ["review", "testing", "deployment"];
  const currentIndex = workflowSteps.indexOf(step);
  
  return {
    description: `${projectType} development workflow - Step ${currentIndex + 1}: ${step}`,
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `Guide for ${projectType} project ${step} phase.

Progress: Step ${currentIndex + 1} of ${workflowSteps.length}
Previous steps: ${workflowSteps.slice(0, currentIndex).join(', ') || 'None'}
Next steps: ${workflowSteps.slice(currentIndex + 1).join(', ') || 'Complete'}

${this.getStepGuidance(step, projectType)}

Provide detailed guidance and check completion criteria before proceeding.`,
        },
      },
    ],
  };

// Helper method
private getStepGuidance(step: string, projectType: string): string {
  const guidance: { [key: string]: { [key: string]: string } } = {
    review: {
      web: "Code Review Guidelines:\n- Check code quality and standards\n- Verify security practices\n- Review performance considerations\n- Validate functionality",
      api: "API Review Guidelines:\n- Check endpoint design\n- Validate error handling\n- Review authentication\n- Test API contracts",
    },
    testing: {
      web: "Testing Guidelines:\n- Unit test coverage\n- Integration testing\n- User acceptance testing\n- Performance testing",
      api: "API Testing Guidelines:\n- Endpoint testing\n- Load testing\n- Security testing\n- Contract testing",
    },
    deployment: {
      web: "Deployment Guidelines:\n- Environment configuration\n- Database migrations\n- Rollback procedures\n- Monitoring setup",
      api: "API Deployment Guidelines:\n- API gateway configuration\n- Version management\n- Documentation publishing\n- Client notifications",
    },
  };
  return guidance[step]?.[projectType] || "Follow standard practices for this step.";
}
```

Test the workflow by calling the prompt with different currentStep values and verifying step progression and guidance.

</details>

### Exercise 3: Production-Ready Server

**Goal:** Create a production-ready MCP server with all capabilities.

**Steps:**

1. Implement comprehensive error handling
2. Add logging and monitoring
3. Include health checks
4. Add configuration management
5. Implement rate limiting
6. Create deployment scripts

**Requirements:**

- Structured logging
- Health check endpoints
- Configuration validation
- Graceful shutdown
- Performance monitoring

<details>
<summary>Solution</summary>

Implement comprehensive error handling, logging, health checks, configuration management, rate limiting, and deployment scripts.<br><br>

Example code structure:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

class ProductionMCPServer {
  private server: Server;
  private config: any;
  private requestCount = 0;
  private startTime = Date.now();

  constructor(configPath?: string) {
    this.config = this.loadConfiguration(configPath);
    this.server = new Server(
      {
        name: this.config.name,
        version: this.config.version,
      },
      {
        capabilities: {
          tools: {},
          resources: {},
          prompts: {},
        },
      }
    );

    this.setupLogging();
    this.setupHandlers();
    this.setupErrorHandling();
    this.setupHealthChecks();
  }

  private loadConfiguration(configPath?: string): any {
    // Load from file or environment
    return {
      name: "production-mcp-server",
      version: "1.0.0",
      port: process.env.PORT || 3000,
      logLevel: process.env.LOG_LEVEL || "info",
      rateLimit: parseInt(process.env.RATE_LIMIT || "100"),
    };
  }

  private setupLogging(): void {
    // Use a proper logging library in production
    console.log = this.createLogger("info");
    console.error = this.createLogger("error");
  }

  private createLogger(level: string): (...args: any[]) => void {
    return (...args: any[]) => {
      const timestamp = new Date().toISOString();
      process.stderr.write(`[${timestamp}] ${level.toUpperCase()}: ${args.join(' ')}\n`);
    };
  }

  private setupHandlers(): void {
    // Add rate limiting to handlers
    this.server.setRequestHandler(ListToolsRequestSchema, this.rateLimitedHandler(async () => {
      return { tools: [] };
    }));

    // Add other handlers similarly
  }

  private rateLimitedHandler(handler: Function): Function {
    return async (request: any) => {
      this.requestCount++;
      if (this.requestCount > this.config.rateLimit) {
        throw new Error("Rate limit exceeded");
      }
      return handler(request);
    };
  }

  private setupHealthChecks(): void {
    // Add health check endpoint (if using HTTP transport)
    // For stdio, we can add a special tool
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      if (request.params.name === "health_check") {
        return {
          content: [{
            type: "text",
            text: JSON.stringify({
              status: "healthy",
              uptime: Date.now() - this.startTime,
              requestCount: this.requestCount,
            }),
          }],
        };
      }
      // Handle other tools
    });
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("Server error:", error);
      // Send to monitoring service
    };

    process.on("SIGTERM", async () => {
      console.log("Received SIGTERM, shutting down gracefully");
      await this.server.close();
      process.exit(0);
    });

    process.on("uncaughtException", (error) => {
      console.error("Uncaught exception:", error);
      process.exit(1);
    });
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.log("Production MCP Server running on stdio");
  }
}

// Deployment script (deploy.sh)
#!/bin/bash
npm run build
npm run test
docker build -t mcp-server .
docker run -p 3000:3000 mcp-server
```

Test by running the server, checking logs, calling health check tool, and verifying graceful shutdown.

</details>

---

## Key Takeaways

<p>✅ <strong>Prompts</strong> create reusable AI workflows with structured guidance</p>
<p>✅ <strong>Resource integration</strong> provides contextually rich prompt experiences</p>
<p>✅ <strong>Arguments</strong> make prompts flexible and customizable</p>
<p>✅ <strong>Complete servers</strong> combine tools, resources, and prompts effectively</p>
<p>✅ <strong>Dynamic prompts</strong> adapt to current data and context</p>
<p>✅ <strong>Production readiness</strong> requires comprehensive error handling and monitoring</p>
<p>✅ <strong>Workflow orchestration</strong> enables complex, multi-step AI processes</p>
<p>✅ <strong>Domain specialization</strong> creates powerful, focused AI capabilities</p>

---

## Next Steps

Congratulations! 

You've completed the comprehensive MCP learning series. 

You now posses the knowledge and skills to:

<p>✅ <strong>Build</strong> complete MCP servers with all three capabilities</p>
<p>✅ <strong>Create</strong> sophisticated AI workflows and integrations</p>
<p>✅ <strong>Deploy</strong> production-ready MCP solutions</p>
<p>✅ <strong>Contribute</strong> to the MCP ecosystem</p>

---

## What's Next?

### Further experimentation
Go ahead and experiment further with MCP un the [MCP Lab Tasks](../Tasks/) section, filled with hands-on exercises to deepen your understanding of MCP capabilities.

### Advanced Topics
- **MCP Extensions**: Custom protocol extensions
- **Multi-server Coordination**: Server orchestration
- **Performance Optimization**: Scaling MCP servers
- **Security Hardening**: Advanced security patterns

### Real-World Applications
- **Code Analysis Tools**: Automated code review and improvement
- **DevOps Automation**: Infrastructure and deployment automation
- **Data Science Workflows**: AI-assisted data analysis
- **Content Creation**: AI-powered content generation pipelines

### Community Engagement
- **Contribute to MCP**: Join the open-source development
- **Share Your Servers**: Publish your MCP servers
- **Build Integrations**: Create MCP clients and tools
- **Teach Others**: Help grow the MCP community

---

**Your MCP journey has just begun!** 

**The protocol provides endless possibilities for AI-human collaboration.**

**Go forth and build amazing things!**
