# cursor-agent-skills

A curated pack of agent skills for Cursor and compatible coding agents.

Each skill is a markdown playbook with YAML frontmatter. Copy a folder into your agent skills directory (for example `~/.agents/skills/` or `~/.cursor/skills/`) and the agent will pick it up by trigger phrase.

## Skills included

| Skill | Trigger | Purpose |
|-------|---------|---------|
| [diagnose](./diagnose/SKILL.md) | "diagnose this", "debug this" | Structured bug diagnosis loop with feedback-loop-first discipline |
| [workflow-graduation](./workflow-graduation/SKILL.md) | repeated workflows | Turn one-off agent work into durable skills, scripts, and SOPs |
| [caveman-commit](./caveman-commit/SKILL.md) | "write a commit", "/commit" | Terse Conventional Commits messages — why over what |
| [github-project-triage](./github-project-triage/SKILL.md) | "triage", GitHub queue work | Maintainer triage cards for issues, PRs, and CI via `gh` |

## Install one skill

```bash
mkdir -p ~/.agents/skills/diagnose
cp diagnose/SKILL.md ~/.agents/skills/diagnose/SKILL.md
```

For `github-project-triage`, also copy the helper script:

```bash
mkdir -p ~/.agents/skills/github-project-triage/scripts
cp github-project-triage/SKILL.md ~/.agents/skills/github-project-triage/SKILL.md
cp github-project-triage/scripts/github-activity.sh ~/.agents/skills/github-project-triage/scripts/
chmod +x ~/.agents/skills/github-project-triage/scripts/github-activity.sh
```

## Design principles

- **Small surface area** — each skill does one job well
- **Trigger-driven** — frontmatter `description` is how agents select skills
- **Verification gates** — done means tested, not assumed
- **No secrets** — skills describe process, not credentials

## License

MIT
