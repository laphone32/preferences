"""
Kitty dynamic watcher script for font and color theme management.
Uses real-time dynamic path resolution via kitty_path.
"""

import os
import sys
from pathlib import Path
from typing import Any, Dict

# Ensure config dir is in sys.path
_kitty_config = os.path.expanduser("~/.config/kitty")
if _kitty_config not in sys.path:
    sys.path.insert(0, _kitty_config)

from kitty_path import (  # pylint: disable=wrong-import-position
    preferences_get_active_theme_conf_path,
    preferences_get_kitty_conf_path,
    preferences_get_kitty_theme_dir,
)
from font_size import get_profile_font_offset  # pylint: disable=wrong-import-position
from term.compile.title import parse_cmd  # pylint: disable=wrong-import-position
from kitty.boss import Boss
from kitty.window import Window


def _force_symlink(src: str, dst: str) -> bool:
    try:
        current_dst = os.readlink(dst)
        if src != current_dst:
            os.remove(dst)
            os.symlink(src, dst)
            return True
    except OSError:
        if os.path.exists(dst):
            os.remove(dst)
        os.symlink(src, dst)
        return True

    return False


def _path(prefix: str, profile: str) -> str:
    return f"{prefix}/{profile}.conf"


def _valid_path(prefix: str, profile: str) -> str:
    ret = _path(prefix, profile)
    return ret if os.path.isfile(ret) else _path(prefix, "default")


class Default:
    profile = "default"


def _update_profile(boss: Boss, profile: str) -> None:
    theme_path = _valid_path(
        str(preferences_get_kitty_theme_dir()), profile
    )
    if _force_symlink(theme_path, str(preferences_get_active_theme_conf_path())):
        boss._current_profile = profile
        boss.load_config_file(str(preferences_get_kitty_conf_path()))
        offset = get_profile_font_offset(profile)
        if offset > 0:
            boss.change_font_size(False, "+", offset)
        elif offset < 0:
            boss.change_font_size(False, "-", abs(offset))


window_profile: dict[int, str] = {}


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    if not window or not data or not data.get("focused"):
        return

    profile = window_profile.get(window.id, Default.profile)
    _update_profile(boss, profile)


def on_cmd_startstop(
    boss: Boss, window: Window, data: Dict[str, Any]
) -> None:
    if not window or not data:
        return

    cmdline = data.get("cmdline", "")
    if data.get("is_start"):
        profile, _ = parse_cmd(cmdline)
    else:
        profile = Default.profile
    window_profile[window.id] = profile
    _update_profile(boss, profile)
