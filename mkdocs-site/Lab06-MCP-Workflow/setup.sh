#!/bin/bash

# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Run the python script to set up MCP structure
python mcp_structure.py

echo "Setup complete. Virtual environment created and dependencies installed."
