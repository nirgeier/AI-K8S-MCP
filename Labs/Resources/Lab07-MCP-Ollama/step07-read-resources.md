# Step 07: Resource Handlers

### Method `read_resource`

**Capabilities:**

- Implements resource reading logic
- Handles resource requests and returns content

**Why This Runs Fifth:**

- Connects resource URIs to actual content
- Makes resources accessible to clients

---

Add this method to your class:

```python
@self.server.read_resource()
async def read_resource(self, uri: str) -> str:
  uri_str = str(uri).strip()

  # Debug log to help diagnose the mismatch
  print(f"DEBUG: Requesting URI: '{uri_str}'", file=sys.stderr)

  # Allow exact match or match without scheme to be robust
  if uri_str == "resource://server-info" or uri_str.endswith("server-info"):
    info = {
      "name": "Complete Ollama MCP Server",
      "version": "1.0.0",
      "capabilities": ["tools", "resources", "ollama-integration"],
      "tools": ["country_info", "read_file", "query_database"],
      "country_database": "193 UN member states with capitals, populations, topographic heights, and foundation years"
    }
    return json.dumps(info, indent=2)

  elif uri_str == "resource://ollama-models" or uri_str.endswith("ollama-models"):
    try:
      models = self.ollama_client.list()
      return json.dumps(models, indent=2)
    except Exception as e:
      return json.dumps({"error": str(e)}, indent=2)

  else:
    raise ValueError(f"Unknown resource: {uri_str}")
```
