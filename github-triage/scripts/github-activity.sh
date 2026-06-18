#!/usr/bin/env bash
# Author trust summary via gh API. Usage:
#   github-activity.sh --repo owner/repo --global login
set -euo pipefail

repo=""
login=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --global)
      login="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$repo" || -z "$login" ]]; then
  echo "Usage: $0 --repo owner/repo --global login" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Trust: @$login; gh not installed; signal: unknown."
  exit 0
fi

owner="${repo%%/*}"

user_json=$(gh api "users/${login}" --jq '{createdAt, type}' 2>/dev/null || echo '{}')
created_raw=$(printf '%s' "$user_json" | jq -r '.createdAt // empty')
if [[ -n "$created_raw" && "$created_raw" != "null" ]]; then
  created=$(printf '%s' "$created_raw" | cut -c1-10)
else
  created="unknown"
fi
acct_type=$(printf '%s' "$user_json" | jq -r '.type // "User"')

repo_prs=$(gh api "search/issues?q=repo:${repo}+type:pr+author:${login}&per_page=1" --jq .total_count 2>/dev/null || echo 0)
repo_issues=$(gh api "search/issues?q=repo:${repo}+type:issue+author:${login}&per_page=1" --jq .total_count 2>/dev/null || echo 0)
global_prs=$(gh api "search/issues?q=author:${login}+type:pr&per_page=1" --jq .total_count 2>/dev/null || echo 0)
global_issues=$(gh api "search/issues?q=author:${login}+type:issue&per_page=1" --jq .total_count 2>/dev/null || echo 0)

signal="unknown"
if [[ "$acct_type" == "Bot" ]]; then
  signal="bot"
elif [[ "$login" == "$owner" ]]; then
  signal="owner"
elif [[ "$repo_prs" -gt 0 || "$repo_issues" -gt 0 ]]; then
  signal="known contributor"
elif [[ "$global_prs" -gt 5 || "$global_issues" -gt 3 ]]; then
  signal="active GitHub user"
else
  signal="new or low-signal"
fi

printf 'Trust: @%s; acct %s; repo %s PRs/%s issues; GitHub %s PRs/%s issues; signal: %s.\n' \
  "$login" "$created" "$repo_prs" "$repo_issues" "$global_prs" "$global_issues" "$signal"
