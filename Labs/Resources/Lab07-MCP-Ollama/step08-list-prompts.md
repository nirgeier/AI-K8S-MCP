```python
@self.server.list_prompts()
async def list_prompts() -> List[Prompt]:
  return [
    Prompt(
      name="analyze-country-data",
      description="Analyze country data and provide insights",
      arguments=[
        {
          "name": "country",
          "description": "Country to analyze",
          "required": True
        }
      ]
    )
  ]
```
