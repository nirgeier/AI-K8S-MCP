# Implementing Live MCP Server (With Ollama Integration)

## Overview

* In this lab, you'll master the art of creating sophisticated, production-ready `MCP` tools that can handle complex inputs, perform real-world operations, and return rich content types.

---


## Learning Objectives

By the end of this lab, you will:

- Design robust tool schemas with advanced validation
- Implement tools that interact with external systems (APIs, databases, file systems)
- Return multiple content types (text, images, resources)
- Handle errors gracefully with detailed feedback
- Implement async operations and streaming responses
- Apply best practices for tool composition
- Test tools thoroughly with various edge cases

---

## Prerequisites

  - Completion of previous MCP labs or equivalent experience
  - Understanding of async/await in JavaScript/TypeScript
  - Basic knowledge of REST APIs and JSON
  - Node.js development environment set up

---

### Weather Information with Ollama

#### Goal
  * Create a production-ready weather tool that uses Ollama (local AI) to generate weather information, handles errors gracefully, and returns formatted information.

#### Complete Weather Tool Implementation with Ollama

* Here is the complete `src/index.ts` file with the Ollama-based weather tool added. 

<details>
<summary>Click to expand code</summary>

```typescript
#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
* Create an MCP server with core capabilities
*/
class MyFirstMCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "my-first-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  /**
  * Set up request handlers
  */
  private setupHandlers(): void {
    // Handler for listing available tools
    this.server.setRequestHandler(
      ListToolsRequestSchema,
      async () => ({
        tools: [
          {
            name: "get_weather",
            description: "Get current weather information for a city using AI",
            inputSchema: {
              type: "object",
              properties: {
                city: {
                  type: "string",
                  description: "City name (e.g., 'London', 'New York')"
                },
                units: {
                  type: "string",
                  description: "Temperature units",
                  enum: ["celsius", "fahrenheit"],
                  default: "celsius"
                }
              },
              required: ["city"]
            }
          },
          {
            name: "hello_world",
            description: "Returns a friendly greeting message",
            inputSchema: {
              type: "object",
              properties: {
                name: {
                  type: "string",
                  description: "The name to greet",
                },
              },
              required: ["name"],
            },
          },
        ],
      })
    );

    // Handler for calling tools
    this.server.setRequestHandler(
      CallToolRequestSchema,
      async (request) => {
        const { name, arguments: args } = request.params;

        if (name === "get_weather") {
          try {
            // Extract and validate parameters
            const city = args.city as string;
            const units = (args.units as string) || "celsius";

            if (!city || city.trim().length === 0) {
              throw new Error("City name cannot be empty");
            }

            // Use Ollama to generate weather information
            const prompt = `Generate realistic current weather information for ${city}.
            Return ONLY a JSON object with this exact structure:
            {
              "name": "${city}",
              "sys": {"country": "XX"},
              "main": {"temp": 20.5, "feels_like": 22.1, "humidity": 65},
              "weather": [{"description": "clear sky"}],
              "wind": {"speed": 3.2}
            }

            Use realistic weather data appropriate for the location. Temperature should be in Celsius. Choose an appropriate 2-letter country code for the city. Make the weather description realistic for the location and season.`;

            // Call Ollama API
            const response = await fetch('http://localhost:11434/api/generate', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                model: 'gpt-oss:20b',
                prompt: prompt,
                stream: false,
                format: 'json'
              }),
            });

            if (!response.ok) {
              throw new Error(`Ollama API error: ${response.status} ${response.statusText}. Make sure Ollama is running with 'ollama serve'.`);
            }

            const ollamaResult = await response.json();
            let data;

            try {
              // Parse the JSON response from Ollama
              data = JSON.parse(ollamaResult.response);
            } catch (parseError) {
              // Fallback to mock data if parsing fails
              console.warn('Failed to parse Ollama response, using fallback data');
              const fallbackData: Record<string, any> = {
                "london": {
                  name: "London",
                  sys: { country: "GB" },
                  main: { temp: 15.2, feels_like: 14.8, humidity: 82 },
                  weather: [{ description: "light rain" }],
                  wind: { speed: 3.6 }
                },
                "new york": {
                  name: "New York",
                  sys: { country: "US" },
                  main: { temp: 22.5, feels_like: 24.1, humidity: 65 },
                  weather: [{ description: "clear sky" }],
                  wind: { speed: 2.1 }
                },
                "tokyo": {
                  name: "Tokyo",
                  sys: { country: "JP" },
                  main: { temp: 18.7, feels_like: 18.2, humidity: 78 },
                  weather: [{ description: "few clouds" }],
                  wind: { speed: 1.8 }
                },
                "paris": {
                  name: "Paris",
                  sys: { country: "FR" },
                  main: { temp: 12.8, feels_like: 11.9, humidity: 71 },
                  weather: [{ description: "overcast clouds" }],
                  wind: { speed: 4.2 }
                },
                "sydney": {
                  name: "Sydney",
                  sys: { country: "AU" },
                  main: { temp: 24.3, feels_like: 25.1, humidity: 73 },
                  weather: [{ description: "sunny" }],
                  wind: { speed: 2.8 }
                }
              };
              data = fallbackData[city.toLowerCase().trim()] || fallbackData["london"];
            }

            // Format response
            const tempUnit = units === "fahrenheit" ? "°F" : "°C";
            const weatherText = `
Weather in ${data.name}, ${data.sys.country}:
- Temperature: ${data.main.temp}${tempUnit}
- Feels like: ${data.main.feels_like}${tempUnit}
- Conditions: ${data.weather[0].description}
- Humidity: ${data.main.humidity}%
- Wind Speed: ${data.wind.speed} m/s

