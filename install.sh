#!/usr/bin/env bash
# Installs the shared Claude Code config into ~/.claude on this machine.
# Safe to re-run — backs up any existing settings.json before overwriting.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
mkdir -p "$CLAUDE_HOME"

# Back up existing settings.json if present, timestamped so nothing is lost.
if [ -f "$CLAUDE_HOME/settings.json" ]; then
  cp "$CLAUDE_HOME/settings.json" "$CLAUDE_HOME/settings.json.bak.$(date +%Y%m%d%H%M%S)"
  echo "Backed up existing settings.json"
fi

# Copy the statusline script as-is.
cp "$REPO_DIR/settings/statusline-command.sh" "$CLAUDE_HOME/statusline-command.sh"
chmod +x "$CLAUDE_HOME/statusline-command.sh"

# settings.json has a __CLAUDE_HOME__ placeholder for the statusline command path
# (this machine's $HOME/.claude, not the one baked in at commit time) — substitute it in.
sed "s#__CLAUDE_HOME__#$CLAUDE_HOME#g" "$REPO_DIR/settings/settings.json" > "$CLAUDE_HOME/settings.json"

echo "Installed settings.json and statusline-command.sh into $CLAUDE_HOME"
echo "Note: this does NOT touch .credentials.json or project-specific settings.local.json — those stay machine-local on purpose."
