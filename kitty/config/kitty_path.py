"""
Kitty-specific path resolution utilities.
Builds on centralized python.util.path library.
"""

import os
import sys
from pathlib import Path

# Ensure preferences root and preferences/python are in sys.path when running inside Kitty process
_pref_env = os.environ.get("PREFERENCES_DIR")
_pref_dir = (
    Path(_pref_env).resolve()
    if _pref_env
    else Path(__file__).resolve().parents[2]
)
_pref_python = _pref_dir / "python"

for _p in (_pref_dir, _pref_python):
    if str(_p) not in sys.path:
        sys.path.insert(0, str(_p))

from util.path import (
    preferences_get_config_dir,
    preferences_get_dir,
    preferences_get_user_config_dir,
    preferences_get_workspace_dir,
)


def preferences_get_kitty_workspace_dir() -> Path:
    """Get the .workspace/kitty directory."""
    return preferences_get_workspace_dir("kitty")


def preferences_get_kitty_theme_dir() -> Path:
    """Get the .workspace/kitty/theme directory."""
    return preferences_get_kitty_workspace_dir() / "theme"


def preferences_get_kitty_local_config_dir() -> Path:
    """Get ~/.config/kitty directory."""
    env_dir = os.environ.get("PREFERENCES_KITTY_LOCAL")
    if env_dir:
        return Path(env_dir)
    return preferences_get_user_config_dir("kitty")


def preferences_get_kitty_conf_path() -> Path:
    """Get ~/.config/kitty/kitty.conf path."""
    return preferences_get_kitty_local_config_dir() / "kitty.conf"


def preferences_get_active_theme_conf_path() -> Path:
    """Get ~/.config/kitty/theme.conf path."""
    return preferences_get_kitty_local_config_dir() / "theme.conf"


def preferences_get_device_font_conf_path() -> Path:
    """Get .workspace/kitty/device_font.conf path."""
    return preferences_get_kitty_workspace_dir() / "device_font.conf"


def preferences_get_font_offsets_path() -> Path:
    """Get .workspace/kitty/font_offsets.json path."""
    return preferences_get_kitty_workspace_dir() / "font_offsets.json"
