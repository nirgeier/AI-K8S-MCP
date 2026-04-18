#!/usr/bin/env python3
"""
Simple MCP Client Example

This script shows how to use the MCP server to:
- Get prompt templates
- Send requests to LLM models
- Get replies

Usage:
    python simple_mcp_client.py
"""

import asyncio
import httpx
import json

async def main():
    base_url = "http://localhost:8889"

    async with httpx.AsyncClient(timeout=60.0) as client:
        print("🔗 Connecting to MCP server...")

        # 1. Get a prompt template
        print("\n📝 Getting prompt template...")
        prompt_payload = {
            "tool": "code_review_prompt",
            "arguments": {
                "code": "def calculate_sum(a, b):\n    return a + b",
                "language": "python"
            }
        }

        response = await client.post(f"{base_url}/tools/execute", json=prompt_payload)
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                prompt_text = result["result"]
                print("✅ Prompt generated:")
                print(prompt_text[:200] + "..." if len(prompt_text) > 200 else prompt_text)
            else:
                print(f"❌ Error: {result.get('error')}")
                return
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            return

        # 2. Send the prompt to LLM
        print("\n🤖 Sending to LLM...")
        llm_payload = {
            "prompt": prompt_text,
            "model": "codestral:latest",
            "maxTokens": 300
        }

        response = await client.post(f"{base_url}/sampling", json=llm_payload)
        if response.status_code == 200:
            llm_result = response.json()
            if "error" not in llm_result:
                reply = llm_result.get("completion", "")
                print("✅ LLM Reply:")
                print(reply[:500] + "..." if len(reply) > 500 else reply)
            else:
                print(f"❌ LLM Error: {llm_result['error']}")
        else:
            print(f"❌ HTTP Error: {response.status_code}")

        # 3. Direct LLM chat
        print("\n💬 Direct LLM chat...")
        chat_payload = {
            "tool": "ollama_chat",
            "arguments": {
                "message": "What is the capital of France?",
                "model": "codestral:latest"
            }
        }

        response = await client.post(f"{base_url}/tools/execute", json=chat_payload)
        if response.status_code == 200:
            chat_result = response.json()
            if chat_result.get("success"):
                print("✅ Chat Reply:")
                print(chat_result["result"])
            else:
                print(f"❌ Chat Error: {chat_result.get('error')}")
        else:
            print(f"❌ HTTP Error: {response.status_code}")

if __name__ == "__main__":
    asyncio.run(main())