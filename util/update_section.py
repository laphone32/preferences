#!/usr/bin/env python3
import sys
import os

def update_or_insert_section(file_path: str, section: str, content: str) -> None:
    head_note = f"### {section} ###"
    foot_note = f"### end of {section} ###"
    block = f"{head_note}\n{content}\n{foot_note}\n"

    if not os.path.exists(file_path):
        with open(file_path, "w") as f:
            f.write(block)
        return

    with open(file_path, "r") as f:
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

    with open(file_path, "w") as f:
        f.writelines(new_lines)

def main():
    if len(sys.argv) < 4:
        print("Usage: update_section.py <file_path> <section_name> <content>", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]
    section = sys.argv[2]
    content = sys.argv[3]

    update_or_insert_section(file_path, section, content)

if __name__ == "__main__":
    main()
