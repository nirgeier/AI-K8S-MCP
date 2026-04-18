#!/usr/bin/env python3
"""
Workflow Client
Demonstrates the use of the extracted workflow server
"""

import sys
import shutil
import asyncio

# Check if mcp package is installed
try:
    from mcp.client.stdio import stdio_client, StdioServerParameters
    from mcp.client.session import ClientSession
except ImportError:
    print("Error: 'mcp' package not found. Please install it using: pip install mcp")
    sys.exit(1)

async def run_client_demo():
    print("🚀 Starting Workflow Client Demo...")
    
    # Define server parameters - points to our workflow_server.py
    server_params = StdioServerParameters(
        command="python3",
        args=["workflow_server.py"],
        env=None
    )
    
    print(f"🔌 Connecting to server: {server_params.command} {' '.join(server_params.args)}")
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # 1. Initialize
            await session.initialize()
            print("✅ Connected to server!")
            
            # 2. List Tools
            print("\n📋 Listing Available Tools:")
            tools = await session.list_tools()
            for tool in tools.tools:
                print(f"  - {tool.name}: {tool.description}")
            
            # 3. Call Tool (Calculate)
            print("\n🧮 Calling 'calculate' tool (add 10 + 5):")
            result = await session.call_tool("calculate", {
                "operation": "add",
                "a": 10,
                "b": 5
            })
            print(f"  Result: {result.content[0].text}")
            
            # 4. Call Tool (Store Data)
            print("\n💾 Calling 'store_data' tool:")
            await session.call_tool("store_data", {
                "key": "demo_key",
                "value": "Hello from Client!"
            })
            print("  Data stored successfully.")
            
            # 5. List Resources
            print("\n📚 Listing Available Resources:")
            resources = await session.list_resources()
            for resource in resources.resources:
                print(f"  - {resource.name} ({resource.uri})")
            
            # 6. Read Resource
            print("\n📖 Reading 'resource://data-store':")
            content = await session.read_resource("resource://data-store")
            print(f"  Content: {content.contents[0].text}")
            
            # 7. List Prompts
            print("\n💬 Listing Available Prompts:")
            prompts = await session.list_prompts()
            for prompt in prompts.prompts:
                print(f"  - {prompt.name}: {prompt.description}")
            
            # 8. Get Prompt
            print("\n📝 Getting 'analyze-data' prompt:")
            prompt_res = await session.get_prompt("analyze-data", {"key": "demo_key"})
            print("  Prompt Content:")
            # The prompt structure might vary slightly by SDK version, printing generic info
            # Usually result.messages or result.description
            # For this demo we'll print what we get
            print(f"  {prompt_res}")

    print("\n🎉 Demo Complete!")

if __name__ == "__main__":
    asyncio.run(run_client_demo())
