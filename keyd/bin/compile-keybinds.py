#!/usr/bin/env python3
"""
Compiles keybinds.json into keyd configuration files.
Parses human-readable keybindings and generates default.conf and app.conf.
"""

import json
import os
import sys


def translate_layer(trigger_str):
    """
    Translate a trigger string to a keyd layer and key for global mappings.

    Args:
        trigger_str: The human-readable trigger string (e.g., 'Super + C').

    Returns:
        A tuple of (layer_name, key).
    """
    parts = [p.strip().lower() for p in trigger_str.split("+")]
    mod_map = {
        "ctrl": "control",
        "shift": "shift",
        "alt": "alt",
        "super": "meta",
    }

    mods = [mod_map[p] for p in parts[:-1] if p in mod_map]
    key = parts[-1]

    layer_name = "-".join(mods)
    return layer_name, key


def translate_app_layer(trigger_str):
    """
    Translate a trigger string to a keyd layer binding format for app.conf.

    Args:
        trigger_str: The human-readable trigger string (e.g., 'Super + C').

    Returns:
        The formatted keyd LHS binding string (e.g., 'meta.c').
    """
    parts = [p.strip().lower() for p in trigger_str.split("+")]
    mod_map = {"ctrl": "C", "shift": "S", "alt": "A", "super": "meta"}

    mods = [mod_map[p] for p in parts[:-1] if p in mod_map]
    key = parts[-1]

    if mods:
        return "-".join(mods) + "." + key
    return key


def translate_action(action_str):
    """
    Translate a human-readable action string to a keyd RHS action string.

    Args:
        action_str: The human-readable action string (e.g., 'Ctrl + Shift + C').

    Returns:
        The formatted keyd RHS string (e.g., 'C-S-c').
    """
    parts = [p.strip().lower() for p in action_str.split("+")]
    mod_map = {"ctrl": "C", "shift": "S", "alt": "A", "super": "M"}

    mods = [mod_map[p] for p in parts[:-1] if p in mod_map]
    key = parts[-1]

    if mods:
        return "-".join(mods) + "-" + key
    return key


def main():
    """Main execution function for the compiler."""
    if len(sys.argv) < 2:
        print("Usage: compile-keybinds.py <keybinds.json>")
        sys.exit(1)

    json_path = sys.argv[1]

    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError) as error:
        print(f"ERROR: Failed to parse JSON: {error}")
        sys.exit(1)

    workspace_dir = os.environ.get(
        "PREFERENCES_WORKSPACE_KEYD",
        os.path.expanduser("~/personal/preferences/.workspace/keyd"),
    )
    os.makedirs(workspace_dir, exist_ok=True)

    default_conf_path = os.path.join(workspace_dir, "default.conf")
    app_conf_path = os.path.join(workspace_dir, "app.conf")

    default_layers = {}
    apps_dict = {}

    for trigger, cfg in data.items():
        # default.conf (global)
        if "global" in cfg:
            layer, key = translate_layer(trigger)
            action = translate_action(cfg["global"])
            if layer not in default_layers:
                default_layers[layer] = []
            default_layers[layer].append(f"{key} = {action}")

        # app.conf
        if "apps" in cfg:
            app_lhs = translate_app_layer(trigger)
            for app_name, app_action_str in cfg["apps"].items():
                action = translate_action(app_action_str)
                if app_name not in apps_dict:
                    apps_dict[app_name] = []
                apps_dict[app_name].append(f"{app_lhs} = {action}")

    # Write default.conf
    default_lines = [
        "# AUTOMATICALLY GENERATED. DO NOT EDIT.",
        "[ids]",
        "*",
        "",
        "[main]",
        "",
    ]

    for layer, binds in default_layers.items():
        default_lines.append(f"[{layer}]")
        for bind in binds:
            default_lines.append(bind)
        default_lines.append("")

    with open(default_conf_path, "w", encoding="utf-8") as f:
        f.write("\n".join(default_lines))

    # Write app.conf
    app_lines = [
        "# AUTOMATICALLY GENERATED. DO NOT EDIT.",
        "",
    ]
    for app_name, binds in apps_dict.items():
        app_lines.append(f"[{app_name}]")
        for bind in binds:
            app_lines.append(bind)
        app_lines.append("")

    with open(app_conf_path, "w", encoding="utf-8") as f:
        f.write("\n".join(app_lines))

    print("SUCCESS: Keybinds compiled.")


if __name__ == "__main__":
    main()
