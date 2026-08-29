"""Kitty Boss Kitten: Dynamic Zero-Hardcoding Font Size Persistence.

Executes in-process (no_ui=True), updates device_font.conf, and reloads config.
"""

import importlib
import os
import sys
from typing import List

# Ensure config directory is in sys.path
kitty_config_dir = os.path.expanduser("~/.config/kitty")
if kitty_config_dir not in sys.path:
    sys.path.insert(0, kitty_config_dir)

# pylint: disable=wrong-import-position
import font_size
import kitty_path

importlib.reload(font_size)
importlib.reload(kitty_path)

from font_size import (
    get_profile_font_offset,
    read_device_font_size,
    save_device_font_size,
)
from kitty_path import preferences_get_kitty_conf_path

# Optional imports when running outside of Kitty binary
try:
    from kittens.tui.handler import result_handler
    from kitty.boss import Boss
except ImportError:
    def result_handler(**kwargs):  # pylint: disable=unused-argument
        def decorator(f):
            return f
        return decorator
    Boss = object  # type: ignore


def main(args: List[str]) -> None:  # pylint: disable=unused-argument
    """CLI entrypoint for kitten."""


@result_handler(no_ui=True)
def handle_result(  # pylint: disable=unused-argument
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    """Handle kitten shortcut action."""
    # Action parameter from shortcut (e.g. "+1.0", "-1.0", "reset")
    action = args[1] if len(args) > 1 else "+1.0"

    current_base = read_device_font_size(default=20.0)

    if action == "reset":
        new_base = 20.0
    elif action.startswith("+"):
        try:
            delta = float(action[1:])
        except ValueError:
            delta = 1.0
        new_base = current_base + delta
    elif action.startswith("-"):
        try:
            delta = float(action[1:])
        except ValueError:
            delta = 1.0
        new_base = max(6.0, current_base - delta)
    else:
        try:
            new_base = float(action)
        except ValueError:
            return

    new_base = round(new_base, 1)
    save_device_font_size(new_base)

    # Reload configuration so Kitty applies the new device_font.conf
    boss.load_config_file(str(preferences_get_kitty_conf_path()))

    # If currently in a profile with custom offset (e.g. vim), re-apply offset
    active_profile = getattr(boss, "_current_profile", "default")
    offset = get_profile_font_offset(active_profile)
    if offset > 0:
        boss.change_font_size(False, "+", offset)
    elif offset < 0:
        boss.change_font_size(False, "-", abs(offset))
