"""
Centralized path resolution utilities for Preferences repository.
"""

import os
from pathlib import Path
from typing import Optional


def preferences_get_dir() -> Path:
    """Get the root directory of preferences repo."""
    env_dir = os.environ.get("PREFERENCES_DIR")
    if env_dir:
        return Path(env_dir).resolve()
    # Fallback: traverse up from this file (preferences/python/util/path.py -> preferences)
    return Path(__file__).resolve().parent.parent.parent


def preferences_get_workspace_dir(module: Optional[str] = None) -> Path:
    """Get the .workspace directory (or a module-specific workspace subdirectory)."""
    pref_dir = preferences_get_dir()
    ws_env = os.environ.get("PREFERENCES_WORKSPACE")
    base_ws = Path(ws_env) if ws_env else (pref_dir / ".workspace")
    return base_ws / module if module else base_ws


def preferences_get_config_dir(module: Optional[str] = None) -> Path:
    """Get module config directory (e.g. preferences/<module>/config)."""
    pref_dir = preferences_get_dir()
    return pref_dir / module / "config" if module else pref_dir


def preferences_get_user_config_dir(module: Optional[str] = None) -> Path:
    """Get ~/.config (or ~/.config/<module>)."""
    home_config = Path(
        os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")
    )
    return home_config / module if module else home_config
