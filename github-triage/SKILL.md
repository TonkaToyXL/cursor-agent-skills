---
name: github-triage
description: "Use when the user types triage or asks to triage GitHub issues, PRs, queues, CI, blockers, risk, proof, next actions, or autonomous GitHub maintainer work."
---

# GitHub Triage

Use this skill when the user types `triage`, asks about GitHub issues/PRs/queues, or says `do work autonomously`, `keep going`, or `fix what you can on GitHub`.

Triage means maintainer-facing item cards: URL, what each issue/PR is about, why it matters, author trust, fit, risk, proof/test state, blockers, and next action. Never return only queue numbers or opaque refs.

Output is URL-first: every surfaced issue/PR/repo item must include its full GitHub URL in the first line or first sentence for that item.

Adapted from [steipete/agent-scripts](https://github.com/steipete/agent-scripts); `gh`-only triage workflow.

## Modes

| Mode | Triggers | Permission |
|------|----------|------------|
| **Triage** | `triage`, queue summary, next actions | Read-only analysis; no edits |
| **Autonomous** | `do work autonomously`, `keep going`, `fix what you can on GitHub` | Implement + verify locally; push/merge/close only when explicitly authorized |

Triage alone is not permission to mutate GitHub or local repos.

## Scope

**Default (current repo):** If cwd is a git repo with a GitHub remote, triage only that project unless the user says `broad`, `all`, `everything`, or names multiple repos.

**Broad:** Scan all repos visible to `gh` (owned, collaborator, org — including private when token allows).

**No remote:** If the local project has no GitHub remote, say triage is N/A and offer to create/push a repo first.

## Setup

Verify `gh` auth:

```bash
gh auth status
```

Resolve current repo:

```bash
repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
if [ -z "$repo" ]; then
  url=$(git remote get-url origin 2>/dev/null || true)
  repo=$(printf '%s\n' "$url" |
    sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\.git$##')
fi
printf '%s\n' "$repo"
```

## Local Repo Gate

Before starting work inside any local project:

```bash
git status --short --branch
git branch --show-current
```

Proceed only when the worktree is clean. If dirty, stop and ask the user what to do. Do not stash, commit, reset, restore, or clean without explicit direction.

If not on the default branch (`main` or repo default), stop and ask unless the user already authorized work on that branch.

For autonomous work that needs latest `main`:

```bash
git pull --ff-only
```

If pull fails, stop and report.

## Product Fit

Read in order when present:

1. `VISION.md`
2. `README.md`
3. `AGENTS.md` / `CLAUDE.md`

Use these as product-fit source of truth before judging autonomous fit.

## Current-Project Triage

```bash
gh issue list --repo "$repo" --state open --limit 50 \
  --json number,title,author,labels,createdAt,updatedAt,url
gh pr list --repo "$repo" --state open --limit 50 \
  --json number,title,author,isDraft,reviewDecision,mergeStateStatus,createdAt,updatedAt,url
```

Before acting on any item, read all comments. **Maintainer comments are authoritative** — they override bot labels and ordinary triage judgment. If the maintainer says it looks good, needs changes, is superseded, or is not wanted, follow that.

For small queues (about 10 open items or fewer), inspect all items. For larger queues, inspect the top priority slice and say what was not expanded.

```bash
gh issue view <n> --repo "$repo" \
  --json number,title,author,body,comments,labels,createdAt,updatedAt,url
gh pr view <n> --repo "$repo" \
  --json number,title,author,body,comments,files,commits,isDraft,reviewDecision,mergeStateStatus,statusCheckRollup,createdAt,updatedAt,url
gh pr diff <n> --repo "$repo" --patch
```

Only comment, close, merge, rerun, or patch with strong evidence.

## Broad Queue Scan (gh-only)

List repos with open work, sorted by PR count then issues:

```bash
gh repo list --limit 200 --json nameWithOwner,issues,pullRequests,isPrivate,updatedAt \
  --jq '[.[] | select(.issues.totalCount > 0 or .pullRequests.totalCount > 0)]
        | sort_by(-.pullRequests.totalCount, -.issues.totalCount)
        | .[] | {repo: .nameWithOwner, issues: .issues.totalCount, prs: .pullRequests.totalCount, private: .isPrivate}'
```

Detail pass for top repos:

```bash
gh issue list --repo <owner/name> --state open --limit 50 --json number,title,author,url,updatedAt
gh pr list --repo <owner/name> --state open --limit 50 --json number,title,author,isDraft,url,updatedAt
gh run list --repo <owner/name> --limit 10
```

For mergeable or suspicious PRs:

```bash
gh pr view <n> --repo <owner/name> --json number,title,state,author,isDraft,mergeStateStatus,reviewDecision,statusCheckRollup,updatedAt,url
gh pr diff <n> --repo <owner/name> --patch
gh run list --repo <owner/name> --branch <branch> --limit 10
```

## Triage Output

Return three buckets:

- **Autonomous candidates:** fixable/landable without more product input — URL, why it qualifies, required verification, confidence. Selection for review, not permission to start unless the user also asked for autonomous execution.
- **Needs maintainer:** blocked on product direction, credentials/access, live proof unavailable, security/privacy judgment, or maintainer comment requesting changes.
- **Defer/close/supersede:** stale, duplicate, lower-quality, or overlapping items.

For plausible autonomous candidates on risky PRs (security, broad diff, new account), optionally spawn a **Task** subagent for trust/feasibility review before presenting.

## Item Evaluation

Classify each item:

| Type | Requirements |
|------|--------------|
| `bug` | Repro/log/failing test/current-main proof; root cause before fix |
| `feature` | E2E test plan; state missing creds/access explicitly |
| `dependency` | Package group, semver risk, failing checks, split recommendation |
| `security` | High priority; careful code-path proof; no merge on rationale alone |
| `docs/internal` | Lower risk; note user-visible relevance |

Judge: **Fit** (good/mixed/poor), **Risk** (low/medium/high), **Proof** (CI/repro/E2E/missing), **Blocker**, **Next** action.

## Trust Signals

For non-maintainer items you recommend acting on, include author trust:

```bash
./scripts/github-activity.sh --repo <owner/repo> --global <login>
```

Trust changes review depth, not correctness. Do not treat trust as proof.

## Permission Ladder

Separate permissions explicitly:

| Permission | What it allows |
|------------|----------------|
| Triage / monitor | Read queue, CI, diffs — no edits |
| Autonomous implement | Local changes, tests, live proof |
| Push | Push branch / update PR |
| CI fix | Rerun workflows, repair CI failures |
| Merge/close | Merge PR, close issue, comment as land proof |
| Release | Version bump, tag, publish |

Without required permission, stop at the last authorized boundary and report the exact next action needed.

The user saying `land it`, `merge`, or `push` counts as explicit authorization for that action.

## Autonomous Work Mode

When the user authorizes autonomous work, do not stop after a queue summary or one local patch. Process the eligible queue **sequentially, one item at a time**, until no safe autonomous item remains, each item is landed/closed/deferred with proof, or a blocker requires the user.

For each item:

1. Read issue/PR, related code, docs, CI, and product-fit files; use official docs when facts may be stale.
2. Decide autonomous fit:
   - **Go:** performance (unless complexity spikes); bugfixes with repro; small UI/docs; narrow test/CI fixes; low-risk deps.
   - **Ask first:** new features, product choices, broad behavior changes, security without proof, live-provider work without creds, anything not E2E testable.
   - **Refactor:** prefer clean bounded refactor when it is the better fix.
3. Implement or fix PR in the best maintainable way. Prefer updating contributor PR when writable; preserve credit.
4. **Live proof** on the real boundary (device/audio, browser, API with real creds when available). If access missing, stop before claiming done.
5. Run review: Bugbot or security-review subagent for non-trivial changes; address actionable findings.
6. Ensure CI green; good PR description/changelog. If push authorized, push. If merge authorized, land with proof comment.
7. Post PR comment with exactly how it was tested: commands, live proof, CI state, landed commit, caveats.
8. Return to default branch, `git pull --ff-only`, verify clean worktree, then next item.

Do not end with dirty files or unpushed fixes unless blocked. If blocked, state exact blocker, branch/status, proof gathered, and decision needed.

**Integrate — do not duplicate:**

- PR merge-ready loop → `a PR babysit automation (see agent-loop-runner)`
- CI failures → `gh-fix-ci` when available
- Done claims → verification-before-completion
- Commits → `your commit message conventions`

## Live Proof Gate

Live proof is required before merge/close, not optional polish.

- Test the final candidate through the changed user path with real built artifact and real service/device/OS as applicable.
- Mocks, fixtures, and CI supplement but do not replace live proof for runtime changes.
- Redact secrets; keep concrete evidence (command, behavior, response class, state transition).
- If creds/hardware unavailable, finish code/tests/CI, then stop and ask with a decision brief.
- Docs/CI/test-only changes: use closest built-artifact or workflow proof; state why no external boundary applies.

## Owner Decision Brief

Never ask the maintainer to land/delete/approve with only a URL.

Every decision request must include:

- Full canonical clickable URL and title
- Plain-language what changes and who benefits
- Why the decision is needed now
- Completed proof: repro, live test, tests, review, CI, mergeability
- Tradeoffs, residual risks, scope concerns
- Recommendation and rationale
- Exact choices and what each does

If autonomous work remains, do that first — report as active, not premature decision.

## Triage Heuristics

**Prioritize:** green/near-green CI PRs; reproducible bugs; security/release/auth/CI/data-loss; dependency/docs with clear path.

**Deprioritize:** archived repos (unless asked); old broad features without repro; provider PRs needing unavailable API keys; generated churn without user problem.

## Output Shape

**Current-project triage:**

```text
Repo: owner/name
Source: gh list/view/diff/checks, local source/tests where inspected

Autonomous candidates:
- https://github.com/owner/repo/pull/123 — title
  What: one-line summary.
  Type/Fit/Risk: bug; good; low because ...
  Trust: @login; acct date; repo/global activity; known/unknown/bot.
  Proof: CI/repro/test/e2e state.
  Blocker: none / ...
  Next: exact action.

Needs maintainer:
- https://github.com/owner/repo/issues/124 — ...

Defer/close:
- https://github.com/owner/repo/issues/125 — ...

Skipped:
- <why>
```

**Broad scan:**

```text
Owners/repos scanned: <summary>
Source: gh repo list + gh detail for selected repos

Top queues:
- owner/repo: X issues, Y PRs; why it matters; next action

Autonomous candidates:
- <URL-first items>

Needs maintainer:
- <URL-first items>

Skipped:
- archived/no access/etc.
```

When the user asks to act, inspect selected items with `gh`, rerun/fix CI when authorized, comment/close/merge only with evidence, and report exact commands/proof.

## Credential Access

1. Check only the exact expected environment variable; use only when already exported.
2. Never broadly enumerate secrets or print values.
3. Ask the user only after targeted env check fails or interactive unlock is required.
4. Report presence, access path, and exact missing approval — never send credentials between threads.
