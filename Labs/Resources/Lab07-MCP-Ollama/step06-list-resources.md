```python
@self.server.list_resources()
async def list_resources() -> List[Resource]:
  return [
    Resource(
      uri="resource://server-info",
      name="Server Information",
      description="Basic information about this MCP server",
      mimeType="application/json"
    ),
    Resource(
      uri="resource://ollama-models",
      name="Available Ollama Models",
      description="List of available Ollama models",
      mimeType="application/json"
    )
  ]
```