*Generated by Ollama AI*
`.trim();

            // Return MCP response
            return {
              content: [
                {
                  type: "text",
                  text: weatherText
                }
              ]
            };

          } catch (error) {
            // Handle errors
            throw new Error(
              `Failed to get weather: ${error instanceof Error ? error.message : 'Unknown error'}`
            );
          }
        }

        if (name === "hello_world") {
          const userName = args?.name as string;

          if (!userName) {
            throw new Error("Name parameter is required");
          }

          return {
            content: [
              {
                type: "text",
                text: `Hello, ${userName}! Welcome to your first MCP server! 🎉`,
              },
            ],
          };
        }

        throw new Error(`Unknown tool: ${name}`);
      }
    );
  }

  /**
  * Set up error handling
  */
  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  /**
  * Start the server
  */
  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);

    console.error("My First MCP Server running on stdio");
  }
}

/**
* Main entry point
*/
async function main() {
  const server = new MyFirstMCPServer();
  await server.start();
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

</details>

---


#### Test the Weather Tool

- This MCP is wriitten in TypeScript. Make sure you have all dependencies installed with `npm install`.

  ```sh
  # Install dependencies
  npm install @types/node tsx typescript

  # Test the MCP server
  # Start the MCP Inspector** (in a new terminal):
  npx @modelcontextprotocol/inspector tsx mcp.ts
  ```

2. **In the MCP Inspector interface**:
  
      - You should see both `get_weather` and `hello_world` tools listed
      - Click on `get_weather` tool
      - Enter a city name like "London", "New York", "Tokyo", "Paris", or "Sydney"
      - Optionally set units to "fahrenheit" for Fahrenheit temperatures
      - Click "Call Tool"

3. **Test different scenarios**:
  
      - Valid cities: "London", "New York", "Tokyo", "Paris", "Sydney"
      - Invalid cities: "InvalidCity123" (will use fallback data)
      - Different units: Try both "celsius" and "fahrenheit"
      - Empty city: Try with empty string (should show validation error)

4. **Test error cases**:
   
      - Stop Ollama server and try calling the tool (should show API error)
      - Try with invalid model name in the code (should show error)


- You should see AI-generated weather information formatted like this:

    ```
    Weather in London, GB:
    - Temperature: 15.2°C
    - Feels like: 14.8°C
    - Conditions: light rain
    - Humidity: 82%
    - Wind Speed: 3.6 m/s

    *Generated by Ollama AI*
    ```

---

### Tool 2: File Operations

#### Goal

  * Create a secure file reading tool that can handle various file types, validate paths, and return formatted content with metadata.

#### Complete File Operations Tool Implementation

!!! danger ""
      * Do NOT copy the entire code block below. 
      * Instead, add the `read_file` tool to your existing `src/index.ts` file by following these specific steps:

1. **Add the import** at the top of your file (after existing imports):
   ```typescript
   import * as fs from 'fs/promises';
   import * as path from 'path';
   ```

2. **Add the `read_file` tool to your tools array** in the `ListToolsRequestSchema` handler:
   ```typescript
   {
     name: "read_file",
     description: "Read contents of a text file with security validation",
     inputSchema: {
       type: "object",
       properties: {
         filepath: {
           type: "string",
           description: "Absolute path to the file"
         },
         encoding: {
           type: "string",
           description: "File encoding",
           enum: ["utf8", "ascii", "base64"],
           default: "utf8"
         },
         maxSize: {
           type: "number",
           description: "Maximum file size in bytes",
           minimum: 1,
           maximum: 10485760,
           default: 1048576
         }
       },
       required: ["filepath"]
     }
   }
   ```

3. **Add the `read_file` handler** in the `CallToolRequestSchema` handler (before the final `throw new Error`):
   ```typescript
   if (name === "read_file") {
     try {
       const filepath = args.filepath as string;
       const encoding = (args.encoding as BufferEncoding) || "utf8";
       const maxSize = (args.maxSize as number) || 1048576;

       // Security: Validate input
       if (!filepath || typeof filepath !== 'string' || filepath.trim().length === 0) {
         throw new Error("filepath must be a non-empty string");
       }

       // Security: Resolve and validate path
       const resolvedPath = path.resolve(filepath);
       
       // Prevent directory traversal attacks
       if (!resolvedPath.startsWith(process.cwd())) {
         throw new Error("Access denied: file path outside allowed directory");
       }

       // Check if file exists and is readable
       try {
         await fs.access(resolvedPath, fs.constants.R_OK);
       } catch {
         throw new Error(`File not found or not readable: ${filepath}`);
       }

       // Get file stats
       const stats = await fs.stat(resolvedPath);
       
       // Check if it's actually a file (not a directory)
       if (!stats.isFile()) {
         throw new Error(`Path is not a file: ${filepath}`);
       }

       // Check file size
       if (stats.size > maxSize) {
         throw new Error(
           `File too large: ${stats.size} bytes (max: ${maxSize})`
         );
       }

       // Read file content
       const content = await fs.readFile(resolvedPath, encoding);

       // Format response with metadata
       const fileInfo = {
         path: resolvedPath,
         size: stats.size,
         modified: stats.mtime.toISOString(),
         encoding: encoding
       };

       return {
         content: [
           {
             type: "text",
             text: `File Information:\n${JSON.stringify(fileInfo, null, 2)}\n\nContent:\n${content}`
           }
         ]
       };

     } catch (error) {
       throw new Error(
         `Failed to read file: ${error instanceof Error ? error.message : 'Unknown error'}`
       );
     }
   }
   ```

---


#### Testing the File Operations Tool

## Step 1: Create Test File

```bash
# Create a test directory and files
mkdir -p test-files
echo "Hello, this is a test file\!" > test-files/hello.txt
echo '{"name": "test", "value": 123}' > test-files/data.json
echo "Line 1\nLine 2\nLine 3" > test-files/lines.txt
```

---

## Step 2: Start the MCP Inspector

```bash
npx @modelcontextprotocol/inspector tsx mcp.ts
```

---

## Step 3: Test File Reading

1. **Test with a simple text file**:

      - Tool: `read_file`
      - filepath: `/absolute/path/to/test-files/hello.txt` (use the full absolute path)
      - Click "Call Tool"

2. **Test with JSON file**:

      - Tool: `read_file`
      - filepath: `/absolute/path/to/test-files/data.json`
      - Click "Call Tool"

3. **Test with different encoding**:

      - Tool: `read_file`
      - filepath: `/absolute/path/to/test-files/hello.txt`
      - encoding: `base64`
      - Click "Call Tool"

4. **Test file size limit**:

      - Create a large file: `dd if=/dev/zero of=test-files/large.txt bs=1M count=2`
      - Try reading it with default maxSize (1MB)
      - Try with maxSize: `2097152` (2MB)

---

## Step 4: Test Error Cases

1. **Non-existent file**:

      - filepath: `/absolute/path/to/test-files/nonexistent.txt`

2. **Directory instead of file**:

      - filepath: `/absolute/path/to/test-files` (the directory itself)

3. **Empty filepath**:

      - filepath: `""`

4. **Path traversal attempt**:

      - filepath: `/absolute/path/../../../etc/passwd`

---

## Step 5: Verify Output

- You should see output like:

    ```
    File Information:
    {
      "path": "/Users/username/project/test-files/hello.txt",
      "size": 27,
      "modified": "2024-01-06T10:30:00.000Z",
      "encoding": "utf8"
    }

    Content:
    Hello, this is a test file!
    ```

#### **Troubleshooting:**

- **"File not found"**: Make sure you're using the absolute path
- **"Access denied"**: The file path is outside your project directory
- **"Path is not a file"**: You tried to read a directory
- **"File too large"**: Increase the maxSize parameter

#### Key Learning Points:

- **Path security** and preventing directory traversal attacks
- **File system operations** with Node.js fs/promises
- **Input validation** beyond JSON Schema
- **File metadata** extraction and formatting
- **Error handling** for various file system scenarios
- **Resource limits** to prevent abuse

---

### Tool 3: Database Query

#### Goal
  
  * Create a secure database query tool that can execute `SELECT` statements on a `SQLite` database with proper validation and safety measures.

#### Complete Database Query Tool Implementation

- First, install the SQLite dependency:

    ```bash
    npm install -g better-sqlite3
    npm install -g @types/better-sqlite3
    ```

* Now add the `query_database` tool to your existing `src/index.ts` file by following these specific steps:

1. **Add the imports** at the top of your file (after existing imports):
   ```typescript
   import Database from 'better-sqlite3';
   ```

2. **Add the `query_database` tool to your tools array** in the `ListToolsRequestSchema` handler:
   ```typescript
   {
     name: "query_database",
     description: "Execute SELECT queries on a SQLite database",
     inputSchema: {
       type: "object",
       properties: {
         query: {
           type: "string",
           description: "SQL SELECT query to execute"
         },
         parameters: {
           type: "array",
           description: "Query parameters for prepared statement",
           items: {
             type: ["string", "number", "boolean", "null"]
           },
           default: []
         },
         limit: {
           type: "number",
           description: "Maximum number of rows to return",
           minimum: 1,
           maximum: 1000,
           default: 100
         }
       },
       required: ["query"]
     }
   }
   ```

3. **Add the `query_database` handler** in the `CallToolRequestSchema` handler (before the final `throw new Error`):
   ```typescript
   if (name === "query_database") {
     try {
       const query = args.query as string;
       const parameters = (args.parameters as any[]) || [];
       const limit = (args.limit as number) || 100;

       // Security: Validate input
       if (!query || typeof query !== 'string' || query.trim().length === 0) {
         throw new Error("query must be a non-empty string");
       }

       // Security: Only allow SELECT queries
       const trimmedQuery = query.trim().toUpperCase();
       if (!trimmedQuery.startsWith('SELECT')) {
         throw new Error("Only SELECT queries are allowed for security");
       }

       // Check if database file exists
       const dbPath = './data.db';
       try {
         await fs.access(dbPath, fs.constants.R_OK);
       } catch {
         throw new Error("Database file 'data.db' not found in project root");
       }

       // Open database in read-only mode
       const db = new Database(dbPath, { readonly: true });

       try {
         // Prepare statement
         const stmt = db.prepare(query + ' LIMIT ?');
         
         // Execute query
         const rows = stmt.all(...parameters, limit);

         // Format results
         const resultText = rows.length > 0
           ? JSON.stringify(rows, null, 2)
           : "No results found";

         // Get query info
         const info = stmt.columns();
         const columnNames = info.map(col => col.name);

         return {
           content: [
             {
               type: "text",
               text: `Query executed successfully.\nDatabase: ${dbPath}\nColumns: ${columnNames.join(', ')}\nRows returned: ${rows.length}\n\nResults:\n${resultText}`
             }
           ]
         };

       } finally {
         db.close();
       }

     } catch (error) {
       throw new Error(
         `Database query failed: ${error instanceof Error ? error.message : 'Unknown error'}`
       );
     }
   }
   ```

---

#### Testing the Database Query Tool


**Step 1: Install SQLite**

```bash
# Install sqlite3 command-line tool (if not already installed)

