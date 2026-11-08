---
description: Write a handoff file so the next session can resume after /clear (cheaper than /compact on a cold cache)
---

Write a handoff note for this session to `.claude/handoff.md` in the current project root (create `.claude/` if needed; overwrite any older handoff). A fresh session will read it after `/clear`, so include ONLY what a new session could not work out from the repo itself:

1. **Goal**: what we are trying to achieve, in one or two lines.
2. **Done**: what is finished and verified (with commit hashes if any).
3. **Next**: the very next concrete step, then the rest in order.
4. **Files touched**: paths, plus one line each on what changed.
5. **Decisions**: choices made and why (so they are not re-litigated).
6. **Tried and failed**: approaches that did not work and why (so they are not retried).
7. **Open questions for Casper**, if any.

Keep it under ~60 lines. Do not paste file contents, logs, or the conversation itself; point to paths instead. If the project is a git repo, commit the handoff file together with today's work (per the commit-same-day rule).

When done, reply with just the path and this line: "Now run `/clear`, then say: 讀 .claude/handoff.md 接手".

$ARGUMENTS
