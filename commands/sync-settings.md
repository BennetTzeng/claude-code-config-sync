Sync this machine's Claude Code global settings with the shared
`claude-code-config-sync` GitHub repo (https://github.com/BennetTzeng/claude-code-config-sync).

Steps:
1. Find the local clone of `claude-code-config-sync` (check `C:\Projects\claude-code-config-sync`
   on Windows, or `~/claude-code-config-sync` on macOS/Linux; if neither exists, clone it fresh
   with `gh repo clone BennetTzeng/claude-code-config-sync` into the user's projects directory).
2. `git pull` in that repo.
3. Run `bash install.sh` from inside that repo — it copies `settings/settings.json` and
   `settings/statusline-command.sh` into `~/.claude/`, substituting the correct home path for
   this machine, and backs up any existing settings.json first.
4. If the user has made local changes to `~/.claude/settings.json` they want pushed to the repo
   instead of pulled: copy `~/.claude/settings.json` over `settings/settings.json` in the repo,
   manually replace this machine's real home path with the literal string `__CLAUDE_HOME__` in
   the statusLine command field, then `git add -A && git commit -m "update settings" && git push`.
5. Report what changed (new settings pulled in vs. nothing to do) in one or two sentences.

Default to pulling (step 1-3) unless the user says they want to push local changes instead.
