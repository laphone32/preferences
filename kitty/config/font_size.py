"""Centralized font size utilities for Kitty.

Shared between watcher.py, adjust_font_size.py, and theme compilers.
"""

import json
from typing import Optional

from kitty_path import (
    preferences_get_device_font_conf_path,
    preferences_get_font_offsets_path,
)

_CACHED_OFFSETS: Optional[dict] = None


def load_font_offsets() -> dict:
    """Load relative delta offsets from workspace. Fallback to 0.0 delta."""
    global _CACHED_OFFSETS  # pylint: disable=global-statement
    if _CACHED_OFFSETS is not None:
        return _CACHED_OFFSETS

    offsets_file = preferences_get_font_offsets_path()
    if offsets_file.exists():
        try:
            with open(offsets_file, "r", encoding="utf-8") as f:
                _CACHED_OFFSETS = json.load(f)
                return _CACHED_OFFSETS
        except (OSError, json.JSONDecodeError):
            pass

    return {"default": 0.0}


def get_profile_font_offset(profile: str) -> float:
    """Get font size offset relative to default profile for a given profile."""
    return load_font_offsets().get(profile, 0.0)


def read_device_font_size(default: float = 20.0) -> float:
    """Read current base font size from device_font.conf."""
    conf_path = preferences_get_device_font_conf_path()
    if conf_path.exists():
        try:
            with open(conf_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("font_size"):
                        parts = line.split()
                        if len(parts) >= 2:
                            return float(parts[1])
        except (OSError, ValueError):
            pass
    return default


def save_device_font_size(base_size: float) -> None:
    """Saves the base font size to device_font.conf."""
    conf_path = preferences_get_device_font_conf_path()
    conf_path.parent.mkdir(parents=True, exist_ok=True)

    with open(conf_path, "w", encoding="utf-8") as f:
        f.write(f"font_size {base_size:.1f}\n")
