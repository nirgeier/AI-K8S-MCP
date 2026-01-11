#!/usr/bin/env python3
"""
MCP Client Script for K-Agent MCP Server

This script demonstrates how to use the MCP server to:
1. List available prompts
2. Get prompt templates
3. Use prompts to generate content
4. Send requests to LLM models via sampling
5. Get replies from the LLM

Usage:
    python mcp_client.py

Requirements:
    - MCP server running on localhost:8889
    - httpx library: pip install httpx
"""

import asyncio
import httpx
import json
import sys
from typing import Dict, Any, List, Optional

class MCPClient:
    def __init__(self, base_url: str = "http://localhost:8889"):
        self.base_url = base_url
        self.client = httpx.AsyncClient(timeout=60.0)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()

    async def get_server_info(self) -> Dict[str, Any]:
        """Get server information and capabilities"""
        try:
            response = await self.client.get(f"{self.base_url}/.well-known/mcp")
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"Error getting server info: {e}")
            return {}

    async def list_tools(self) -> List[Dict[str, Any]]:
        """List available tools"""
        try:
            response = await self.client.post(f"{self.base_url}/tools")
            response.raise_for_status()
            data = response.json()
            return data.get("tools", [])
        except Exception as e:
            print(f"Error listing tools: {e}")
            return []

    async def list_prompts(self) -> List[Dict[str, Any]]:
        """List available prompts"""
        try:
            response = await self.client.post(f"{self.base_url}/prompts")
            response.raise_for_status()
            data = response.json()
            return data.get("prompts", [])
        except Exception as e:
            print(f"Error listing prompts: {e}")
            return []

    async def execute_tool(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a tool"""
        try:
            payload = {
                "tool": tool_name,
                "arguments": arguments
            }
            response = await self.client.post(f"{self.base_url}/tools/execute", json=payload)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {"success": False, "error": str(e)}

    async def get_prompt_template(self, prompt_name: str, **kwargs) -> Optional[str]:
        """Get a prompt template by calling the corresponding tool"""
        # For this MCP server, prompts are implemented as tools that return prompt text
        prompt_tools = {
            "code_review_prompt": "code_review_prompt",
            "debug_prompt": "debug_prompt"
        }

        tool_name = prompt_tools.get(prompt_name)
        if not tool_name:
            print(f"Unknown prompt: {prompt_name}")
            return None

        result = await self.execute_tool(tool_name, kwargs)
        if result.get("success"):
            return result.get("result")
        else:
            print(f"Error getting prompt: {result.get('error')}")
            return None

    async def sample_llm(self, prompt: str, model: str = "llama3.2:latest", max_tokens: int = 500) -> Dict[str, Any]:
        """Send a prompt to the LLM via sampling endpoint"""
        try:
            payload = {
                "prompt": prompt,
                "model": model,
                "maxTokens": max_tokens
            }
            response = await self.client.post(f"{self.base_url}/sampling", json=payload)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {"error": str(e), "completion": ""}

    async def chat_with_llm(self, message: str, model: str = "llama3.2:latest", system_prompt: str = "") -> str:
        """Chat with LLM using the chat tool"""
        result = await self.execute_tool("ollama_chat", {
            "message": message,
            "model": model,
            "system": system_prompt
        })

        if result.get("success"):
            return result.get("result")
        else:
            return f"Error: {result.get('error')}"

    async def generate_with_llm(self, prompt: str, model: str = "llama3.2:latest", max_tokens: int = 500) -> str:
        """Generate text with LLM using the generate tool"""
        result = await self.execute_tool("ollama_generate", {
            "prompt": prompt,
            "model": model,
            "max_tokens": max_tokens
        })

        if result.get("success"):
            return result.get("result")
        else:
            return f"Error: {result.get('error')}"

async def main():
    """Main demonstration function"""
    print("🚀 MCP Client Demo")
    print("=" * 50)

    async with MCPClient() as client:
        # 1. Get server information
        print("\n1. Getting server information...")
        server_info = await client.get_server_info()
        if server_info:
            print(f"✅ Connected to: {server_info.get('name', 'Unknown')}")
            print(f"   Version: {server_info.get('version', 'Unknown')}")
            print(f"   Base URL: {server_info.get('base_url', 'Unknown')}")
        else:
            print("❌ Failed to connect to MCP server")
            print("   Make sure the server is running on localhost:8889")
            return

        # 2. List available tools
        print("\n2. Listing available tools...")
        tools = await client.list_tools()
        if tools:
            print(f"✅ Found {len(tools)} tools:")
            for tool in tools:
                print(f"   - {tool.get('name', 'Unknown')}: {tool.get('description', 'No description')}")
        else:
            print("❌ No tools found")

        # 3. List available prompts
        print("\n3. Listing available prompts...")
        prompts = await client.list_prompts()
        if prompts:
            print(f"✅ Found {len(prompts)} prompts:")
            for prompt in prompts:
                print(f"   - {prompt.get('name', 'Unknown')}: {prompt.get('description', 'No description')}")
        else:
            print("❌ No prompts found")

        # 4. Use a prompt template
        print("\n4. Using prompt template...")
        if prompts:
            # Use the code review prompt
            prompt_template = await client.get_prompt_template("code_review_prompt",
                code="def hello():\n    print('Hello World')",
                language="python"
            )
            if prompt_template:
                print("✅ Generated prompt template:")
                print("-" * 30)
                print(prompt_template)
                print("-" * 30)

                # 5. Send to LLM for processing
                print("\n5. Sending prompt to LLM...")
                llm_response = await client.sample_llm(prompt_template, max_tokens=300)
                if "error" not in llm_response:
                    print("✅ LLM Response:")
                    print("-" * 30)
                    print(llm_response.get("completion", "No response"))
                    print("-" * 30)
                else:
                    print(f"❌ LLM Error: {llm_response['error']}")
            else:
                print("❌ Failed to generate prompt template")

        # 6. Direct chat with LLM
        print("\n6. Direct chat with LLM...")
        chat_response = await client.chat_with_llm(
            "Explain what MCP (Model Context Protocol) is in simple terms.",
            system_prompt="You are a helpful AI assistant explaining technical concepts."
        )
        if not chat_response.startswith("Error"):
            print("✅ Chat Response:")
            print("-" * 30)
            print(chat_response)
            print("-" * 30)
        else:
            print(f"❌ Chat Error: {chat_response}")

        # 7. Direct generation with LLM
        print("\n7. Direct text generation with LLM...")
        gen_response = await client.generate_with_llm(
            "Write a short poem about programming.",
            max_tokens=200
        )
        if not gen_response.startswith("Error"):
            print("✅ Generation Response:")
            print("-" * 30)
            print(gen_response)
            print("-" * 30)
        else:
            print(f"❌ Generation Error: {gen_response}")

        # 8. Test a simple tool
        print("\n8. Testing simple tool (hello)...")
        tool_result = await client.execute_tool("hello", {"name": "MCP User"})
        if tool_result.get("success"):
            print(f"✅ Tool Result: {tool_result.get('result')}")
        else:
            print(f"❌ Tool Error: {tool_result.get('error')}")

    print("\n🎉 Demo completed!")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
        sys.exit(0)
    except Exception as e:
        print(f"\n💥 Error: {e}")
        sys.exit(1)