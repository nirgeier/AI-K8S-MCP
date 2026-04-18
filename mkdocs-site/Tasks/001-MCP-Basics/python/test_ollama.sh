#!/bin/bash
echo "========================================="
echo "Testing Ollama Integration with MCP"
echo "========================================="
echo ""
echo "1. Ollama Status:"
curl -sS http://localhost:8889/ollama/status | jq '.status, .models_count, .default_model'
echo ""
echo "2. Available Ollama Tools:"
curl -sS http://localhost:8889/tools | jq '.tools[] | select(.name | startswith("ollama")) | .name'
