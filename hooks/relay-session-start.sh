#!/bin/bash
# Requires CLAUDE_RELAY_MACHINE env var set per-machine (e.g. hp, acer, macmini) - not synced, set once locally.
if [ -z "$CLAUDE_RELAY_MACHINE" ]; then
  echo '{}'
  exit 0
fi
VAULT="/c/Projects/Academic/Master's Research/Obsidian Vault"
cd "$VAULT" 2>/dev/null || { echo '{}'; exit 0; }
git pull --quiet origin master >/dev/null 2>&1
INBOX="Tools/relay/inbox-${CLAUDE_RELAY_MACHINE}.md"
REMINDER="Cross-machine relay: this machine is '${CLAUDE_RELAY_MACHINE}'. Before ending this session, if anything happened that other computers (Acer/Mac Mini/HP - whichever aren't this one) should know about, write it to Tools/relay/inbox-<machine>.md in the vault repo - it will auto-commit and push when the session ends."
if [ -f "$INBOX" ] && grep -q '^## New' "$INBOX"; then
  NEWCONTENT=$(awk '/^## New/{f=1;next}/^## Read/{f=0}f' "$INBOX" | grep -v '^[[:space:]]*$' | grep -v '(nothing yet)')
  if [ -n "$NEWCONTENT" ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Pulled the vault repo and found unread content in %s under the New section - read that file now before doing anything else. %s"}}' "$INBOX" "$REMINDER"
    exit 0
  fi
fi
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$REMINDER"
