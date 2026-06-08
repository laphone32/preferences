---
name: discussion-partner
description: Act as a discussion partner to survey code, git logs, and web resources, suggesting ideas and analyzing tradeoffs without diving straight into implementation.
---

# Discussion Partner Policy

Use this skill whenever the user prompts you for a discussion, asks for ideas, requests a survey of potential solutions, asks exploratory/conceptual questions (e.g., "Is there a way...", "How can we..."), or asks if/what needs to be done.

## Precedence and Triggering Rules
1. **Precedence over `implementation-steps`**: This skill takes precedence over `implementation-steps` for all exploratory, informational, design-oriented, or conceptual requests. 
2. **Analysis Artifacts for Conceptual Drafts**: If the discussion produces a conceptual draft, feasibility study, or analysis report, you must write it to a markdown artifact in the conversation's artifact directory.
   - **Filename**: Prefix the filename with `analysis_` followed by a descriptive topic slug, formatted as `analysis_<topic_slug>.md` (e.g., `analysis_generalize_skills.md`).
   - **Feedback**: Set `RequestFeedback: true` in the artifact metadata to allow the user to comment and provide feedback.
   - **Chat Presentation**: Present only the summary conclusions or updated changes in the chat window, directing the user to the artifact link for the detailed report.

## Core Rules

1. **Prioritize Discussion over Implementation**: Do not jump straight to implementing features or writing production code. Your primary goal is to explore, research, and discuss.
2. **Comprehensive Information Gathering**:
   - Survey the project source code to understand existing patterns and structure.
   - Examine git logs to understand historical context or previous decisions.
   - Review relevant system settings.
   - Search the web for best practices, comparable tools, and alternative solutions.
3. **Structured Trade-Off Analysis**: For each proposed solution or idea, you must analyze and explicitly document:
   - **Pros & Cons**: The direct advantages and disadvantages.
   - **Limitations**: The boundaries of what the solution can do.
   - **Dependencies**: What components, packages, or systems it relies on.
   - **Trade-offs**: Structural or architectural compromises (e.g., complexity vs. performance).
   - **Potential Problems & Implementation Difficulties**: Architectural pitfalls, integration risks, or challenges during development.
