#!/usr/bin/env bash

# File: agent/common.sh

export PREFERENCES_AGENT="$PREFERENCES_DIR/agent"
export PREFERENCES_AGENT_CLI_DIR="$PREFERENCES_AGENT/cli"
export PREFERENCES_AGENT_MCP_DIR="$PREFERENCES_AGENT/mcp"
export PREFERENCES_AGENT_SKILLS="$PREFERENCES_AGENT/skills"

sourceShare bash utils.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/utils.sh" 2>/dev/null || true

export PREFERENCES_WORKSPACE_AGENT="$(command -v workspace &>/dev/null && workspace agent || echo "${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}/agent")"
export PREFERENCES_AGENT_RUN_DIR="$PREFERENCES_WORKSPACE_AGENT/mcp"

# CLI specific settings
export PREFERENCES_AGY_SBX_KIT="$PREFERENCES_AGENT_CLI_DIR/agy/sbx-kit"

export PREFERENCES_AGENT_CONV_DIR="$PREFERENCES_WORKSPACE_AGENT/sbx/conversation"

function get_agent_guest_conversation_dir() {
    local agent_name="$1"
    case "$agent_name" in
        agy)
            echo "/home/agent/.gemini/antigravity-cli/brain"
            ;;
        claude)
            echo "/home/agent/.claude/projects"
            ;;
        *)
            echo "/home/agent/.${agent_name}/conversations"
            ;;
    esac
}

function get_agent_host_conversation_dir() {
    local sandbox_name="$1"
    echo "$PREFERENCES_AGENT_CONV_DIR/$sandbox_name"
}