# On macOS:
brew install sqlite3

# On Linux (Ubuntu/Debian):
sudo apt-get update && sudo apt-get install sqlite3

# On Linux (CentOS/RHEL/Fedora):
sudo yum install sqlite3    # or sudo dnf install sqlite3

# On Windows (using Chocolatey):
choco install sqlite

# On Windows (manual download):
# Download from: https://www.sqlite.org/download.html
# Extract sqlite3.exe to a folder in your PATH

# Verify installation:
sqlite3 --version
```

---

**Step 2: Create a Sample Database**

**Navigate to your MCP server directory**

```bash
cd /Users/orni/Code-Wizard/MCP_Lab/MCP_Lab/lab_solution/my-first-mcp-server
```

**Run the database creation command**

```bash
sqlite3 data.db << 'EOF'
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
  ('Bob Smith', 'bob@example.com', 34),
  ('Charlie Brown', 'charlie@example.com', 22);

INSERT INTO products (name, price, category, in_stock) VALUES 
  ('Laptop', 999.99, 'Electronics', 1),
  ('Book', 19.99, 'Education', 1),
  ('Coffee Mug', 12.50, 'Kitchen', 0);

.quit
EOF
```

**Verify the database was created**

```bash
sqlite3 data.db "SELECT name FROM sqlite_master WHERE type='table';"
```

- You should see output like:

    ```
    users
    products
    ```

**What this does:**

- Creates a SQLite database file called `data.db` in your project directory
- Creates two tables: `users` and `products`
- Inserts sample data into both tables
- This gives you test data to query with your `query_database` tool

---

**Step 2: Start the MCP Inspector**

```bash
npx @modelcontextprotocol/inspector tsx mcp.ts
```

---

**Step 3: Test Database Queries**

1. **Simple SELECT query**:

      - Tool: `query_database`
      - query: `SELECT * FROM users`
      - Click "Call Tool"

2. **Query with WHERE clause**:

      - Tool: `query_database`
      - query: `SELECT name, email FROM users WHERE age > 25`
      - Click "Call Tool"

3. **Query with parameters**:

      - Tool: `query_database`
      - query: `SELECT * FROM products WHERE category = ?`
      - parameters: `["Electronics"]`
      - Click "Call Tool"

4. **Query with LIMIT**:

      - Tool: `query_database`
      - query: `SELECT * FROM users`
      - limit: `2`
      - Click "Call Tool"

5. **JOIN query**:

      - Tool: `query_database`
      - query: `SELECT u.name, p.name as product FROM users u CROSS JOIN products p LIMIT 5`
      - Click "Call Tool"

---

**Step 4: Test Error Cases**

1. **Non-SELECT query**:

      - query: `DELETE FROM users WHERE id = 1`

2. **Invalid SQL syntax**:

      - query: `SELECT * FROM nonexistent_table`

3. **Missing database file**:

      - Rename `data.db` to `data.db.backup` and try a query

4. **Empty query**:

      - query: `""`

---

**Step 5: Verify Output**

- You should see output like:

    ```
    Query executed successfully.
    Database: ./data.db
    Columns: id, name, email, age, created_at
    Rows returned: 3

    Results:
    [
      {
        "id": 1,
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "age": 28,
        "created_at": "2024-01-06 10:30:00"
      },
      ...
    ]
    ```


**Troubleshooting:**

- **"Database file not found"**: Make sure `data.db` exists in your project root
- **"Only SELECT queries are allowed"**: The tool only allows SELECT statements for security
- **"no such table"**: Check your table names in the database
- **"sqlite3: command not found"**: Install sqlite3 CLI tool

#### Key Learning Points:

- **SQL injection prevention** using prepared statements
- **Database security** with read-only access and query restrictions
- **SQLite operations** with better-sqlite3
- **Query parameterization** for safe dynamic queries
- **Result formatting** and metadata extraction
- **Resource management** with proper database connection handling

---

## Returning Rich Content

* MCP supports multiple content types in tool responses, allowing you to return not just text but also images, resources, and combinations of different content types. 
* This enables richer, more interactive responses that can include visual data, file references, and structured information.

### 1. Text Content

**Text content** is the most common and basic type of response.   
Use it for any string-based information like analysis results, status messages, or formatted data.

```typescript
return {
  content: [
    {
      type: "text",
      text: "Simple text response"
    }
  ]
};
```

**When to use -** Most tool responses will use text content. 
It's perfect for:

  - Status messages and confirmations
  - Formatted data output (JSON, tables, lists)
  - Error messages and explanations
  - Analysis results and summaries

### 2. Image Content

**Image content** allows you to return visual data directly in the response. The image data must be base64-encoded and include the appropriate MIME type.

```typescript
return {
  content: [
    {
      type: "image",
      data: base64ImageData,
      mimeType: "image/png"
    }
  ]
};
```

**When to use -** Ideal for tools that generate or process visual content:

  - Charts and graphs from data analysis
  - Screenshots or visual captures
  - Generated diagrams or illustrations
  - Image processing results

**Important:** Always specify the correct MIME type (image/png, image/jpeg, image/svg+xml, etc.) and ensure the base64 data is properly encoded.

### 3. Resource Content

**Resource content** references external resources rather than including their data directly. This is useful for large files or when you want to provide access to resources without embedding them.

```typescript
return {
  content: [
    {
      type: "resource",
      resource: {
        uri: "file:///path/to/file.txt",
        mimeType: "text/plain",
        text: "File contents..."
      }
    }
  ]
};
```

**When to use -** Best for:

  - Large files that would make responses too bulky
  - References to external files or URLs
  - When the client should handle the resource directly
  - Providing access to generated files

**Note:** The `text` field is optional - you can omit it if the resource content is too large or if you just want to provide a reference.

### 4. Multiple Content Items

**Multiple content items** allow you to combine different types of content in a single response. This creates rich, multi-part responses that can include text explanations alongside visual data.

```typescript
return {
  content: [
    {
      type: "text",
      text: "Analysis complete:"
    },
    {
      type: "text",
      text: "Details:\n- Item 1\n- Item 2"
    },
    {
      type: "image",
      data: chartImage,
      mimeType: "image/png"
    }
  ]
};
```

**When to use -** Perfect for comprehensive responses that need multiple components:

  - Analysis reports with both text summaries and visual charts
  - File processing results with metadata and content preview
  - Multi-step operations with status updates and final results
  - Complex data with both tabular and graphical representations

**Tip:** Order your content logically - start with text explanations, then show supporting images or resources.

---

## Error Handling Patterns

Error handling is crucial for robust MCP tools. Different situations require different approaches to handle failures gracefully while providing useful feedback to users. Here are three essential patterns for handling errors effectively.

### Pattern 1: Input Validation

**Input validation** ensures that tool arguments meet your requirements before processing begins. This prevents runtime errors and provides clear feedback when users provide invalid data.

```typescript
function validateInput(args: any): void {
  if (!args.filepath || typeof args.filepath !== 'string') {
    throw new Error("filepath must be a non-empty string");
  }

  if (args.maxSize && (args.maxSize < 1 || args.maxSize > 10485760)) {
    throw new Error("maxSize must be between 1 and 10485760 bytes");
  }
}
```

**When to use -** Always validate inputs before processing, even when using JSON Schema validation. This pattern is essential for:

  - Type checking beyond JSON Schema capabilities
  - Business logic validation (file size limits, path security)
  - Preventing runtime errors from malformed data
  - Providing specific, actionable error messages

**Why it matters:** Early validation fails fast and gives users clear guidance on how to fix their input.

### Pattern 2: Graceful Degradation

**Graceful degradation** provides partial functionality when full operation isn't possible. Instead of failing completely, the tool returns useful information or falls back to alternative approaches.

```typescript
try {
  const data = await fetchFromAPI(url);
  return formatSuccess(data);
} catch (error) {
  // Log error but return partial results if possible
  console.error("API call failed:", error);

  return {
    content: [
      {
        type: "text",
        text: "⚠️ Could not fetch live data. Using cached results..."
      }
    ]
  };
}
```

**When to use -** For external dependencies that might be unreliable:

  - API calls that could timeout or fail
  - Network-dependent operations
  - Services with occasional downtime
  - When partial results are better than no results

**Why it matters:** Users get some value even when systems are partially broken, improving overall reliability and user experience.

### Pattern 3: Detailed Error Context

**Detailed error context** provides comprehensive information for debugging while keeping user-facing messages clean. Log full details internally but expose only safe, helpful information to users.

```typescript
catch (error) {
  const errorMessage = error instanceof Error ? error.message : 'Unknown error';
  const errorContext = {
    tool: name,
    arguments: args,
    timestamp: new Date().toISOString(),
    error: errorMessage
  };

  console.error("[Tool Error]", JSON.stringify(errorContext));

  throw new Error(
    `Tool '${name}' failed: ${errorMessage}. Check server logs for details.`
  );
}
```

**When to use -** For complex operations where debugging might be needed:

  - Multi-step processes with potential failure points
  - Operations involving external systems
  - When you need to track error patterns over time
  - Production environments where detailed logging is crucial

**Why it matters:** Developers can diagnose issues effectively while users get clear, non-technical error messages.

---

#### **Best Practices for Error Handling:**

- **Fail Fast:** Validate inputs early and stop processing on critical errors
- **Log Internally:** Use `console.error()` for detailed logging (goes to stderr, not stdout)
- **User-Friendly Messages:** Keep error messages clear and actionable
- **Don't Leak Sensitive Data:** Never expose file paths, credentials, or internal details
- **Consistent Format:** Use similar error message patterns across tools
- **Recovery Options:** When possible, suggest how users can resolve the issue

---

## Async Operations and Performance

MCP tools often need to handle asynchronous operations and optimize performance. Long-running tasks require special handling to prevent timeouts and provide feedback, while expensive operations benefit from caching to improve response times and reduce resource usage.

### Long-Running Operations

**Long-running operations** need monitoring and progress feedback to prevent timeouts and keep users informed. Use logging and timing to track operation progress and provide completion status.

```typescript
if (name === "analyze_large_file") {
  const filepath = args.filepath as string;

  // For very long operations, consider streaming or progress updates
  console.error(`[INFO] Starting analysis of ${filepath}...`);

  try {
    const startTime = Date.now();

    // Perform analysis
    const result = await performLongAnalysis(filepath);

    const duration = Date.now() - startTime;
    console.error(`[INFO] Analysis completed in ${duration}ms`);

    return {
      content: [
        {
          type: "text",
          text: `Analysis Results (completed in ${duration}ms):\n\n${result}`
        }
      ]
    };

  } catch (error) {
    console.error(`[ERROR] Analysis failed after ${Date.now() - startTime}ms`);
    throw error;
  }
}
```

**When to use -** For operations that take more than a few seconds:

- Large file processing or analysis
- Complex computations
- External API calls with potential delays
- Batch operations on multiple items

**Why it matters:** Prevents timeouts, provides user feedback, enables monitoring and debugging of slow operations.

### Caching Results

**Caching results** stores expensive operation results to avoid redundant computation. Use time-based expiration and proper cache keys for efficient reuse of results.

```typescript
class CachedMCPServer {
  private cache: Map<string, { data: any; timestamp: number }>;
  private cacheTTL: number = 60000; // 1 minute

