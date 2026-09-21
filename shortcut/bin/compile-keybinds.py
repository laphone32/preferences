#!/usr/bin/env python3
# pylint: disable=invalid-name
"""Compiles keybinds.json into desktop environment configurations.

Discovers and executes backend compiler plugins in shortcut/bin/de/*.py.
"""

import argparse
import importlib.util
import json
import os
import sys


def discover_de_plugins(de_dir):
    """
    Discover all desktop environment plugins in de_dir.

    Returns:
        dict of {plugin_name: module}
    """
    plugins = {}
    if not os.path.isdir(de_dir):
        return plugins

    for filename in sorted(os.listdir(de_dir)):
        if filename.endswith(".py") and not filename.startswith("__"):
            plugin_name = os.path.splitext(filename)[0]
            plugin_path = os.path.join(de_dir, filename)

            spec = importlib.util.spec_from_file_location(plugin_name, plugin_path)
            if spec and spec.loader:
                module = importlib.util.module_from_spec(spec)
                sys.modules[f"shortcut.de.{plugin_name}"] = module
                spec.loader.exec_module(module)
                if hasattr(module, "compile") and callable(module.compile):
                    plugins[plugin_name] = module

    return plugins


def main():
    """Main execution function for the shortcut compiler."""
    script_dir = os.path.dirname(os.path.realpath(__file__))
    default_json = os.path.normpath(os.path.join(script_dir, "..", "keybinds.json"))

    parser = argparse.ArgumentParser(
        description="Compile keybinds.json into DE configurations via de/*.py plugins."
    )
    parser.add_argument(
        "json_path",
        nargs="?",
        default=default_json,
        help="Path to keybinds.json (default: ../keybinds.json)",
    )
    parser.add_argument(
        "--de",
        dest="target_de",
        help="Compile for a specific DE plugin (e.g. gnome, hyprland). Default: all",
    )
    args = parser.parse_args()

    json_path = args.json_path
    if not os.path.isfile(json_path):
        print(f"ERROR: Keybinds file not found: {json_path}")
        sys.exit(1)

    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError) as error:
        print(f"ERROR: Failed to parse JSON: {error}")
        sys.exit(1)

    workspace_dir = os.environ.get(
        "PREFERENCES_WORKSPACE_SHORTCUT",
        os.environ.get(
            "PREFERENCES_WORKSPACE_KEYD",
            os.path.expanduser("~/personal/preferences/.workspace/shortcut"),
        ),
    )
    os.makedirs(workspace_dir, exist_ok=True)

    de_dir = os.path.join(script_dir, "de")
    plugins = discover_de_plugins(de_dir)

    if not plugins:
        print(f"WARNING: No DE plugins found in {de_dir}")
        sys.exit(0)

    print(f"Compiling shortcuts from {os.path.basename(json_path)} to {workspace_dir}...")

    executed = 0
    for name, plugin in plugins.items():
        if args.target_de and args.target_de.lower() != name.lower():
            continue
        print(f"Running DE plugin: {name}")
        try:
            plugin.compile(data, workspace_dir)
            executed += 1
        except Exception as err:
            print(f"ERROR running plugin {name}: {err}")
            sys.exit(1)

    if executed == 0 and args.target_de:
        print(f"ERROR: Target DE '{args.target_de}' not found among available plugins: {list(plugins.keys())}")
        sys.exit(1)

    print("SUCCESS: All shortcut configurations compiled.")


if __name__ == "__main__":
    main()
