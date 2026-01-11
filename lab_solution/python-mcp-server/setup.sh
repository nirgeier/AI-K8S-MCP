#!/bin/bash

set -e

# ============================================================
# Configuration
# ============================================================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VENV_DIR=".venv"
readonly SERVER_PID_FILE=".server.pid"
readonly INSPECTOR_PID_FILE=".inspector.pid"

# Ports configuration
readonly PORTS=(8888 8889 6274 6277)
readonly SERVER_PORT=8889
readonly INSPECTOR_PORT=6274
readonly INSPECTOR_MCP_PORT=8889

# Server scripts
readonly MCP_SERVERS=("mcp02.py")

# Timeouts
readonly SERVER_STARTUP_WAIT=5
readonly PROCESS_CHECK_WAIT=1

# ============================================================
# Helper Functions
# ============================================================
log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_success() {
    echo "[✓] $*"
}

print_banner() {
    cat <<EOF
====================================================
= MCP Basics Demo                                  =
= Inspector: http://localhost:${INSPECTOR_PORT}                    =
====================================================
EOF
}

cleanup_ports() {
    log_info "Cleaning up existing processes on ports: ${PORTS[*]}"
    for port in "${PORTS[@]}"; do
        lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null || true
    done
}

check_dependency() {
    local cmd=$1
    local install_hint=$2

    if ! command -v "$cmd" &>/dev/null; then
        log_error "$cmd is not installed."
        log_error "Install it with: $install_hint"
        exit 1
    fi
}

setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        log_info "Creating virtual environment..."
        uv venv
        log_success "Virtual environment created"
    else
        log_info "Virtual environment already exists"
    fi

    source "$VENV_DIR/bin/activate"
}

install_dependencies() {
    if [ -f "requirements.txt" ]; then
        log_info "Installing dependencies from requirements.txt..."
        uv pip install -r requirements.txt
    else
        log_info "Installing default dependencies..."
        uv pip install mcp uvicorn
    fi
    log_success "Dependencies installed"
}

wait_for_port() {
    local port=$1
    local max_attempts=15
    local attempt=1

    log_info "Waiting for port $port to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if lsof -ti:$port >/dev/null 2>&1; then
            log_success "Port $port is ready"
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done

    log_error "Port $port failed to become ready after $max_attempts seconds"
    return 1
}

start_servers() {
    log_info "Starting MCP servers..."
    for server in "${MCP_SERVERS[@]}"; do
        if [ -f "$server" ]; then
            log_info "Launching $server..."
            uv run "$server" &
        else
            log_error "Server file not found: $server"
        fi
    done

    local server_pid=$!
    echo "$server_pid" >"$SERVER_PID_FILE"

    log_info "Waiting for servers to initialize..."
    sleep "$SERVER_STARTUP_WAIT"

    # Verify the server is actually listening
    if ! wait_for_port "$SERVER_PORT"; then
        log_error "Server failed to start on port $SERVER_PORT"
        exit 1
    fi
}

test_server() {
    local endpoint=$1
    local description=$2

    echo ""
    log_info "Testing: $description (http://localhost:${SERVER_PORT}${endpoint})"

    local response
    local exit_code

    response=$(curl -sS "http://localhost:${SERVER_PORT}${endpoint}" 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        if echo "$response" | jq . >/dev/null 2>&1; then
            echo "$response" | jq -C .
            log_success "$description OK"
        else
            echo "$response"
            log_success "$description OK (non-JSON)"
        fi
    else
        log_error "$description failed (connection error)"
        echo "Response: $response"
        return 1
    fi
}

start_inspector() {
    log_info "Starting MCP Inspector..."
    DANGEROUSLY_OMIT_AUTH=true npx @modelcontextprotocol/inspector \
        "http://localhost:${INSPECTOR_MCP_PORT}/mcp" &

    local inspector_pid=$!
    echo "$inspector_pid" >"$INSPECTOR_PID_FILE"

    sleep "$PROCESS_CHECK_WAIT"
}

verify_processes() {
    local server_pid
    local inspector_pid

    [ -f "$SERVER_PID_FILE" ] && server_pid=$(cat "$SERVER_PID_FILE")
    [ -f "$INSPECTOR_PID_FILE" ] && inspector_pid=$(cat "$INSPECTOR_PID_FILE")

    if [ -n "$server_pid" ] && ps -p "$server_pid" >/dev/null 2>&1; then
        log_success "MCP Server running (PID: $server_pid)"
    else
        log_error "MCP Server failed to start"
    fi

    if [ -n "$inspector_pid" ] && ps -p "$inspector_pid" >/dev/null 2>&1; then
        log_success "MCP Inspector running (PID: $inspector_pid)"
    else
        log_error "MCP Inspector failed to start"
    fi
}

print_usage() {
    cat <<EOF

To stop the services:
  kill \$(cat $SERVER_PID_FILE) 2>/dev/null || true
  kill \$(cat $INSPECTOR_PID_FILE) 2>/dev/null || true

Or run:
  lsof -ti:$(
        IFS=,
        echo "${PORTS[*]}"
    ) | xargs kill -9 2>/dev/null

EOF
}

# ============================================================
# Main Execution
# ============================================================
main() {
    cd "$SCRIPT_DIR"

    log_info "Initializing MCP Basics Demo"
    log_info "Working directory: $SCRIPT_DIR"

    # Prerequisites
    check_dependency "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
    check_dependency "jq" "brew install jq"

    # Setup
    cleanup_ports
    setup_venv
    install_dependencies

    # Start services
    start_servers

    # Test endpoints
    test_server "/health" "Health check" || log_error "Health check failed but continuing..."
    test_server "/metadata" "Server metadata" || log_error "Metadata endpoint failed but continuing..."
    test_server "/ollama/status" "Ollama connection" || log_error "Ollama endpoint failed but continuing..."
    test_server "/tools" "Tools endpoint" || log_error "Tools endpoint failed but continuing..."
    test_server "/prompts" "Prompts endpoint" || log_error "Prompts endpoint failed but continuing..."
    test_server "/resources" "Resources endpoint" || log_error "Resources endpoint failed but continuing..."
    test_server "/roots" "Roots endpoint" || log_error "Roots endpoint failed but continuing..."
    test_server "/ping" "Ping endpoint" || log_error "Ping endpoint failed but continuing..."
    test_server "/negotiate" "Negotiate endpoint" || log_error "Negotiate endpoint failed but continuing..."

    # Extra wait to ensure server is fully stable before starting inspector
    log_info "Ensuring server is fully stable..."
    sleep 2

    # Start inspector
    start_inspector

    # Verify and report
    verify_processes
    print_banner
    print_usage

    log_success "Setup complete!"
}

main "$@"