  constructor() {
    this.cache = new Map();
  }

  private getCacheKey(toolName: string, args: any): string {
    return `${toolName}:${JSON.stringify(args)}`;
  }

  private getCached(key: string): any | null {
    const cached = this.cache.get(key);
    if (!cached) return null;

    if (Date.now() - cached.timestamp > this.cacheTTL) {
      this.cache.delete(key);
      return null;
    }

    return cached.data;
  }

  private setCache(key: string, data: any): void {
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }
}
```

**When to use -** For expensive operations that return consistent results:

- API calls to external services
- Complex calculations or data processing
- Database queries with static data
- File analysis that doesn't change frequently

**Why it matters:** Dramatically improves response times, reduces resource usage, and provides better user experience for repeated requests.

#### **Best Practices for Async Operations and Performance:**

- **Monitor Execution Time:** Log start/end times for operations over 1 second
- **Set Reasonable Timeouts:** Use appropriate timeouts for external calls (5-30 seconds)
- **Cache Strategically:** Cache expensive operations but consider data freshness
- **Use Streaming:** For very large responses, consider streaming or pagination
- **Resource Cleanup:** Always clean up connections, file handles, and memory
- **Progress Feedback:** For long operations, provide progress updates via logging
- **Memory Management:** Be mindful of memory usage in long-running processes

---

## Tool Composition

**Tool composition** is the art of designing MCP tools that work seamlessly together, allowing LLMs to chain multiple tools to accomplish complex tasks. Well-composed tools create a powerful ecosystem where each tool handles a specific responsibility while enabling sophisticated workflows through intelligent combination.

### Example: Multi-Step Analysis

**Multi-step analysis** demonstrates how simple, focused tools can be combined to perform complex data processing workflows. Each tool has a clear responsibility and can be used independently or as part of larger operations.

```typescript
// Tool 1: List files
{
  name: "list_files",
  description: "List files in a directory",
  inputSchema: { ... }
}

