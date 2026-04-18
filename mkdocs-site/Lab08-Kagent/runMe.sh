#!/bin/bash

# Function to start Ollama
start_ollama() {
  if pgrep -f "ollama serve" >/dev/null 2>&1; then
    echo "✅ Ollama is already running"
  else
    echo "🚀 Starting Ollama..."
    ollama serve >/tmp/ollama.log 2>&1 &
    sleep 2
    if pgrep -f "ollama serve" >/dev/null 2>&1; then
      echo "✅ Ollama started successfully"
    else
      echo "❌ Failed to start Ollama. Check /tmp/ollama.log for details"
      return 1
    fi
  fi
}

# Function to stop Ollama
stop_ollama() {
  if pgrep -f "ollama serve" >/dev/null 2>&1; then
    echo "🛑 Stopping Ollama..."
    pkill -f "ollama serve"
    sleep 1
    if ! pgrep -f "ollama serve" >/dev/null 2>&1; then
      echo "✅ Ollama stopped successfully"
    else
      echo "⚠️  Ollama may still be running"
    fi
  else
    echo "ℹ️  Ollama is not running"
  fi
}

# Function to start LiteLLM
start_litellm() {
  local model=$1
  local api_key=$2

  if pgrep -f "litellm --model" >/dev/null 2>&1; then
    echo "✅ LiteLLM is already running"
    return 0
  fi

  echo "🚀 Starting LiteLLM proxy server..."
  export LITELLM_MASTER_KEY="$api_key"

  # Check Python version - uvloop has compatibility issues with Python 3.14+
  PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
  PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
  PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

  if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 14 ]; then
    echo "⚠️  Warning: Python $PYTHON_VERSION detected"
    echo "ℹ️  LiteLLM may have compatibility issues with Python 3.14+"
    echo "ℹ️  Attempting to start with asyncio loop..."
  fi

  # Try to start litellm
  litellm --model "ollama/$model" --port 4000 --drop_params >/tmp/litellm.log 2>&1 &
  LITELLM_PID=$!
  sleep 4

  # Check if it's actually running
  if kill -0 $LITELLM_PID 2>/dev/null && pgrep -f "litellm --model" >/dev/null 2>&1; then
    echo "✅ LiteLLM started successfully on http://localhost:4000"
    return 0
  else
    echo "❌ Failed to start LiteLLM"
    echo "ℹ️  Check /tmp/litellm.log for details"
    echo ""
    echo "📝 Manual start command:"
    echo "   export LITELLM_MASTER_KEY=$api_key"
    echo "   litellm --model ollama/$model --port 4000"
    return 1
  fi
}

# Function to stop LiteLLM
stop_litellm() {
  if pgrep -f "litellm --model" >/dev/null 2>&1; then
    echo "🛑 Stopping LiteLLM..."
    pkill -f "litellm --model"
    sleep 1
    if ! pgrep -f "litellm --model" >/dev/null 2>&1; then
      echo "✅ LiteLLM stopped successfully"
    else
      echo "⚠️  LiteLLM may still be running"
    fi
  else
    echo "ℹ️  LiteLLM is not running"
  fi
}

# Start Ollama before running the main script
start_ollama

# List available models and select the first one
echo "--------------------------------------"
echo "📋 Fetching available Ollama models..."
echo "--------------------------------------"

# Get the first model from ollama list (skip header line)
SELECTED_MODEL=$(ollama list | tail -n +2 | head -n 1 | awk '{print $1}')

if [ -z "$SELECTED_MODEL" ]; then
  echo "❌ No Ollama models found. Please pull a model first:"
  echo "   ollama pull llama3"
  exit 1
fi

echo "✅ Selected model: $SELECTED_MODEL"
echo "--------------------------------------"
echo ""

# Generate a 32-character secure hex string
# We try openssl first, then fallback to /dev/urandom if needed
if command -v openssl >/dev/null 2>&1; then
  KEY_SUFFIX=$(openssl rand -hex 16)
else
  KEY_SUFFIX=$(head -c 16 /dev/urandom | xxd -p | tr -d ' \n')
fi

API_KEY="sk-ollama-$KEY_SUFFIX"

echo "--------------------------------------"
echo "🔑 OLLAMA PROXY KEY GENERATED"
echo "--------------------------------------"
echo "Your API Key: $API_KEY"
echo ""

# Save to .env file
echo "LITELLM_MASTER_KEY=$API_KEY" >.env
echo "✅ Key saved to .env"
echo "--------------------------------------"
echo ""

# Start LiteLLM proxy server
LITELLM_STARTED=false
if start_litellm "$SELECTED_MODEL" "$API_KEY"; then
  LITELLM_STARTED=true
fi

echo ""

if [ "$LITELLM_STARTED" = true ]; then
  echo "--------------------------------------"
  echo "🧪 Testing the LiteLLM proxy..."
  echo "--------------------------------------"

  # Wait a moment for the server to be fully ready
  sleep 5

  # Test the proxy with a simple request
  curl --location 'http://localhost:4000/v1/chat/completions' \
    --header "Authorization: Bearer $API_KEY" \
    --header 'Content-Type: application/json' \
    --data '{
    "model": "ollama/'$SELECTED_MODEL'",
    "messages": [{"role": "user", "content": "Say hello!"}]
  }'

  echo ""
  echo ""
  echo "--------------------------------------"
  echo "✅ All services are running!"
  echo "--------------------------------------"
  echo "Ollama: Running"
  echo "LiteLLM: http://localhost:4000"
  echo "API Key: $API_KEY"
  echo "Model: ollama/$SELECTED_MODEL"
  echo ""
  echo "To stop services, run:"
  echo "  source ./runMe.sh && stop_litellm && stop_ollama"
  echo "--------------------------------------"
else
  echo "--------------------------------------"
  echo "⚠️  Services Status"
  echo "--------------------------------------"
  echo "Ollama: ✅ Running"
  echo "LiteLLM: ❌ Failed to start"
  echo ""
  echo "You can start LiteLLM manually:"
  echo "  export LITELLM_MASTER_KEY=$API_KEY"
  echo "  litellm --model ollama/$SELECTED_MODEL --port 4000"
  echo "--------------------------------------"
fi
