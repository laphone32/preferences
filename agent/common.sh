#!/usr/bin/env bash

# File: agent/common.sh

export PREFERENCES_AGENT="$PREFERENCES_DIR/agent"
export PREFERENCES_AGENT_CLI_DIR="$PREFERENCES_AGENT/cli"
export PREFERENCES_AGENT_MCP_DIR="$PREFERENCES_AGENT/mcp"

sourceShare bash utils.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/utils.sh" 2>/dev/null || true

export PREFERENCES_WORKSPACE_AGENT="$(command -v workspace &>/dev/null && workspace agent || echo "${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}/agent")"
export PREFERENCES_AGENT_RUN_DIR="$PREFERENCES_WORKSPACE_AGENT/mcp"

# CLI specific settings
export PREFERENCES_AGY_SBX_KIT="$PREFERENCES_AGENT_CLI_DIR/agy/sbx-kit"

# Backward compatibility mappings
export PREFERENCES_AGY_MCP_DIR="$PREFERENCES_AGENT_MCP_DIR"
export PREFERENCES_AGY_RUN_DIR="$PREFERENCES_AGENT_RUN_DIR"

