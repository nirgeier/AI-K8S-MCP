```python
async def run(self):
    async with stdio_server() as (read_stream, write_stream):
        await self.server.run(read_stream, write_stream, self.server.create_initialization_options())
```
