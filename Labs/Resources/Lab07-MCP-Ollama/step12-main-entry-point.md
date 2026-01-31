```python
async def main():
    server = CompleteOllamaMCPServer()
    await server.run()

if __name__ == "__main__":
    asyncio.run(main())
```
