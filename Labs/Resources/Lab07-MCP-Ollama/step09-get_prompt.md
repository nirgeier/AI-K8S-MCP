# Step 09: Prompt Handlers

### Method `get_prompt`

**Capabilities:**

- Generates prompt content.
- Handles prompt requests and returns structured messages.

**Why This Runs Seventh:**

- Connects prompt templates to actual content.
- Makes prompts usable by clients.

---

Add this method to your class:

```python
@self.server.get_prompt()
async def get_prompt(name: str, arguments: Dict[str, Any]) -> GetPromptResult:
    if name == "analyze-country-data":
        country = arguments.get("country", "Unknown Country")
        prompt_text = f"""Analyze the data for {country} and provide insights:

1. Use the country_info tool to get information about the country's capital, population, topographic height, and foundation year
2. Analyze the retrieved information and provide interesting facts
3. Consider historical context and geographical significance
4. Provide recommendations or interesting trivia based on the data

Please provide a comprehensive country analysis."""

        return GetPromptResult(
            description=f"Country analysis prompt for {country}",
            messages=[
                {
                    "role": "user",
                    "content": {
                        "type": "text",
                        "text": prompt_text
                    }
                }
            ]
        )

    else:
        raise ValueError(f"Unknown prompt: {name}")
```
