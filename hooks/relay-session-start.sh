#!/bin/bash
# Open Casper's Prism LaTeX editor (prism.openai.com) alongside every session --
# this used to be a daily manual "paste me the URL" step; opening it here removes
# that. Best-effort: never blocks or fails the hook if the browser can't be found.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) cmd.exe /c start "" "https://prism.openai.com/" >/dev/null 2>&1 & ;;
  Darwin) open "https://prism.openai.com/" >/dev/null 2>&1 & ;;
  *) command -v xdg-open >/dev/null 2>&1 && xdg-open "https://prism.openai.com/" >/dev/null 2>&1 & ;;
esac

# Requires CLAUDE_RELAY_MACHINE env var set per-machine (e.g. hp, acer, macmini) - not synced, set once locally.
if [ -z "$CLAUDE_RELAY_MACHINE" ]; then
  echo '{}'
  exit 0
fi
VAULT="${CLAUDE_RELAY_VAULT_PATH:-/c/Projects/Academic/Master's Research/Obsidian Vault}"
cd "$VAULT" 2>/dev/null || { echo '{}'; exit 0; }
git pull --quiet origin master >/dev/null 2>&1

extract_new() {
  awk '/^## New/{f=1;next}/^## Read/{f=0}f' "$1" 2>/dev/null | grep -v '^[[:space:]]*$' | grep -v '(nothing yet)'
}

MSG=""
OWN_INBOX="Tools/relay/inbox-${CLAUDE_RELAY_MACHINE}.md"
if [ -f "$OWN_INBOX" ] && [ -n "$(extract_new "$OWN_INBOX")" ]; then
  MSG="Unread content in ${OWN_INBOX} under the New section - read it now before doing anything else. "
fi
PUBLIC_INBOX="Tools/relay/inbox-public.md"
if [ -f "$PUBLIC_INBOX" ] && [ -n "$(extract_new "$PUBLIC_INBOX")" ]; then
  MSG="${MSG}Unread content in ${PUBLIC_INBOX} (infra-wide announcement) under the New section - read it too. "
fi

REMINDER="Cross-machine relay: this machine is '${CLAUDE_RELAY_MACHINE}'. Before ending this session, if anything happened that other computers should know about, write it to Tools/relay/inbox-<machine>.md (or inbox-public.md for infra-wide changes) in the vault repo - it will auto-commit and push when the session ends."
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s%s"}}' "$MSG" "$REMINDER"