// Tool 2: Read file
{
  name: "read_file",
  description: "Read a specific file",
  inputSchema: { ... }
}

// Tool 3: Analyze content
{
  name: "analyze_text",
  description: "Analyze text content",
  inputSchema: { ... }
}
```

**When to use -** For workflows that require multiple processing steps:

- Data analysis pipelines
- File processing workflows
- Multi-stage computations
- Complex research tasks

**Why it matters:** Breaks down complex problems into manageable, reusable components that can be combined in flexible ways.

### LLM Tool Chaining

**LLM tool chaining** allows AI models to automatically sequence tool calls based on intermediate results. The LLM analyzes outputs from one tool and determines which tool to call next, creating intelligent workflows without explicit programming.

The LLM can chain these tools:

1. **List files in directory** - Discover available files
2. **Read interesting files** - Access content based on filenames
3. **Analyze their content** - Process and extract insights

**When to use -** When tasks naturally break down into sequential steps:

- Research and analysis workflows
- Data processing pipelines
- Content generation chains
- Problem-solving sequences

**Why it matters:** Enables complex, multi-step reasoning and problem-solving that would be difficult to implement in single tools.

### Testing Composed Tools

**Testing composed tools** ensures that individual tools work correctly both in isolation and when chained together. Use comprehensive test suites that cover single-tool usage and multi-tool workflows.

```typescript
import { describe, it, expect } from 'vitest';

