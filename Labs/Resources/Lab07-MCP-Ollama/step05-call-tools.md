# Step 05: Tool Handlers

Add this method to your class:

```python
@self.server.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    if name == "country_info":
        country = arguments.get("country", "").lower()
        info_types = arguments.get("info_types", [])

        if not country:
            raise ValueError("Country name is required")

        if not info_types:
            info_types = ["capital", "population", "height", "foundation_year"]

        retrieved_info = {}
        for info_type in info_types:
            # Safe access to nested dictionary
            type_data = self.country_data.get(info_type, {})
            if country in type_data:
                retrieved_info[info_type] = type_data[country]
            else:
                retrieved_info[info_type] = f"Information not available (Data loaded: {len(type_data)} records)"

        # Use Ollama to generate a formatted response
        prompt = f"Format the following information about {country.title()} into a nice, readable response: {json.dumps(retrieved_info, indent=2)}"

        try:
            # Use llama3.2 as detected on your system
            response = self.ollama_client.generate(
                model='llama3.2',
                prompt=prompt,
                options={'temperature': 0.7, 'max_tokens': 300}
            )

            result = response['response'].strip()

            return [TextContent(type="text", text=result)]

        except Exception as e:
            # Fallback if Ollama fails
            return [TextContent(type="text", text=f"Error getting AI response: {str(e)}\n\nRaw Data: {retrieved_info}")]

    elif name == "read_file":
        filepath = arguments.get("filepath", "")
        max_size = arguments.get("max_size", 1048576)
        encoding = arguments.get("encoding", "utf-8")

        if not filepath:
            raise ValueError("File path is required")

        path = Path(filepath)
        if not path.exists():
            raise ValueError(f"File not found: {filepath}")

        if not path.is_file():
            raise ValueError(f"Path is not a file: {filepath}")

        file_size = path.stat().st_size
        if file_size > max_size:
            raise ValueError(f"File too large: {file_size} bytes (max: {max_size})")

        try:
            with open(path, 'r', encoding=encoding) as f:
                content = f.read()

            metadata = f"File: {path.name}\nSize: {file_size} bytes\nEncoding: {encoding}\n\n"
            result = metadata + "Content:\n" + content

            return [TextContent(type="text", text=result)]

        except Exception as e:
            return [TextContent(type="text", text=f"Error reading file: {str(e)}")]

    elif name == "query_database":
        query = arguments.get("query", "").strip()
        database = arguments.get("database", self.db_path)

        if not query:
            raise ValueError("Query is required")

        if not query.upper().startswith("SELECT"):
            raise ValueError("Only SELECT queries are allowed")

        try:
            conn = sqlite3.connect(database)
            cursor = conn.cursor()

            cursor.execute(query)
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]

            conn.close()

            if not rows:
                result = "No results found."
            else:
                # Format as table
                result = "| " + " | ".join(columns) + " |\n"
                result += "|" + "|".join(["---"] * len(columns)) + "|\n"
                for row in rows:
                    result += "| " + " | ".join(str(cell) for cell in row) + " |\n"

            return [TextContent(type="text", text=result)]

        except Exception as e:
            return [TextContent(type="text", text=f"Database error: {str(e)}")]

    else:
        raise ValueError(f"Unknown tool: {name}")
```
