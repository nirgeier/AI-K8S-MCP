```python
@self.server.list_tools()
async def list_tools() -> List[Tool]:
  return [
    Tool(
      name="country_info",
      description="Get country information using RAG from CSV databases",
      inputSchema={
        "type": "object",
        "properties": {
          "country": {
            "type": "string",
            "description": "The country name to get information for"
          },
          "info_types": {
            "type": "array",
            "items": {"type": "string", "enum": ["capital", "population", "height", "foundation_year"]},
            "description": "Types of information to retrieve"
          }
        },
        "required": ["country"]
      }
    ),
    Tool(
      name="read_file",
      description="Read and analyze file contents with metadata",
      inputSchema={
        "type": "object",
        "properties": {
          "filepath": {
            "type": "string",
            "description": "Absolute path to the file to read"
          },
          "max_size": {
            "type": "number",
            "default": 1048576,
            "description": "Maximum file size in bytes (default 1MB)"
          },
          "encoding": {
            "type": "string",
            "default": "utf-8",
            "description": "File encoding"
          }
        },
        "required": ["filepath"]
      }
    ),
    Tool(
      name="query_database",
      description="Execute SELECT queries on SQLite database",
      inputSchema={
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "SELECT SQL query to execute"
          },
          "database": {
            "type": "string",
            "default": "data.db",
            "description": "Database file path"
          }
        },
        "required": ["query"]
      }
    )
  ]
```
