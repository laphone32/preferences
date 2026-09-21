#!/usr/bin/env python3
"""Utility script for updating or deleting marked sections in text files."""

import os
import sys


def get_section_markers(file_path: str, section: str) -> tuple:
    """Return language-compatible (head_note, foot_note) section delimiters."""
    ext = os.path.splitext(file_path)[1].lower()
    if ext in [".lua"]:
        return f"-- ### {section} ###", f"-- ### end of {section} ###"
    if ext in [".vim"]:
        return f'" ### {section} ###', f'" ### end of {section} ###'
    if ext in [".c", ".cpp", ".js", ".ts"]:
        return f"// ### {section} ###", f"// ### end of {section} ###"
    return f"### {section} ###", f"### end of {section} ###"


def update_or_insert_section(
    file_path: str, section: str, content: str
) -> None:
    """Update existing marked section or insert a new one at EOF."""
    head_note, foot_note = get_section_markers(file_path, section)
    block = f"{head_note}\n{content}\n{foot_note}\n"

    if not os.path.exists(file_path):
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(block)
        return

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    in_section = False
    found = False

    for line in lines:
        if line.strip() == head_note:
            in_section = True
            found = True
            new_lines.append(block)
        elif line.strip() == foot_note:
            in_section = False
        elif not in_section:
            new_lines.append(line)

    if not found:
        if new_lines and not new_lines[-1].endswith("\n"):
            new_lines.append("\n")
        new_lines.append(block)

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)


def delete_section(file_path: str, section: str) -> None:
    """Delete a marked configuration section from a file."""
    head_note, foot_note = get_section_markers(file_path, section)

    if not os.path.exists(file_path):
        return

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    in_section = False

    for line in lines:
        if line.strip() == head_note:
            in_section = True
        elif line.strip() == foot_note:
            in_section = False
        elif not in_section:
            new_lines.append(line)

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)


def main():
    """CLI entrypoint for update_section."""
    if len(sys.argv) >= 4 and sys.argv[1] == "--delete":
        delete_section(sys.argv[2], sys.argv[3])
    elif len(sys.argv) >= 4:
        update_or_insert_section(sys.argv[1], sys.argv[2], sys.argv[3])
    else:
        print(
            "Usage: update_section.py <file_path> <section_name> <content>",
            file=sys.stderr,
        )
        print(
            "       update_section.py --delete <file_path> <section_name>",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
