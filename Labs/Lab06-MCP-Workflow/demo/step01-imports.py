#!/usr/bin/env python3
"""
Complete MCP (Model Context Protocol) Server Implementation
Built step by step for learning purposes.
Step 1: Imports
"""

import asyncio
import json
from typing import Any, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Tool,
    Resource,
    Prompt,
    TextContent,
    ImageContent,
    EmbeddedResource,
)
import sys