describe('Weather Tool', () => {
  it('should validate city name', async () => {
    await expect(
      callTool('get_weather', { city: '' })
    ).rejects.toThrow('City name cannot be empty');
  });

  it('should handle invalid city', async () => {
    await expect(
      callTool('get_weather', { city: 'InvalidCity12345' })
    ).rejects.toThrow('not found');
  });

  it('should return weather data', async () => {
    const result = await callTool('get_weather', {
      city: 'London',
      units: 'celsius'
    });

    expect(result.content).toHaveLength(1);
    expect(result.content[0].text).toContain('Temperature');
  });
});
```

**When to use -** For validating tool behavior in different scenarios:

- Unit testing individual tools
- Integration testing tool chains
- Regression testing after changes
- Edge case validation

**Why it matters:** Ensures reliability and predictability when tools are used individually or in combination.


#### **Best Practices for Tool Composition:**

- **Single Responsibility:** Each tool should do one thing well
- **Consistent Interfaces:** Use similar parameter patterns across tools
- **Clear Dependencies:** Document which tools work well together
- **Error Propagation:** Handle failures gracefully in tool chains
- **State Management:** Avoid tools that require complex state between calls
- **Flexible Outputs:** Design tool outputs to be usable as inputs for other tools
- **Documentation:** Clearly explain how tools can be combined
- **Version Compatibility:** Ensure tool interfaces remain stable

---

## Best Practices Checklist

**Schema Design**

  - Use descriptive names and descriptions
  - Add examples in descriptions
  - Set reasonable defaults
  - Use enums for constrained values
  - Add min/max for numbers

**Implementation**

  - Validate all inputs, even with schemas
  - Handle errors gracefully
  - Log to stderr, not stdout
  - Use async/await properly
  - Clean up resources (file handles, connections)

**Security**

  - Validate and sanitize file paths
  - Use prepared statements for SQL
  - Limit resource usage (file sizes, API calls)
  - Don't expose sensitive data in errors
  - Implement rate limiting

**Performance**

  - Cache expensive operations
  - Set reasonable timeouts
  - Limit result sizes
  - Use streaming for large data
  - Monitor execution time

**User Experience**

  - Provide clear error messages
  - Return structured data when possible
  - Include relevant context in responses
  - Handle edge cases gracefully
  - Document expected behavior

---


## Hands-On Exercises

### Exercise 1: Text Processing Tool

Create a tool that:

  - Counts words, characters, lines
  - Finds specific patterns
  - Calculates reading time
  - Detects language

<details>
<summary>💡 Solution: Text Processing Tool</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "process_text",
  description: "Analyze and process text content with various metrics and operations",
  inputSchema: {
    type: "object",
    properties: {
      text: {
        type: "string",
        description: "The text content to process"
      },
      operations: {
        type: "array",
        description: "Operations to perform",
        items: {
          type: "string",
          enum: ["count", "find_pattern", "reading_time", "detect_language"]
        },
        default: ["count"]
      },
      pattern: {
        type: "string",
        description: "Regex pattern for find_pattern operation"
      }
    },
    required: ["text"]
  }
}
```

Implementation - Add this handler in your "CallToolRequestSchema" handler:

