---
name: git-commit-rule
description: Prevents the agent from committing to the master/main branches and enforces standard commit message formats.
---

# Git Commit Rules

You (the AI agent) must strictly follow these rules whenever you create git commits in this repository.

## Rule 1: Branch Restriction
1. **Check the Branch**: Before executing any command that creates a git commit (e.g., `git commit`, `git commit-tree`, or running commit scripts), you must check the current git branch.
2. **Commit Restriction**: If the current branch is `master` or `main`, you must:
   - **REFUSE** to make the commit.
   - **EXPLAIN** to the user that committing directly to the `master` / `main` branch is prohibited.
   - **INSTRUCT** the user to switch to a non-master/non-main branch, or to create a new branch.
3. **Allowed Branches**: You may only commit changes if the current branch is a non-master and non-main branch (e.g., feature branches, bugfix branches).

## Rule 2: Commit Message Format
Whenever you are allowed to commit, you must format the commit message using the Conventional Commits style:
1. **Format**: `<type>(<scope>): <description>` (scope is optional).
2. **Allowed Types**:
   - `feat`: A new feature
   - `fix`: A bug fix
   - `docs`: Documentation only changes
   - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
   - `refactor`: A code change that neither fixes a bug nor adds a feature
   - `perf`: A code change that improves performance
   - `test`: Adding missing tests or correcting existing tests
   - `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation
3. **Case & Mood**: Use lowercase for the type, and use the imperative mood (e.g., "add skill" instead of "added skill") for the description.
4. **Length**: Keep the subject line (first line) to 72 characters or less.

## Rule 3: Commit Review and Confirmation
1. **Review Staged/Added Files**: Before running `git commit`, you must review all the files and modifications staged for the commit. Assess whether it is necessary or appropriate to commit each change (e.g., ensuring scratch scripts, temporary files, or unnecessary debug statements are not committed). If you are unsure if a change is necessary, ask the user to clarify/confirm before proceeding.
2. **Confirm Content with User**: Before executing `git commit`, you must present a summary of the changes or diff to be committed to the user and ask for their explicit confirmation. Do not run the commit command until the user approves.

