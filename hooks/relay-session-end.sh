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