```typescript
if (name === "process_text") {
  try {
    const text = args.text as string;
    const operations = (args.operations as string[]) || ["count"];
    const pattern = args.pattern as string;

    let results: string[] = [];

    for (const op of operations) {
      switch (op) {
        case "count":
          const lines = text.split('\n').length;
          const words = text.split(/\s+/).filter(w => w.length > 0).length;
          const chars = text.length;
          results.push(`📊 Text Statistics:\n- Lines: ${lines}\n- Words: ${words}\n- Characters: ${chars}`);
          break;

        case "find_pattern":
          if (!pattern) {
            results.push("❌ Pattern required for find_pattern operation");
            break;
          }
          try {
            const regex = new RegExp(pattern, 'g');
            const matches = text.match(regex);
            results.push(`🔍 Pattern Matches (${pattern}):\nFound ${matches ? matches.length : 0} matches:\n${matches ? matches.slice(0, 10).join('\n') : 'None'}`);
          } catch (e) {
            results.push(`❌ Invalid regex pattern: ${pattern}`);
          }
          break;

        case "reading_time":
          // Average reading speed: 200 words per minute
          const wordCount = text.split(/\s+/).filter(w => w.length > 0).length;
          const readingTime = Math.ceil(wordCount / 200);
          results.push(`⏱️ Reading Time: Approximately ${readingTime} minute${readingTime !== 1 ? 's' : ''} (${wordCount} words at 200 WPM)`);
          break;

        case "detect_language":
          // Simple language detection based on common words
          const englishWords = /\b(the|and|or|but|in|on|at|to|for|of|with|by)\b/gi;
          const spanishWords = /\b(el|la|los|las|y|o|pero|en|sobre|a|para|de|con|por)\b/gi;
          const frenchWords = /\b(le|la|les|et|ou|mais|dans|sur|à|pour|de|avec|par)\b/gi;

          const englishMatches = (text.match(englishWords) || []).length;
          const spanishMatches = (text.match(spanishWords) || []).length;
          const frenchMatches = (text.match(frenchWords) || []).length;

          const maxMatches = Math.max(englishMatches, spanishMatches, frenchMatches);
          let detectedLang = "Unknown";

          if (maxMatches > 0) {
            if (englishMatches === maxMatches) detectedLang = "English";
            else if (spanishMatches === maxMatches) detectedLang = "Spanish";
            else if (frenchMatches === maxMatches) detectedLang = "French";
          }

          results.push(`🌍 Detected Language: ${detectedLang} (confidence: ${maxMatches} common words)`);
          break;
      }
    }

    return {
      content: [
        {
          type: "text",
          text: results.join('\n\n')
        }
      ]
    };

  } catch (error) {
    throw new Error(`Text processing failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}
```

Testing - Test with different inputs:

```javascript
// Basic counting
{ text: "Hello world\nThis is a test", operations: ["count"] }

// Pattern matching
{ text: "The quick brown fox jumps over the lazy dog", operations: ["find_pattern"], pattern: "\\b\\w{4}\\b" }

// Multiple operations
{ text: "This is a longer piece of text to analyze for various metrics and patterns.", operations: ["count", "reading_time", "detect_language"] }
```

</details>


### Exercise 2: JSON Validator Tool

Create a tool that:

- Validates JSON syntax
- Validates against JSON Schema
- Formats/pretty-prints JSON
- Compares two JSON objects

<details>
<summary>💡 Solution: JSON Validator Tool</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "validate_json",
  description: "Validate, format, and compare JSON data",
  inputSchema: {
    type: "object",
    properties: {
      json: {
        type: "string",
        description: "JSON string to validate or format"
      },
      operation: {
        type: "string",
        description: "Operation to perform",
        enum: ["validate", "format", "schema_validate", "compare"],
        default: "validate"
      },
      schema: {
        type: "string",
        description: "JSON Schema for schema validation (as JSON string)"
      },
      json2: {
        type: "string",
        description: "Second JSON string for comparison"
      }
    },
    required: ["json", "operation"]
  }
}
```

Implementation - First, install the required dependency:

```bash
npm install ajv
```

Add the import:

```typescript
import Ajv from 'ajv';
```

Add this handler in your "CallToolRequestSchema" handler:

