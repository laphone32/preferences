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


def _font_path(profile: str) -> str:
    return f"{preferences_dir}/kitty/fonts/{profile}.conf"


def _color_path(profile: str) -> str:
    return f"{preferences_dir}/.workspace/kitty/color-theme/{profile}.conf"


def _set_term(boss: Boss, profile: str) -> None:
    reload = _force_symlink(
        _font_path(profile if os.path.isfile(_font_path(profile)) else "default"),
        f"{kitty_config}/fonts.conf",
    )
    reload |= _force_symlink(
        _color_path(profile if os.path.isfile(_color_path(profile)) else "default"),
        f"{kitty_config}/theme.conf",
    )

    if reload:
        boss.load_config_file(f"{kitty_config}/kitty.conf")


window_profile = {}


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    # Here data will contain focused
    if data["focused"]:
        profile = window_profile.get(window.id, "default")
        _set_term(boss, profile)


def on_cmd_startstop(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    # called when the shell starts/stops executing a command. Here
    # data will contain is_start, cmdline and time.
    profile = _cmd_to_profile(data["cmdline"]) if data["is_start"] else "default"

    window_profile[window.id] = profile
    _set_term(boss, profile)
