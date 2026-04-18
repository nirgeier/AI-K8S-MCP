#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         MCP Function Call Workflow Tests                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

BASE_URL="http://localhost:8889"

echo "1️⃣  Single Tool Execution - hello"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool": "hello", "arguments": {"name": "Function Call"}}' | jq '{execution_id, tool, success, result, duration_ms}'

echo ""
echo "2️⃣  Single Tool Execution - add"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool": "add", "arguments": {"a": 123, "b": 456}}' | jq '{execution_id, tool, success, result, duration_ms}'

echo ""
echo "3️⃣  Batch Tool Execution"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/batch \
  -H "Content-Type: application/json" \
  -d '{
    "calls": [
      {"tool": "hello", "arguments": {"name": "Alice"}},
      {"tool": "add", "arguments": {"a": 50, "b": 75}},
      {"tool": "hello", "arguments": {"name": "Bob"}}
    ]
  }' | jq '{total, success, results: [.results[] | {tool, success, result}]}'

echo ""
echo "4️⃣  Error Handling - Missing Argument"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool": "hello", "arguments": {}}' | jq '{tool, success, error}'

echo ""
echo "5️⃣  Error Handling - Unknown Tool"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool": "nonexistent", "arguments": {}}' | jq '{tool, success, error}'

echo ""
echo "6️⃣  Execution History (Last 5)"
echo "────────────────────────────────────────"
curl -sS "$BASE_URL/tools/history?limit=5" | jq '{total, recent: [.executions[] | {id: .execution_id, tool, success, duration_ms}]}'

echo ""
echo "7️⃣  Ollama Integration - Quick Generation"
echo "────────────────────────────────────────"
curl -sS -X POST $BASE_URL/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool": "ollama_generate", "arguments": {"prompt": "Hi in 2 words", "max_tokens": 10}}' | jq '{execution_id, tool, success, result: .result[:60], duration_ms}'

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         All Function Call Tests Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
