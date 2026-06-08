---
name: implementation-steps
description: Guides development tasks through a strict workflow, writing the plan to an interactive artifact for CLI review.
---

# Implementation Workflow

Use this skill whenever you are tasked with implementing features, refactoring code, or modifying configurations in this project, **and the design or solution has already been decided and agreed upon**. If the request is exploratory, asks for options/feasibility/ideas, or asks how to do something, you must **NOT** use this skill; instead, use the `discussion-partner` skill to brainstorm, research, and align first. You must strictly follow these phases:

## Phase 1: Implementation Plan
- **Rule**: Do not modify any files or system settings in this phase.
- **Action**: Draft a complete implementation plan. 
- **Delivery**: You **MUST** write the implementation plan to a markdown artifact file inside the conversation's artifact directory (`<appDataDir>/brain/<conversation-id>`). The filename must be in the format `implementation_plan_<topic_slug>.md` (e.g., `implementation_plan_add_git_hooks.md`), where `<topic_slug>` is a short, descriptive snake_case identifier of the task. Do not use generic names like `implementation_plan.md`.
- **Metadata**: Set `RequestFeedback` to `true` in the artifact metadata.
- **Content**: Include the expected list of modified/changed files or settings, proposed directory structures, new file contents or diffs, specific terminal commands, and a clear verification plan.
- **Output**: Direct the user to review the plan in the CLI (which they can open using `/artifact` or the interactive controls). Do not modify anything until they approve.

## Phase 2: Task List
- **Rule**: Do not modify any files or system settings in this phase.
- **Action**: Once the implementation plan is approved, construct a detailed task list of all actions needed. Do not begin implementation or modify any files yet.
- **Delivery**: Write this task list as a markdown artifact inside the conversation's artifact directory (`<appDataDir>/brain/<conversation-id>`) or directly in your response. The artifact filename must match the topic of the plan, formatted as `task_list_<topic_slug>.md` (e.g., `task_list_add_git_hooks.md`). Do not use generic names like `task_list.md`.
- **Metadata**: Set `RequestFeedback` to `true` in the artifact metadata.
- **Content**: Break down the plan into individual sub-tasks, including specific verification checks for each sub-task where appropriate. **Do not proceed to Phase 3 (implementation/execution) until the user has explicitly approved the task list.**

## Phase 3: Execute Task List
- **Action**: Once the task list is approved, execute the tasks.
- **Rule**: Check off the tasks and present them to the user one by one as they are completed.

## Phase 4: Verification
- **Action**: Verify the final results against the original requirements using the verification steps outlined in Phase 1.
- **Output**: Present the verification results to the user.
