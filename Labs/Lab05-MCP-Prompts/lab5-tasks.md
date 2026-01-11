# MCP Lab Tasks - Lab 5

Welcome to the MCP Lab Tasks section! 

This comprehensive collection of hands-on exercises will help you master the Model Context Protocol through practical implementation.

Each lab has 15 exercises designed to build your skills progressively. Try to solve each exercise on your own before clicking the solution dropdown.

---



### Exercise 5.1: Simple Prompt Template

Create a basic prompt template that generates greetings.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "greeting") {
        const { name: userName = "World" } = args || {};

        return {
          description: "A friendly greeting prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Hello ${userName}! How are you doing today?`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.2: Code Review Prompt

Implement a prompt for code review assistance.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "code_review") {
        const { code, language = "javascript" } = args || {};

        return {
          description: "Code review assistant prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Please review the following ${language} code for:\n- Code quality and best practices\n- Potential bugs or issues\n- Performance considerations\n- Security concerns\n\nCode:\n${code}\n\nPlease provide specific feedback and suggestions for improvement.`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.3: SQL Query Builder Prompt

Create a prompt that helps build SQL queries.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "sql_builder") {
        const { table, columns, conditions } = args || {};

        return {
          description: "SQL query building assistant",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Help me build an SQL query with the following requirements:\n- Table: ${table || "users"}\n- Columns: ${columns || "name, email, created_at"}\n- Conditions: ${conditions || "active = true"}\n\nPlease provide the SQL query and explain what it does.`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.4: Documentation Generator Prompt

Implement a prompt that generates documentation.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "generate_docs") {
        const { code, language = "typescript" } = args || {};

        return {
          description: "Documentation generator prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Generate comprehensive documentation for the following ${language} code:\n\n${code}\n\nPlease include:\n1. Function/class purpose\n2. Parameters and return types\n3. Usage examples\n4. Important notes or caveats`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.5: Error Analysis Prompt

Create a prompt for analyzing error messages.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "error_analysis") {
        const { error_message, code_context } = args || {};

        return {
          description: "Error analysis and debugging prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `I'm encountering this error:\n\n${error_message}\n\nCode context:\n${code_context || "No context provided"}\n\nPlease help me:\n1. Understand what this error means\n2. Identify the likely cause\n3. Suggest how to fix it\n4. Provide preventive measures for similar errors`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.6: API Design Prompt

Implement a prompt for API design assistance.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "api_design") {
        const { resource, operations } = args || {};

        return {
          description: "API design assistant prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Design a REST API for managing ${resource || "users"} with the following operations:\n${operations || "CRUD operations (Create, Read, Update, Delete)"}\n\nPlease provide:\n1. Endpoint definitions with HTTP methods\n2. Request/response schemas\n3. Error handling approach\n4. Best practices recommendations`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.7: Test Case Generator Prompt

Create a prompt that generates test cases.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "generate_tests") {
        const { function_code, language = "javascript" } = args || {};

        return {
          description: "Test case generator prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Generate comprehensive test cases for this ${language} function:\n\n${function_code}\n\nPlease provide:\n1. Unit tests for normal operation\n2. Edge cases and error conditions\n3. Integration test scenarios\n4. Test framework code (Jest/Mocha for JS, pytest for Python, etc.)`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.8: Performance Optimization Prompt

Implement a prompt for performance analysis.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "performance_tips") {
        const { code, language = "javascript" } = args || {};

        return {
          description: "Performance optimization prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Analyze this ${language} code for performance issues:\n\n${code}\n\nPlease identify:\n1. Performance bottlenecks\n2. Memory leaks or inefficiencies\n3. Optimization opportunities\n4. Recommended improvements with code examples`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.9: Security Audit Prompt

Create a prompt for security code review.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "security_audit") {
        const { code, language = "javascript" } = args || {};

        return {
          description: "Security audit prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Perform a security audit on this ${language} code:\n\n${code}\n\nCheck for:\n1. Input validation vulnerabilities\n2. Authentication/authorization issues\n3. SQL injection or XSS vulnerabilities\n4. Secure coding practices\n5. Data exposure risks\n\nProvide specific recommendations for each issue found.`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.10: Database Schema Design Prompt

Implement a prompt for database design.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "db_schema") {
        const { entities, relationships } = args || {};

        return {
          description: "Database schema design prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Design a database schema for:\nEntities: ${entities || "users, posts, comments"}\nRelationships: ${relationships || "users have many posts, posts have many comments"}\n\nPlease provide:\n1. Table definitions with columns and types\n2. Primary and foreign key relationships\n3. Indexes for performance\n4. Sample SQL DDL statements`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.11: Refactoring Prompt

Create a prompt for code refactoring suggestions.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "refactor_code") {
        const { code, language = "javascript", issues } = args || {};

        return {
          description: "Code refactoring prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Refactor this ${language} code to improve:\n- Readability and maintainability\n- Performance\n- Following best practices\n${issues ? `- Address these specific issues: ${issues}` : ""}\n\nOriginal code:\n${code}\n\nPlease provide the refactored version with explanations of the changes.`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.12: Deployment Strategy Prompt

Implement a prompt for deployment planning.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "deployment_plan") {
        const { app_type, environment } = args || {};

        return {
          description: "Deployment strategy prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Create a deployment strategy for a ${app_type || "web application"} to ${environment || "production"}.\n\nPlease include:\n1. Infrastructure requirements\n2. CI/CD pipeline setup\n3. Environment configuration\n4. Monitoring and logging\n5. Rollback procedures\n6. Scaling considerations`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.13: Interview Question Generator Prompt

Create a prompt that generates technical interview questions.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "interview_questions") {
        const { topic, level = "intermediate" } = args || {};

        return {
          description: "Technical interview question generator",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Generate ${level} level interview questions for ${topic || "JavaScript development"}.\n\nPlease provide:\n1. 5 conceptual questions\n2. 3 coding problems with solutions\n3. 2 system design questions\n4. Expected answers or evaluation criteria for each`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.14: Code Explanation Prompt

Implement a prompt for explaining complex code.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "explain_code") {
        const { code, language = "javascript", audience = "intermediate" } = args || {};

        return {
          description: "Code explanation prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Explain this ${language} code to an ${audience} developer:\n\n${code}\n\nPlease break down:\n1. What the code does overall\n2. Key components and their purposes\n3. How the pieces fit together\n4. Important concepts or patterns used\n5. Potential improvements or alternatives`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```

### Exercise 5.15: Requirements Analysis Prompt

Create a prompt for analyzing project requirements.

??? "Solution"
    ```typescript
    server.setRequestHandler("prompts/get", async (request) => {
      const { name, arguments: args } = request.params;

      if (name === "requirements_analysis") {
        const { requirements, constraints } = args || {};

        return {
          description: "Requirements analysis prompt",
          messages: [{
            role: "user",
            content: {
              type: "text",
              text: `Analyze these project requirements:\n\n${requirements || "Build a user management system with authentication, profiles, and admin features."}\n\nConstraints: ${constraints || "Must be web-based, support 1000 concurrent users, comply with GDPR."}\n\nPlease provide:\n1. Functional requirements breakdown\n2. Non-functional requirements\n3. Technical feasibility assessment\n4. Recommended technology stack\n5. High-level architecture suggestions\n6. Potential risks and mitigation strategies`
            }
          }]
        };
      }

      throw new Error(`Unknown prompt: ${name}`);
    });
    ```