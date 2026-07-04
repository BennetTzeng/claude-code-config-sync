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

## "Upgrading" later

Whenever you change a setting on one machine and want it everywhere else:

```bash
# on the machine where you made the change
cd claude-code-config-sync
cp ~/.claude/settings.json settings/settings.json   # then manually re-add the __CLAUDE_HOME__ placeholder, see below
git add -A && git commit -m "update settings" && git push

# on every other machine
cd claude-code-config-sync
git pull
bash install.sh
```

## What's synced, and what's deliberately NOT

**Synced:**
- `settings.json` — theme, permission allow/deny lists, statusline config
- `statusline-command.sh` — the statusline script itself

**Deliberately excluded (stays machine-local):**
- `.credentials.json` — OAuth tokens. Never commit this to any repo, ever.
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
