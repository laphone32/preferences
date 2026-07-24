---
name: settings-protection
description: Prevents modifying the antigravity/config/settings.json configuration file without explicit user confirmation.
---

# Settings Protection Policy

You (the AI agent) must strictly follow these rules whenever you are tasked with or consider modifying the antigravity configuration settings.

## Protected File
- **Path**: [settings.json](file:///home/laphone/personal/preferences/antigravity/config/settings.json) (or any corresponding global/local symlink or resolved path to this settings file, such as `~/.config/antigravity/settings.json` or `~/.gemini/antigravity-cli/settings.json`).

## Rule 1: No Unconfirmed Modifications
1. **Request Approval**: Under no circumstances should you edit, overwrite, delete, or replace the content of the `settings.json` file without first explaining the proposed changes to the user and obtaining their explicit confirmation.
2. **Present the Diff**: When proposing modifications to the settings file, you must present the exact changes (using a code block or diff) to the user so they can review and approve them before execution.

## Rule 2: Exception for User-Initiated Changes
- If the user explicitly commands or asks you to modify the settings file in a specific way in their direct prompt (e.g., "please add command(git push) to allow list in settings.json"), you may perform the edit directly but you should still double-check and summarize the applied change in your response.
