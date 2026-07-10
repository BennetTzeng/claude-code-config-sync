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

# Install the /sync-settings custom command so future syncs are a one-word command,
# not a remembered git incantation.
mkdir -p "$CLAUDE_HOME/commands"
cp "$REPO_DIR/commands/sync-settings.md" "$CLAUDE_HOME/commands/sync-settings.md"

# Cross-machine relay hook scripts (checks/writes Tools/relay/inbox-*.md in the vault repo).
mkdir -p "$CLAUDE_HOME/hooks"
cp "$REPO_DIR/hooks/relay-session-start.sh" "$CLAUDE_HOME/hooks/relay-session-start.sh"
cp "$REPO_DIR/hooks/relay-session-end.sh" "$CLAUDE_HOME/hooks/relay-session-end.sh"
chmod +x "$CLAUDE_HOME/hooks/relay-session-start.sh" "$CLAUDE_HOME/hooks/relay-session-end.sh"

echo "Installed settings.json, statusline-command.sh, /sync-settings, and relay hooks into $CLAUDE_HOME"
echo "Note: this does NOT touch .credentials.json or project-specific settings.local.json — those stay machine-local on purpose."
echo "Note: the relay hooks need a one-time per-machine env var to know which inbox is theirs — see README for CLAUDE_RELAY_MACHINE."

# Desktop shortcuts to the two research panels, so they're one click away instead of
# needing to be re-found each time. Only auto-created on Windows, where the vault's
# Tools/ path is a known convention (C:\Projects\Tools\...). On macOS the project path
# isn't standardized across machines, so this is a manual step instead (see README).
if command -v powershell.exe >/dev/null 2>&1; then
  DASHBOARD_PATH='C:\Projects\Tools\rendered\dashboard.html'
  VIEWER_PATH='C:\Projects\Tools\vault-viewer.html'
  powershell.exe -NoProfile -Command "
    \$desktop = [Environment]::GetFolderPath('Desktop')
    \$WshShell = New-Object -ComObject WScript.Shell
    if (Test-Path '$DASHBOARD_PATH') {
      \$s = \$WshShell.CreateShortcut(\"\$desktop\Research Dashboard.lnk\")
      \$s.TargetPath = '$DASHBOARD_PATH'
      \$s.IconLocation = 'C:\Windows\System32\imageres.dll,174'
      \$s.Save()
    }
    if (Test-Path '$VIEWER_PATH') {
      \$s2 = \$WshShell.CreateShortcut(\"\$desktop\Vault Viewer.lnk\")
      \$s2.TargetPath = '$VIEWER_PATH'
      \$s2.IconLocation = 'C:\Windows\System32\imageres.dll,174'
      \$s2.Save()
    }
  " >/dev/null 2>&1 && echo "Created desktop shortcuts: Research Dashboard, Vault Viewer (skipped any whose target file doesn't exist on this machine)."
fi
