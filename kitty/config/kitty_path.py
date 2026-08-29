"""Kitty-specific path resolution utilities.

Builds on centralized python util.path library.
"""

import os
from pathlib import Path
import sys

# Ensure preferences root and workspace share/python are in sys.path
_pref_env = os.environ.get("PREFERENCES_DIR")
_pref_dir = (
    Path(_pref_env).resolve()
    if _pref_env
    else Path(__file__).resolve().parents[2]
)
_pref_ws = Path(
    os.environ.get("PREFERENCES_WORKSPACE", _pref_dir / ".workspace")
)
_pref_python_share = _pref_ws / "share" / "python"

for _p in (_pref_python_share, _pref_dir):
    if str(_p) not in sys.path:
        sys.path.insert(0, str(_p))

from util.path import (  # pylint: disable=wrong-import-position
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
