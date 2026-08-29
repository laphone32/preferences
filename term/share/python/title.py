#!/usr/bin/env python3
"""
Centralized title formatting and command parsing utilities for preferences.
Shared by terminal managers (e.g. Kitty watcher, term scripts).
"""

import os
import sys
from typing import Dict, Optional, Tuple

SHELL_NAMES = {"bash", "zsh", "sh", "fish", "dash", "csh", "tcsh"}

DEFAULT_PROFILE_TITLES: Dict[str, str] = {
    "default": "",
    "vim": "[Vim]",
    "sudo": "[SUDO]",
    "prod": "> PROD <",
    "uat": "> UAT <",
    "remote": "> REMOTE <",
    "container": "> Container <",
}


def format_cwd(cwd: Optional[str]) -> str:
    """Shorten a directory path by replacing the home directory with ~."""
    if not cwd:
        return ""
    home = os.path.expanduser("~")
    if cwd == home:
        return "~"
    if cwd.startswith(home + "/"):
        return "~" + cwd[len(home):]
    return cwd


def parse_cmd(cmd_str: str) -> Tuple[str, str]:
    """
    Parse a shell command string into (profile, extra_argument).

    Returns:
        (profile_name, extra_string)
    """
    if not cmd_str:
        return "default", ""

    parts = cmd_str.split()
    cmd = os.path.basename(parts[0])
    args = parts[1:]

    # 1. Vim
    if cmd in ("vim", "vimdiff", "nvim", "gvim", "vi"):
        return "vim", ""

    # 2. Sudo
    if cmd in ("sudo", "su"):
        return "sudo", " ".join(args)

    # 3. SSH
    if cmd == "ssh":
        for arg in args:
            if arg.startswith("-"):
                continue
            host = arg.split("@")[-1]
            if host.startswith("prod."):
                return "prod", arg
            if host.startswith("uat."):
                return "uat", arg
            if host.startswith("docker.") or host.startswith("container."):
                return "container", arg
        target = args[-1] if args else ""
        return "remote", target

    # 4. Other non-shell commands
    if cmd not in SHELL_NAMES:
        return "default", cmd_str

    # 5. Shell prompt
    return "default", ""


def format_title(
    profile: str,
    extra: str = "",
    titles_map: Optional[Dict[str, str]] = None,
) -> str:
    """
    Format the window title based on profile and extra info.
    If extra is a path, it will be formatted relative to home (~).
    """
    titles = DEFAULT_PROFILE_TITLES if titles_map is None else titles_map
    base = titles.get(profile, f"[{profile.upper()}]" if profile else "")

    if extra:
        if extra.startswith("/") or extra.startswith("~"):
            extra = format_cwd(extra)
        return f"{base} {extra}".strip() if base else extra

    if profile == "vim":
        return base

    cwd_str = format_cwd(os.getcwd())
    if base and cwd_str:
        return f"{base} {cwd_str}"
    return cwd_str or base


def main():
    """CLI entrypoint for shell callers like term/util.sh."""
    profile = sys.argv[1] if len(sys.argv) > 1 else "default"
    extra = sys.argv[2] if len(sys.argv) > 2 else ""

    title = format_title(profile=profile, extra=extra)
    if title:
        print(title)


if __name__ == "__main__":
    main()
