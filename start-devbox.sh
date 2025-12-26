#!/bin/bash

# Script to install devbox (if not already installed) and start devbox shell for this repository

set -e

# Function to check if devbox is installed
check_devbox() {
    if command -v devbox &> /dev/null; then
        echo "Devbox is already installed."
        return 0
    else
        echo "Devbox is not installed. Installing..."
        return 1
    fi
}

# Function to install devbox
install_devbox() {
    # For macOS, use the official installation script
    curl -fsSL https://get.jetify.com/devbox | bash
    # Add devbox to PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
    echo "Devbox installed successfully."
}

# Function to start devbox shell
start_devbox() {
    local repo_dir="/Users/nirg/repositories/Kagent"
    cd "$repo_dir"
    echo "Starting devbox shell in $repo_dir..."
    exec devbox shell
}

# Main script
echo "Setting up devbox for the Kagent repository..."

if ! check_devbox; then
    install_devbox
fi

start_devbox