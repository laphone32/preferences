import os
from typing import Any, Dict

from kitty.boss import Boss
from kitty.window import Window


### Preferences variables ###
preferences_dir = ""
kitty_config = ""
### end of Preferences variables ###


def _cmd_to_profile(cmd_str: str) -> str:
    if len(cmd_str) > 0:
        cmd = cmd_str.split()
        match cmd[0]:
            case "vim":
                return "vim"
            case "ssh":
                for arg in cmd[1:]:
                    if arg.startswith("prod."):
                        return "prod"
                    elif arg.startswith("uat."):
                        return "uat"
                    elif arg.startswith("docker.") or arg.startswith("container."):
                        return "container"
                else:
                    return "remote"

    return "default"


def _force_symlink(src: str, dst: str) -> bool:
    current_dst = os.readlink(dst)
    if src != current_dst:
        os.remove(dst)
        os.symlink(src, dst)
        return True

    return False


def _path(prefix: str, profile: str) -> str:
    return f"{prefix}/{profile}.conf"


def _valid_path(prefix: str, profile: str = "default") -> str:
    ret = _path(prefix, profile)
    return ret if os.path.isfile(ret) else _path(prefix, "default")


def _set_term(boss: Boss, profiles: dict[str, str]) -> None:
    reload = _force_symlink(
        profiles.get("font", _valid_path(f"{preferences_dir}/kitty/fonts")),
        f"{kitty_config}/fonts.conf",
    )
    reload |= _force_symlink(
        profiles.get("theme", _valid_path(f"{preferences_dir}/.workspace/kitty/color-theme")),
        f"{kitty_config}/theme.conf",
    )

    if reload:
        boss.load_config_file(f"{kitty_config}/kitty.conf")


window_profile: dict[int, dict[str, str]] = {}


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    # Here data will contain focused
    if data["focused"]:
        profiles = window_profile.get(window.id, {})
        _set_term(boss, profiles)


def on_cmd_startstop(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    # called when the shell starts/stops executing a command. Here
    # data will contain is_start, cmdline and time.
    profile = (
        _cmd_to_profile(data["cmdline"])
        if data["is_start"]
        else "default"
    )

    profiles = {
        "theme": _valid_path(
            f"{preferences_dir}/.workspace/kitty/color-theme", profile
        ),
        "font": _valid_path(f"{preferences_dir}/kitty/fonts", profile),
    }
    window_profile[window.id] = profiles
    _set_term(boss, profiles)
