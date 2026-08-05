#!/bin/bash
# Requires CLAUDE_RELAY_MACHINE env var set per-machine - not synced, set once locally.
if [ -z "$CLAUDE_RELAY_MACHINE" ]; then
  exit 0
fi
DEFAULT_VAULT_PATH="/c/Projects/Academic/Master's Research/Obsidian Vault"
VAULT="${CLAUDE_RELAY_VAULT_PATH:-$DEFAULT_VAULT_PATH}"
cd "$VAULT" 2>/dev/null || exit 0
if [ -n "$(git status --porcelain -- Tools/relay/ 2>/dev/null)" ]; then
  git add Tools/relay/
  git commit -m "Relay: auto-sync end-of-session changes from ${CLAUDE_RELAY_MACHINE} ($(date '+%Y-%m-%d %H:%M'))" >/dev/null 2>&1
  git pull --quiet origin master >/dev/null 2>&1
  git push origin master >/dev/null 2>&1
fi

# Added 2026-08-05: warn-only (do not auto-commit) if the WHOLE vault has
# uncommitted changes at session end -- the chronic "draft left uncommitted"
# failure mode (thesis_draft_v2.tex, main_2026-07-16.tex, four 2026-08-03
# reports were all lost this way). See 00 - Meta/audit_2026-08-05_*.md §3.2.
DIRTY="$(git status --porcelain 2>/dev/null)"
if [ -n "$DIRTY" ]; then
  COUNT=$(printf '%s\n' "$DIRTY" | grep -c .)
  SAMPLE=$(printf '%s\n' "$DIRTY" | head -3 | cut -c4- | paste -sd ', ' -)
  ESCAPED_SAMPLE=$(printf '%s' "$SAMPLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"systemMessage":"\\u26a0 Vault has %s uncommitted change(s) as this session ends (e.g. %s) -- commit before closing, or it may be lost like past incidents (thesis_draft_v2.tex, four 2026-08-03 reports)."}' "$COUNT" "$ESCAPED_SAMPLE"
fi
