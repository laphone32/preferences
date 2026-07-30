# Universal Principles for Agent Work

You (the AI agent) must strictly adhere to the following principles across all tasks and repository interactions.

## 1. Delivery Standards & Quality Controls
Before presenting completed work or delivering code modifications to the user, you must verify the correctness and quality of your changes:
1. **Run Existing Tests**: Look for unit tests or test suites in the workspace (e.g., `npm test`, `pytest`, `cargo test`, `go test`). Run the tests to ensure your changes pass and do not introduce regressions.
2. **Style & Linting Compliance**: Identify style guidelines, formatters, or linters configured in the project (e.g., Prettier, ESLint, Flake8, Black). Verify your modified code complies with these rules. Run auto-formatters or linters if available in the project.
3. **Build Check**: If the project has a build/compile step, verify it compiles cleanly without errors or warnings.
4. **Review Git Diff**: Run `git diff` to review all staged changes. Remove any debug logs, temporary scratch files, or comment remnants before finalizing.
5. **Documentation Updates**: If documentation exists for the code you modified (e.g., `README.md`, API docs, markdown manuals), ask the user if they would like you to update the documentation to match your modifications. Preserve existing docstrings, header comments, and inline formatting unless explicitly instructed by the user.

## 2. Git Commit Rules
Whenever you create git commits in a repository:
1. **Branch Restriction**: Before executing any command that creates a git commit (e.g., `git commit`, `git commit-tree`, or running commit scripts), check the current git branch. If the current branch is `master` or `main`:
   - **REFUSE** to make the commit.
   - **EXPLAIN** to the user that committing directly to `master` / `main` is prohibited.
   - **INSTRUCT** the user to switch to a non-master/non-main branch, or to create a new branch.
2. **Allowed Branches**: You may only commit changes if the current branch is a non-master and non-main branch (e.g., feature branches, bugfix branches).
3. **Commit Message Format**: Format commit messages using Conventional Commits (`<type>(<scope>): <description>`):
   - Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.
   - Use lowercase for the type and imperative mood (e.g., "add feature" instead of "added feature") for the description.
   - Keep the subject line (first line) to 72 characters or less.
4. **Commit Review and Confirmation**: Review all files and modifications staged for the commit to ensure scratch scripts, temporary files, or debug statements are not committed. Present a summary of changes / diff to the user and obtain explicit approval before running `git commit`.

## 3. Settings Protection Policy
Whenever tasked with or considering modifying configuration settings:
1. **Protected Path**: `settings.json` (or any corresponding global/local symlink or resolved path, such as `~/.config/antigravity/settings.json` or `~/.gemini/antigravity-cli/settings.json`).
2. **No Unconfirmed Modifications**: Under no circumstances should you edit, overwrite, delete, or replace configuration settings files without explaining the proposed changes to the user and obtaining explicit confirmation with a presented diff.
3. **User-Initiated Exception**: If the user explicitly commands or asks you to modify the settings file in their prompt (e.g., "please add command(git push) to allow list in settings.json"), you may perform the edit directly, double-checking and summarizing the applied changes in your response.

## 4. Modification Explanation & Confirmation
Whenever requesting confirmation or permission to perform any file modification, you must provide a brief explanation of the purpose and goal of the proposed modification along with the request.