```typescript
if (name === "validate_json") {
  try {
    const json = args.json as string;
    const operation = args.operation as string;
    const schema = args.schema as string;
    const json2 = args.json2 as string;

    let result = "";

    switch (operation) {
      case "validate":
        try {
          JSON.parse(json);
          result = "✅ Valid JSON syntax";
        } catch (e) {
          result = `❌ Invalid JSON: ${e instanceof Error ? e.message : 'Unknown error'}`;
        }
        break;

      case "format":
        try {
          const parsed = JSON.parse(json);
          result = `📄 Formatted JSON:\n\`\`\`json\n${JSON.stringify(parsed, null, 2)}\n\`\`\``;
        } catch (e) {
          result = `❌ Cannot format invalid JSON: ${e instanceof Error ? e.message : 'Unknown error'}`;
        }
        break;

      case "schema_validate":
        if (!schema) {
          result = "❌ Schema required for schema validation";
          break;
        }
        try {
          const ajv = new Ajv();
          const parsedJson = JSON.parse(json);
          const parsedSchema = JSON.parse(schema);
          
          const validate = ajv.compile(parsedSchema);
          const valid = validate(parsedJson);
          
          if (valid) {
            result = "✅ JSON validates against schema";
          } else {
            result = `❌ Schema validation failed:\n${JSON.stringify(validate.errors, null, 2)}`;
          }
        } catch (e) {
          result = `❌ Schema validation error: ${e instanceof Error ? e.message : 'Unknown error'}`;
        }
        break;

      case "compare":
        if (!json2) {
          result = "❌ Second JSON required for comparison";
          break;
        }
        try {
          const obj1 = JSON.parse(json);
          const obj2 = JSON.parse(json2);
          
          const differences: string[] = [];
          
          // Simple comparison - check if objects are equal
          if (JSON.stringify(obj1) === JSON.stringify(obj2)) {
            result = "✅ JSON objects are identical";
          } else {
            // Find differences
            const keys1 = Object.keys(obj1);
            const keys2 = Object.keys(obj2);
            
            const added = keys2.filter(k => !keys1.includes(k));
            const removed = keys1.filter(k => !keys2.includes(k));
            const modified = keys1.filter(k => keys2.includes(k) && JSON.stringify(obj1[k]) !== JSON.stringify(obj2[k]));
            
            if (added.length > 0) differences.push(`Added keys: ${added.join(', ')}`);
            if (removed.length > 0) differences.push(`Removed keys: ${removed.join(', ')}`);
            if (modified.length > 0) differences.push(`Modified keys: ${modified.join(', ')}`);
            
            result = `⚠️ JSON objects differ:\n${differences.join('\n')}`;
          }
        } catch (e) {
          result = `❌ Comparison error: ${e instanceof Error ? e.message : 'Unknown error'}`;
        }
        break;
    }

    return {
      content: [
        {
          type: "text",
          text: result
        }
      ]
    };

  } catch (error) {
    throw new Error(`JSON validation failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}
```

Testing - Test different operations:

```javascript
// Validate syntax
{ json: '{"name": "test", "value": 123}', operation: "validate" }

// Format JSON
{ json: '{"name":"test","value":123}', operation: "format" }

// Schema validation
{ 
  json: '{"name": "John", "age": 30}', 
  operation: "schema_validate",
  schema: '{"type": "object", "properties": {"name": {"type": "string"}, "age": {"type": "number"}}}'
}

// Compare JSON
{
  json: '{"a": 1, "b": 2}',
  json2: '{"a": 1, "c": 3}',
  operation: "compare"
}
```

</details>


### Exercise 3: Web Scraper Tool

Create a tool that:

- Fetches web page content
- Extracts specific elements
- Returns clean text
- Handles errors gracefully

<details>
<summary>💡 Solution: Web Scraper Tool</summary>

Tool Schema - Add this to your tools array:

```typescript
{
  name: "scrape_web",
  description: "Fetch and extract content from web pages",
  inputSchema: {
    type: "object",
    properties: {
      url: {
        type: "string",
        description: "URL to scrape",
        format: "uri"
      },
      selector: {
        type: "string",
        description: "CSS selector to extract specific elements (optional)",
        default: "body"
      },
      includeText: {
        type: "boolean",
        description: "Extract only text content (remove HTML)",
        default: true
      },
      maxLength: {
        type: "number",
        description: "Maximum length of extracted content",
        minimum: 100,
        maximum: 10000,
        default: 2000
      },
      timeout: {
        type: "number",
        description: "Request timeout in milliseconds",
        minimum: 1000,
        maximum: 30000,
        default: 10000
      }
    },
    required: ["url"]
  }
}
```

Implementation - First, install the required dependencies:

```bash
npm install axios cheerio
```

Add the imports:

```typescript
import axios from 'axios';
import * as cheerio from 'cheerio';
```

Add this handler in your `CallToolRequestSchema` handler:

```typescript
if (name === "scrape_web") {
  try {
    const url = args.url as string;
    const selector = (args.selector as string) || "body";
    const includeText = (args.includeText !== false); // default true
    const maxLength = (args.maxLength as number) || 2000;
    const timeout = (args.timeout as number) || 10000;

    // Validate URL
    try {
      new URL(url);
    } catch {
      throw new Error("Invalid URL format");
    }

    // Fetch the webpage
    const response = await axios.get(url, {
      timeout: timeout,
      headers: {
        'User-Agent': 'MCP-Web-Scraper/1.0 (Educational Tool)'
      },
      maxContentLength: 5 * 1024 * 1024, // 5MB limit
    });

    // Load HTML into cheerio
    const $ = cheerio.load(response.data);
    
    // Extract content based on selector
    let extractedContent = "";
    
    if (selector === "body") {
      extractedContent = includeText ? $('body').text() : $('body').html() || "";
    } else {
      const elements = $(selector);
      if (elements.length === 0) {
        throw new Error(`No elements found matching selector: ${selector}`);
      }
      
      if (includeText) {
        extractedContent = elements.map((_, el) => $(el).text()).get().join('\n\n');
      } else {
        extractedContent = elements.map((_, el) => $.html(el)).get().join('\n\n');
      }
    }

    // Clean up the content
    extractedContent = extractedContent
      .replace(/\s+/g, ' ')  // Replace multiple whitespace with single space
      .replace(/\n\s*\n/g, '\n')  // Remove empty lines
      .trim();

    // Truncate if too long
    if (extractedContent.length > maxLength) {
      extractedContent = extractedContent.substring(0, maxLength - 3) + "...";
    }

    // Prepare metadata
    const metadata = {
      url: url,
      statusCode: response.status,
      contentType: response.headers['content-type'],
      contentLength: response.data.length,
      extractedLength: extractedContent.length,
      selector: selector,
      elementsFound: selector === "body" ? 1 : $(selector).length
    };

    return {
      content: [
        {
          type: "text",
          text: `🌐 Web Scraping Results\n\n📊 Metadata:\n${Object.entries(metadata).map(([k, v]) => `- ${k}: ${v}`).join('\n')}\n\n📄 Extracted Content:\n${extractedContent}`
        }
      ]
    };

  } catch (error) {
    if (axios.isAxiosError(error)) {
      if (error.code === 'ENOTFOUND') {
        throw new Error(`Could not resolve hostname: ${args.url}`);
      } else if (error.code === 'ECONNREFUSED') {
        throw new Error(`Connection refused: ${args.url}`);
      } else if (error.response) {
        throw new Error(`HTTP ${error.response.status}: ${error.response.statusText}`);
      } else if (error.code === 'ETIMEDOUT') {
        throw new Error(`Request timeout after ${args.timeout || 10000}ms`);
      } else {
        throw new Error(`Network error: ${error.message}`);
      }
    } else {
      throw new Error(`Web scraping failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
}
```

Testing - Test with different websites and selectors:

```javascript
// Basic page scraping
{ url: "https://httpbin.org/html" }

// Extract specific elements
{ url: "https://httpbin.org/html", selector: "h1" }

// Get HTML instead of text
{ url: "https://httpbin.org/html", selector: "p", includeText: false }

// Test error handling
{ url: "https://nonexistent-domain-12345.com" }
{ url: "https://httpbin.org/status/404" }
```

#### Security Notes

- This tool includes basic security measures but should not be used for production scraping
- Always respect robots.txt and terms of service
- Consider rate limiting to avoid being blocked
- Some websites may block requests without proper headers

</details>

