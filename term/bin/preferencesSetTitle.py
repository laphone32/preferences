#!/usr/bin/env python3
# pylint: disable=invalid-name
"""
Emit ANSI OSC 0 window title sequence to the terminal.
Shared across shell wrappers, Vim autocommands, and terminal managers.
"""

import os
import sys
from pathlib import Path

# Ensure repository root and workspace share/python are on sys.path
script_dir = Path(__file__).resolve().parent
repo_root = script_dir.parent.parent
pref_ws = Path(
    os.environ.get("PREFERENCES_WORKSPACE", repo_root / ".workspace")
)
ws_python = pref_ws / "share" / "python"

for p in (ws_python, repo_root):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from term.title import format_title  # pylint: disable=wrong-import-position


def set_title(profile: str, extra: str = "") -> None:
    """Format title and emit OSC 0 sequence to stdout, stderr, and /dev/tty."""
    title = format_title(profile, extra=extra)
    if not title:
        return

    osc_seq = f"\033]0;{title}\007"

    # Write to stdout
    sys.stdout.write(osc_seq)
    sys.stdout.flush()

    # Write to stderr (which passes uncaptured to terminal in system())
    sys.stderr.write(osc_seq)
    sys.stderr.flush()

    # Also write to /dev/tty if available
    try:
        with open("/dev/tty", "w", encoding="utf-8") as tty:
            tty.write(osc_seq)
            tty.flush()
    except (OSError, IOError):
        pass


def main():
    profile = sys.argv[1] if len(sys.argv) > 1 else "default"
    extra = sys.argv[2] if len(sys.argv) > 2 else ""

    set_title(profile=profile, extra=extra)


if __name__ == "__main__":
    main()
