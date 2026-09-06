---
name: implement
description: Guides development tasks through a strict 3-phase workflow (plan, execute, verify), writing the plan to an interactive artifact for CLI review.
---

# Implementation Workflow

Use this skill whenever you are tasked with implementing features, refactoring code, or modifying configurations in this project, **and the design or solution has already been decided and agreed upon**. If the request is exploratory, asks for options/feasibility/ideas, or asks how to do something, you must **NOT** use this skill; instead, use the `discuss` skill to brainstorm, research, and align first. You must strictly follow these phases:

## Phase 1: Implementation Plan
- **Rule**: Do not modify any files or system settings in this phase.
- **Action**: Draft a complete implementation plan. 
- **Delivery**: You **MUST** write the implementation plan to a markdown artifact file inside the conversation's artifact directory (`<appDataDir>/brain/<conversation-id>`). The filename must be in the format `implementation_plan_<topic_slug>.md` (e.g., `implementation_plan_add_git_hooks.md`), where `<topic_slug>` is a short, descriptive snake_case identifier of the task. Do not use generic names like `implementation_plan.md`.
- **Metadata**: Set `RequestFeedback` to `true` in the artifact metadata.
- **Content**: Include the expected list of modified/changed files or settings, proposed directory structures, new file contents or diffs, specific terminal commands, a step-by-step checklist of actionable tasks (using `- [ ]`), and a clear verification plan.
- **Output**: Direct the user to review the plan in the CLI (which they can open using `/artifact` or the interactive controls). Do not modify anything until they approve. If the user provides comments, feedback, or requests changes, update the plan, save it with `RequestFeedback` set to `true`, and **STOP**. Do not proceed to Phase 2 (Execute Plan) until the user has explicitly approved the updated version of the implementation plan.

## Phase 2: Execute Plan
- **Action**: Once the implementation plan is approved, execute the planned tasks in order.
- **Rule**: Check off the tasks (updating the artifact checklist and/or reporting progress) and present them to the user as they are completed.

## Phase 3: Verification
- **Action**: Verify the final results against the original requirements using the verification steps outlined in Phase 1.
- **Output**: Present the verification results to the user.
