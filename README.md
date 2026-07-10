# Claude Code Config Sync

Keeps the parts of a Claude Code setup that are actually portable — global
`settings.json` and the statusline script — in sync across every machine you
use Claude Code on, without re-doing the setup by hand each time.

## Setup on a new machine

```bash
git clone https://github.com/BennetTzeng/claude-code-config-sync.git
cd claude-code-config-sync
bash install.sh
```

Works in Git Bash on Windows and in a normal terminal on macOS/Linux — Claude
Code's own Bash tool already runs through Git Bash on Windows, so this matches
that environment.

This also installs a `/sync-settings` custom Claude Code command (see below) —
after the first manual install, every future sync is just typing that in chat.

## "Upgrading" later — just say it

Once installed, open Claude Code on any machine and type:

```
/sync-settings
```

or just tell it in plain language, e.g. "sync my claude settings" — the
installed command handles pulling the latest config and running the installer,
or pushing local changes if you ask it to. You never need to remember the
actual git commands below; they're only here for reference.

<details>
<summary>What /sync-settings actually runs</summary>

```bash
# pulling latest onto this machine
cd claude-code-config-sync
git pull
bash install.sh

# pushing a local change to share with other machines
cp ~/.claude/settings.json settings/settings.json   # then manually re-add the __CLAUDE_HOME__ placeholder
git add -A && git commit -m "update settings" && git push
```
</details>

## Cross-machine relay (Tools/relay/ in the vault repo)

Two hook scripts (`hooks/relay-session-start.sh`, `hooks/relay-session-end.sh`)
are installed into `~/.claude/hooks/` and wired up in `settings.json`'s
`SessionStart`/`SessionEnd` hooks. Together they make the vault's
`Tools/relay/inbox-*.md` system automatic:
- **SessionStart**: pulls the vault repo and surfaces this machine's own inbox
  file if there's unread content, plus a standing reminder to write a note for
  other machines before ending the session if anything relay-worthy happened.
- **SessionEnd**: if the session wrote anything into `Tools/relay/`, commits
  and pushes it automatically.

**Required one-time step per machine (NOT synced on purpose):** set an
environment variable telling the scripts which inbox is "this machine's own" —

```bash
# Windows (persists across reboots)
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('CLAUDE_RELAY_MACHINE','acer','User')"

# macOS/Linux (add to ~/.zshrc or ~/.bashrc)
export CLAUDE_RELAY_MACHINE=macmini
```

Use `hp`, `acer`, or `macmini` matching that machine's actual inbox filename
in the vault repo (`inbox-hp.md`, `inbox-acer.md`, `inbox-macmini.md`). This
has to be set separately per machine — if it were in the synced
`settings.json`, every machine would think it was the same one. Until this is
set, the hooks silently no-op (no error, just do nothing).

## What's synced, and what's deliberately NOT

**Synced:**
- `settings.json` — theme, permission allow/deny lists, statusline config,
  relay hooks (see above)
- `statusline-command.sh` — the statusline script itself
- `hooks/relay-session-start.sh`, `hooks/relay-session-end.sh` — the relay
  hook scripts themselves

**Deliberately excluded (stays machine-local):**
- `.credentials.json` — OAuth tokens. Never commit this to any repo, ever.
- `permissions.defaultMode` / `skipDangerousModePermissionPrompt` — whether a
  machine runs in bypass-permissions mode is a deliberate, explicit decision
  made per-machine, not something that should silently propagate from one
  computer's settings.json to another's.
- Project-level `.claude/settings.local.json` — these accumulate
  machine-specific one-off permission grants (exact local file paths,
  which Python/conda install you have, etc.) that don't make sense on a
  different computer. Each machine builds its own over time; that's fine.
- `history.jsonl`, `sessions/`, `cache/`, `projects/` (auto-memory), `plans/`,
  `daemon*` — runtime state, not configuration. In particular, the
  project-scoped auto-memory system is keyed by an escaped version of the
  project's absolute path (e.g. `C--Projects`), so it won't transfer cleanly
  to a machine where the project lives at a different path anyway.

## Why `__CLAUDE_HOME__` instead of a hardcoded path

`settings.json`'s statusline command needs an absolute path to
`statusline-command.sh`, but that path is different on every machine
(different username, different OS). The committed file has a
`__CLAUDE_HOME__` placeholder instead of a real path; `install.sh` substitutes
in *this machine's* actual `$HOME/.claude` at install time, so the same
committed file works everywhere.
