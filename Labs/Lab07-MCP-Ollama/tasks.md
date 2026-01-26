# MCP Lab Tasks - Lab 3


Welcome to the MCP Lab Tasks section! 

This comprehensive collection of hands-on exercises will help you master the Model Context Protocol through practical implementation.

Each lab has 15 exercises designed to build your skills progressively. Try to solve each exercise on your own before clicking the solution dropdown.

---



### Exercise 3.1: Calculator Tool

Implement a calculator tool that supports basic arithmetic operations.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "calculate") {
        const { operation, a, b } = args;
        let result: number;

        switch (operation) {
          case "add":
            result = a + b;
            break;
          case "subtract":
            result = a - b;
            break;
          case "multiply":
            result = a * b;
            break;
          case "divide":
            if (b === 0) throw new Error("Division by zero");
            result = a / b;
            break;
          default:
            throw new Error(`Unknown operation: ${operation}`);
        }

        return {
          content: [{ type: "text", text: `Result: ${result}` }]
        };
      }
    });
    ```

### Exercise 3.2: File Reader Tool

Create a tool that reads and returns file contents.

??? "Solution"
    ```typescript
    import { readFileSync } from "fs";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "read_file") {
        const { path } = args;
        try {
          const content = readFileSync(path, "utf-8");
          return {
            content: [{ type: "text", text: content }]
          };
        } catch (error) {
          throw new Error(`Failed to read file: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.3: HTTP Request Tool

Implement a tool that makes HTTP requests.

??? "Solution"
    ```typescript
    import fetch from "node-fetch";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "http_request") {
        const { url, method = "GET", headers = {} } = args;

        try {
          const response = await fetch(url, { method, headers });
          const data = await response.text();

          return {
            content: [
              { type: "text", text: `Status: ${response.status}` },
              { type: "text", text: `Body: ${data}` }
            ]
          };
        } catch (error) {
          throw new Error(`HTTP request failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.4: JSON Parser Tool

Create a tool that parses and validates JSON data.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "parse_json") {
        const { json_string } = args;

        try {
          const parsed = JSON.parse(json_string);
          return {
            content: [
              { type: "text", text: "JSON is valid" },
              { type: "text", text: `Parsed: ${JSON.stringify(parsed, null, 2)}` }
            ]
          };
        } catch (error) {
          return {
            content: [{ type: "text", text: `Invalid JSON: ${error.message}` }],
            isError: true
          };
        }
      }
    });
    ```

### Exercise 3.5: String Manipulation Tool

Implement a tool for common string operations.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "string_ops") {
        const { operation, text } = args;
        let result: string;

        switch (operation) {
          case "uppercase":
            result = text.toUpperCase();
            break;
          case "lowercase":
            result = text.toLowerCase();
            break;
          case "reverse":
            result = text.split('').reverse().join('');
            break;
          case "length":
            result = text.length.toString();
            break;
          default:
            throw new Error(`Unknown operation: ${operation}`);
        }

        return {
          content: [{ type: "text", text: `Result: ${result}` }]
        };
      }
    });
    ```

### Exercise 3.6: Database Query Tool

Create a tool that executes simple database queries.

??? "Solution"
    ```typescript
    import sqlite3 from "sqlite3";

    const db = new sqlite3.Database(':memory:');

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "db_query") {
        const { query } = args;

        return new Promise((resolve, reject) => {
          db.all(query, [], (err, rows) => {
            if (err) {
              reject(new Error(`Database error: ${err.message}`));
            } else {
              resolve({
                content: [{ type: "text", text: JSON.stringify(rows, null, 2) }]
              });
            }
          });
        });
      }
    });
    ```

### Exercise 3.7: Image Processing Tool

Implement a tool that gets image metadata.

??? "Solution"
    ```typescript
    import sharp from "sharp";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "image_info") {
        const { image_path } = args;

        try {
          const metadata = await sharp(image_path).metadata();

          return {
            content: [{
              type: "text",
              text: `Width: ${metadata.width}, Height: ${metadata.height}, Format: ${metadata.format}`
            }]
          };
        } catch (error) {
          throw new Error(`Image processing failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.8: Code Linter Tool

Create a tool that lints JavaScript/TypeScript code.

??? "Solution"
    ```typescript
    import { ESLint } from "eslint";

    const eslint = new ESLint();

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "lint_code") {
        const { code, filename = "temp.js" } = args;

        try {
          const results = await eslint.lintText(code, { filePath: filename });
          const formatter = await eslint.loadFormatter("stylish");
          const resultText = formatter.format(results);

          return {
            content: [{ type: "text", text: resultText || "No linting issues found" }]
          };
        } catch (error) {
          throw new Error(`Linting failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.9: Weather API Tool

Implement a tool that fetches weather data.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "get_weather") {
        const { city } = args;
        const apiKey = process.env.WEATHER_API_KEY;

        if (!apiKey) {
          throw new Error("Weather API key not configured");
        }

        try {
          const response = await fetch(
            `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`
          );

          if (!response.ok) {
            throw new Error(`Weather API error: ${response.status}`);
          }

          const data = await response.json();

          return {
            content: [{
              type: "text",
              text: `Weather in ${city}: ${data.weather[0].description}, ${data.main.temp}°C`
            }]
          };
        } catch (error) {
          throw new Error(`Weather fetch failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.10: Git Operations Tool

Create a tool for basic Git operations.

??? "Solution"
    ```typescript
    import { exec } from "child_process";
    import { promisify } from "util";

    const execAsync = promisify(exec);

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "git_status") {
        try {
          const { stdout } = await execAsync("git status --porcelain");
          return {
            content: [{ type: "text", text: stdout || "Working directory clean" }]
          };
        } catch (error) {
          throw new Error(`Git command failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.11: Regex Tool

Implement a tool for regular expression operations.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "regex_match") {
        const { pattern, text, flags = "" } = args;

        try {
          const regex = new RegExp(pattern, flags);
          const matches = text.match(regex);

          return {
            content: [{
              type: "text",
              text: matches ? `Matches found: ${matches.join(", ")}` : "No matches found"
            }]
          };
        } catch (error) {
          throw new Error(`Regex error: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.12: Unit Converter Tool

Create a tool that converts between different units.

??? "Solution"
    ```typescript
    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "convert_units") {
        const { value, from, to } = args;

        // Simple conversion factors (could be expanded)
        const conversions: Record<string, Record<string, number>> = {
          celsius: { fahrenheit: (c) => c * 9/5 + 32, kelvin: (c) => c + 273.15 },
          fahrenheit: { celsius: (f) => (f - 32) * 5/9, kelvin: (f) => (f - 32) * 5/9 + 273.15 },
          meters: { feet: (m) => m * 3.28084, kilometers: (m) => m / 1000 },
          feet: { meters: (f) => f / 3.28084, kilometers: (f) => f / 3280.84 }
        };

        if (conversions[from] && conversions[from][to]) {
          const result = conversions[from][to](value);
          return {
            content: [{ type: "text", text: `${value} ${from} = ${result.toFixed(2)} ${to}` }]
          };
        }

        throw new Error(`Conversion from ${from} to ${to} not supported`);
      }
    });
    ```

### Exercise 3.13: CSV Parser Tool

Implement a tool that parses CSV data.

??? "Solution"
    ```typescript
    import { parse } from "csv-parse/sync";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "parse_csv") {
        const { csv_data } = args;

        try {
          const records = parse(csv_data, {
            columns: true,
            skip_empty_lines: true
          });

          return {
            content: [{
              type: "text",
              text: `Parsed ${records.length} rows: ${JSON.stringify(records.slice(0, 5), null, 2)}`
            }]
          };
        } catch (error) {
          throw new Error(`CSV parsing failed: ${error.message}`);
        }
      }
    });
    ```

### Exercise 3.14: Password Generator Tool

Create a tool that generates secure passwords.

??? "Solution"
    ```typescript
    import { randomBytes } from "crypto";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "generate_password") {
        const { length = 12, include_special = true } = args;

        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        const specialChars = "!@#$%^&*";

        let charset = chars;
        if (include_special) {
          charset += specialChars;
        }

        let password = "";
        const bytes = randomBytes(length);

        for (let i = 0; i < length; i++) {
          password += charset[bytes[i] % charset.length];
        }

        return {
          content: [{ type: "text", text: `Generated password: ${password}` }]
        };
      }
    });
    ```

### Exercise 3.15: Code Formatter Tool

Implement a tool that formats code using Prettier.

??? "Solution"
    ```typescript
    import prettier from "prettier";

    server.setRequestHandler("tools/call", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "format_code") {
        const { code, language = "javascript" } = args;

        try {
          const formatted = await prettier.format(code, {
            parser: language,
            semi: true,
            singleQuote: true
          });

          return {
            content: [{ type: "text", text: formatted }]
          };
        } catch (error) {
          throw new Error(`Code formatting failed: ${error.message}`);
        }
      }
    });
    ```