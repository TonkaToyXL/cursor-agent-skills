# Cursor Agent Skills

Curated markdown skills for Cursor and compatible coding agents. Copy a folder into `~/.cursor/skills/` or `~/.agents/skills/` — agents pick them up by trigger phrase.

## Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| [diagnose](./diagnose/SKILL.md) | "diagnose this", "debug this" | Structured bug diagnosis loop |
| [workflow-graduation](./workflow-graduation/SKILL.md) | repeated workflows | Turn one-off work into durable skills and scripts |
| [terse-commit](./terse-commit/SKILL.md) | "write a commit", "/commit" | Terse Conventional Commits — why over what |
| [github-triage](./github-triage/SKILL.md) | "triage", GitHub queue work | Maintainer triage cards for issues, PRs, and CI |

## Install

```bash
SKILLS=~/.cursor/skills   # or ~/.agents/skills

mkdir -p "$SKILLS/diagnose"
cp diagnose/SKILL.md "$SKILLS/diagnose/SKILL.md"
```

For **github-triage**, also copy the helper script:

```bash
mkdir -p "$SKILLS/github-triage/scripts"
cp github-triage/SKILL.md "$SKILLS/github-triage/SKILL.md"
cp github-triage/scripts/github-activity.sh "$SKILLS/github-triage/scripts/"
chmod +x "$SKILLS/github-triage/scripts/github-activity.sh"
```

## Principles

- One skill, one job
- Trigger-driven selection via YAML frontmatter
- No secrets in skill files

## License

MIT
