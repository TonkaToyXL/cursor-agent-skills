---
name: workflow-graduation
description: Use when a task, fix, research flow, content pipeline, or agent workflow repeats or is likely to repeat. Converts one-off work into durable SOPs, skills, scripts, checklists, memory notes, or backlog items so the agent compounds instead of rediscovering.
---

# Workflow Graduation

## Purpose

Turn repeated or high-value agent work into durable operating assets. This is the “don’t rediscover it next time” skill.

Use it when:
- A workflow has been done twice or will clearly recur.
- A bug/fix/config issue repeats.
- A user says “make this reusable,” “do this properly,” “remember the process,” or “follow your recommendation.”
- A task produced a useful pattern, checklist, prompt, source set, command, or acceptance gate.
- A workflow belongs to a named lane such as content pipelines, config repair, research briefs, or agent/tool setup.

Do **not** use it for true one-offs with no future value.

## Graduation Decision

Classify the work into the smallest durable artifact that will prevent future rediscovery:

| Pattern | Graduate into |
|---|---|
| Stable multi-step workflow | Skill (`~/.agents/skills/<name>/SKILL.md`) |
| Small command sequence | Script or launcher |
| Repeated checklist | SOP/checklist markdown |
| Durable preference/context | Memory note / Obsidian / Gemini Memory |
| Bug or trap | Mistake note + guardrail |
| Future improvement | Backlog item with trigger + acceptance criteria |

Prefer the least complex artifact that will actually be used.

## Required Workflow

1. **Capture the trigger**
   - What happened?
   - What phrase/task should trigger this next time?
   - Which lane does it belong to?

2. **Extract the reusable shape**
   - Inputs needed
   - Steps that worked
   - Tools/sources used
   - Verification gate
   - Output contract
   - Known caveats

3. **Choose the artifact**
   - Skill for cross-session behavior
   - SOP/checklist for guidance
   - Script for deterministic commands
   - Memory for durable preferences/facts
   - Backlog if not implemented now

4. **Install or update it**
   - Put active skills under `~/.agents/skills/<skill-name>/SKILL.md` or your agent skills directory.
   - Put workspace SOPs/backlogs under your agent workspace memory folder.
   - Do not edit generated foundation blocks directly unless the user explicitly asks.

5. **Verify**
   - YAML frontmatter parses.
   - Trigger description is clear enough for future skill selection.
   - Artifact path exists.
   - If a script was added, run a dry-run/help/syntax check.
   - If a workflow was added, include an acceptance gate.

6. **Report briefly**
   - What was made
   - Where it lives
   - How it will trigger next time
   - Any remaining backlog

## Backlog Item Template

```markdown
### <title>
- **Lane:** <agent / content / client / personal ops>
- **Trigger:** <when this should apply>
- **Problem:** <what keeps getting rediscovered or repeated>
- **Durable asset:** <skill / script / SOP / memory / guardrail>
- **Acceptance gate:** <how future agent verifies it worked>
- **Status:** queued | in-progress | shipped | retired
```

## Quality Bar

A graduated workflow is only “done” if a future session can execute it without asking the user to re-explain the context.

Good assets are:
- Short enough to be read quickly.
- Specific enough to prevent mistakes.
- Source-backed when claims matter.
- Paired with a verification gate.
- Updated when reality changes.

## Anti-Patterns

Avoid:
- Huge generic skills that trigger on everything.
- Saving secrets or private tokens.
- Backlogs with no trigger or acceptance gate.
- Writing “remember to…” without creating a durable file/tool.
- Making a skill when a 10-line checklist would do.
