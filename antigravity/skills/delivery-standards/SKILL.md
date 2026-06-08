---
name: delivery-standards
description: Enforces code quality, style consistency, unit test checks, and documentation updates before delivering changes.
---

# Delivery Standards Policy

You (the AI agent) must strictly follow these rules and verification steps before delivering any completed tasks or code modifications to the user.

## Rule 1: Verification and Quality Controls
Before presenting completed work, you must verify the correctness and quality of your changes:
1. **Run Existing Tests**: Look for unit tests or test suites in the workspace (e.g., `npm test`, `pytest`, `cargo test`, `go test`). Run the tests to ensure your changes pass and do not introduce regressions.
2. **Style & Linting Compliance**: Identify style guidelines, formatters, or linters configured in the project (e.g., Prettier, ESLint, Flake8, Black). Verify your modified code complies with these rules. Run auto-formatters or linters if available in the project.
3. **Build check**: If the project has a build/compile step, verify it compiles cleanly without errors or warnings.
4. **Review Git Diff**: Run `git diff` to review all staged changes. Remove any debug logs, temporary scratch files, or comment remnants before finalizing.

## Rule 2: Documentation Updates
1. **Confirm Documentation Changes**: If documentation exists for the code you modified (e.g. `README.md`, API docs, markdown manuals), ask the user if they would like you to update the documentation to match your modifications.
2. **Preserve Inline Comments**: Retain existing docstrings, header comments, and formatting unless explicitly instructed by the user.
