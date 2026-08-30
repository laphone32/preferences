#!/usr/bin/env python3
"""
Preferences Netlink Network Change Hook Runner
Listens for kernel network state transitions and dispatches workspace hooks.
"""
import glob
import os
import select
import socket
import struct
import subprocess
import sys
import time

RTMGRP_LINK = 0x1
RTMGRP_IPV4_IFADDR = 0x10
RTMGRP_IPV4_ROUTE = 0x40
RTMGRP_IPV6_IFADDR = 0x100
RTMGRP_IPV6_ROUTE = 0x400

RTM_NEWLINK = 16
RTM_NEWADDR = 20
RTM_NEWROUTE = 24

DEBOUNCE_SECONDS = 2.5
MIN_INTERVAL_SECONDS = 20.0

def get_workspace_dir():
    pref_dir = os.environ.get("PREFERENCES_DIR", os.path.expanduser("~/personal/preferences"))
    return os.environ.get("PREFERENCES_WORKSPACE", os.path.join(pref_dir, ".workspace"))

def get_log_file():
    ws = get_workspace_dir()
    network_ws = os.path.join(ws, "network")
    os.makedirs(network_ws, exist_ok=True)
    return os.path.join(network_ws, "network.log")

def log(msg):
    log_file = get_log_file()
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    entry = f"[{timestamp}] {msg}\n"
    sys.stdout.write(entry)
    sys.stdout.flush()
    try:
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(entry)
    except OSError as e:
        sys.stderr.write(f"Failed to write log: {e}\n")

def get_module_name(hook_path, ws_dir):
    try:
        rel_dir = os.path.relpath(os.path.dirname(hook_path), ws_dir)
        parts = rel_dir.split(os.sep)
        return parts[0] if parts else "unknown"
    except (ValueError, OSError):
        return "unknown"

def run_hooks():
    ws = get_workspace_dir()
    pattern = os.path.join(ws, "*", "network-hooks.d", "*.sh")
    hooks = sorted(glob.glob(pattern))

    log(f"▶ Dispatched network hooks (Found: {len(hooks)})")
    for hook in hooks:
        if os.path.islink(hook) and not os.path.exists(hook):
            log(f"🧹 Removing stale hook symlink: {os.path.basename(hook)}")
            try:
                os.unlink(hook)
            except OSError as e:
                log(f"  ⚠ Failed to remove stale symlink {hook}: {e}")
            continue

        hook_name = os.path.basename(hook)
        mod_name = get_module_name(hook, ws)
        log(f"  ▶ Executing [{mod_name}:{hook_name}]")

        try:
            res = subprocess.run(
                ["/usr/bin/env", "bash", hook],
                cwd=os.path.dirname(hook),
                capture_output=True,
                text=True,
                timeout=15,
                check=False
            )
            if res.returncode == 0:
                log(f"  🟢 Success [{mod_name}:{hook_name}] (Exit 0)")
                if res.stdout.strip():
                    for line in res.stdout.strip().splitlines():
                        log(f"     [stdout] {line}")
            else:
                log(f"  🔴 Failed [{mod_name}:{hook_name}] (Exit {res.returncode})")
                if res.stderr.strip():
                    for line in res.stderr.strip().splitlines():
                        log(f"     [stderr] {line}")
        except subprocess.TimeoutExpired:
            log(f"  ⚠ Timeout [{mod_name}:{hook_name}] after 15s")
        except (subprocess.SubprocessError, OSError) as e:
            log(f"  🔴 Error executing [{mod_name}:{hook_name}]: {e}")

EVENT_NAMES = {
    RTM_NEWLINK: "RTM_NEWLINK",
    RTM_NEWADDR: "RTM_NEWADDR",
    RTM_NEWROUTE: "RTM_NEWROUTE",
}

def main():
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, socket.NETLINK_ROUTE)
    groups = RTMGRP_LINK | RTMGRP_IPV4_IFADDR | RTMGRP_IPV4_ROUTE | RTMGRP_IPV6_IFADDR | RTMGRP_IPV6_ROUTE
    try:
        sock.bind((0, groups))
    except OSError as e:
        log(f"🔴 Fatal: Failed to bind Netlink socket: {e}")
        sys.exit(1)

    sock.setblocking(False)

    log("🌐 Preferences Netlink Network Watcher initialized.")
    # Initial startup run
    run_hooks()
    last_run_time = time.time()
    pending_trigger_time = None
    pending_event_types = set()

    while True:
        timeout = None
        if pending_trigger_time is not None:
            remaining = pending_trigger_time - time.time()
            timeout = max(0.0, remaining)

        try:
            readable, _, _ = select.select([sock], [], [], timeout)
        except (OSError, select.error):
            readable = []

        if readable:
            try:
                data = sock.recv(65535)
                offset = 0
                while offset + 16 <= len(data):
                    msg_len, msg_type, _, _, _ = struct.unpack_from("=IHHII", data, offset)
                    if msg_len < 16:
                        break
                    if msg_type in (RTM_NEWLINK, RTM_NEWADDR, RTM_NEWROUTE):
                        event_name = EVENT_NAMES.get(msg_type, f"RTM_MSG_{msg_type}")
                        pending_event_types.add(event_name)
                        pending_trigger_time = time.time() + DEBOUNCE_SECONDS
                    offset += (msg_len + 3) & ~3
            except (BlockingIOError, struct.error, OSError):
                pass

        if pending_trigger_time is not None and time.time() >= pending_trigger_time:
            pending_trigger_time = None
            events_desc = ", ".join(sorted(pending_event_types)) if pending_event_types else "UNKNOWN"
            pending_event_types.clear()

            now = time.time()
            if now - last_run_time >= MIN_INTERVAL_SECONDS:
                log(f"⚡ Network event settled [{events_desc}] (debounce passed).")
                run_hooks()
                last_run_time = time.time()
            else:
                log(f"ℹ Rate limit: Skipping sync for [{events_desc}] (within minimum interval).")

if __name__ == "__main__":
    main()
