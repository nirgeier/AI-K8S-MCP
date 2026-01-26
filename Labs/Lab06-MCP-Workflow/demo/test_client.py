import asyncio
import sys
import os
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def run():
    # Get the absolute path to the server script
    current_dir = os.path.dirname(os.path.abspath(__file__))
    server_script = os.path.join(current_dir, "step11-main.py")

    # Define the server parameters
    server_params = StdioServerParameters(
        command="python3",
        args=[server_script],
        env=None
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize the connection
            await session.initialize()

            # List Tools
            print("--- Tools ---")
            tools = await session.list_tools()
            for tool in tools.tools:
                print(f"- {tool.name}: {tool.description}")

            # Call a Tool (Calculate)
            print("\n--- Testing 'calculate' Tool ---")
            result = await session.call_tool("calculate", arguments={"operation": "add", "a": 10, "b": 5})
            print(f"Result (10 + 5): {result.content[0].text}")

            # List Resources
            print("\n--- Resources ---")
            resources = await session.list_resources()
            for resource in resources.resources:
                print(f"- {resource.name} ({resource.uri})")

            # Read a Resource
            print("\n--- Reading 'welcome' Resource ---")
            resource_content = await session.read_resource("resource://welcome")
            print(resource_content.contents[0].text)
            
            # List Prompts
            print("\n--- Prompts ---")
            prompts = await session.list_prompts()
            for prompt in prompts.prompts:
                print(f"- {prompt.name}")

            # Get a Prompt
            print("\n--- Getting 'analyze-data' Prompt ---")
            prompt_res = await session.get_prompt("analyze-data", arguments={"key": "test_key"})
            print(prompt_res.messages[0].content.text)

if __name__ == "__main__":
    asyncio.run(run())
