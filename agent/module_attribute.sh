#!/usr/bin/env bash
# File: agent/module_attribute.sh

function module_get_name() {
    echo "agent"
}

function module_get_packages() {
    echo "sbx"
}

function module_get_gui_packages() {
    echo "sbx"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/agent}"
    source "$PREFERENCES_DIR/agent/common.sh"

    # Link centralized skills for host CLI usage
    local skills_dir="$modDir/skills"
    if [ -d "$skills_dir" ]; then
        mkdir -p "$HOME/.gemini/config"
        ln -sfn "$skills_dir" "$HOME/.gemini/config/skills"
        mkdir -p "$HOME/.agents"
        ln -sfn "$skills_dir" "$HOME/.agents/skills"
    fi

    local cache_dir="${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}/agent"
    local cache_file="$cache_dir/mcp_servers.list"
    local registered_servers=()

    # Register skills & MCP servers in Docker Sandboxes (sbx)
    if command -v sbx &>/dev/null; then
        # Ensure daemon matches current sbx version if running, preventing interactive restart prompts
        if sbx daemon status 2>/dev/null | grep -qi "running"; then
            sbx daemon restart </dev/null &>/dev/null || true
        fi

        echo "🧠 [agent:skills] Importing common skills into sbx..."
        sbx skills import --force </dev/null &>/dev/null || true
        sbx settings set skills.defaultMode readonly </dev/null &>/dev/null || true

        local mcp_base="$modDir/mcp"
        if [ -d "$mcp_base" ]; then
            for srv_dir in "$mcp_base"/*; do
                [ -d "$srv_dir" ] || continue
                local srv_name="$(basename "$srv_dir")"
                local pvenv_dir="$srv_dir/.pvenv"

                # Ensure virtualenv exists with dependencies
                if [ ! -d "$pvenv_dir" ] && [ -f "$srv_dir/requirements.txt" ]; then
                    echo "📦 [agent:mcp] Initializing virtual environment for $srv_name..."
                    python3 -m venv "$pvenv_dir"
                    "$pvenv_dir/bin/pip" install --quiet --upgrade -r "$srv_dir/requirements.txt"
                fi

                local py_bin=""
                if [ -x "$pvenv_dir/bin/python3" ]; then
                    py_bin="$pvenv_dir/bin/python3"
                elif [ -x "$pvenv_dir/bin/python" ]; then
                    py_bin="$pvenv_dir/bin/python"
                else
                    py_bin="$(command -v python3 || command -v python || true)"
                fi

                if [ -n "$py_bin" ] && [ -f "$srv_dir/server.py" ]; then
                    echo "🔌 [agent:mcp] Registering MCP server '$srv_name' in sbx..."
                    sbx mcp rm --force "$srv_name" </dev/null &>/dev/null || true
                    sbx mcp add "$srv_name" \
                        --command "$py_bin" \
                        --args "$srv_dir/server.py" </dev/null &>/dev/null || true
                    registered_servers+=("$srv_name")
                elif [ -f "$srv_dir/run.sh" ]; then
                    echo "🔌 [agent:mcp] Registering MCP server '$srv_name' in sbx..."
                    sbx mcp rm --force "$srv_name" </dev/null &>/dev/null || true
                    sbx mcp add "$srv_name" \
                        --command "bash" \
                        --args "$srv_dir/run.sh" </dev/null &>/dev/null || true
                    registered_servers+=("$srv_name")
                fi
            done
        fi
    fi

    # Generate cache file for fast agent startup
    mkdir -p "$cache_dir"
    if [ ${#registered_servers[@]} -gt 0 ]; then
        printf "%s\n" "${registered_servers[@]}" > "$cache_file"
    else
        : > "$cache_file"
    fi
}
