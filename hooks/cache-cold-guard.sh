#!/bin/bash
# UserPromptSubmit hook: if this session has been idle > 60 min, the prompt cache
# has expired and the next message re-sends the whole conversation at full price.
# Block that first message ONCE with a reminder; re-sending it goes through.
# Slash commands (e.g. /handoff, /clear) always pass.
input=$(cat)
field() { echo "$input" | python -c "import sys,json;print(json.load(sys.stdin).get('$1') or '')" 2>/dev/null | tr -d '\r'; }
transcript=$(field transcript_path)
session=$(field session_id)
prompt=$(field prompt)

[ -z "$transcript" ] || [ ! -f "$transcript" ] && exit 0
case "$prompt" in /*) exit 0 ;; esac

now=$(date +%s)
last=$(stat -c %Y "$transcript" 2>/dev/null || stat -f %m "$transcript" 2>/dev/null) || exit 0
idle=$(( (now - last) / 60 ))
[ "$idle" -lt 60 ] && exit 0

# Only warn once per idle period: marker stores the transcript mtime we warned at.
marker="$HOME/.claude/state/cache-guard-$session"
mkdir -p "$HOME/.claude/state"
[ -f "$marker" ] && [ "$(cat "$marker")" = "$last" ] && exit 0
echo "$last" > "$marker"

# Only worth warning for big conversations (transcript > 200 KB).
size=$(wc -c < "$transcript")
[ "$size" -lt 200000 ] && exit 0

echo "Cache expired: idle ${idle} min, transcript $((size/1024)) KB. This message would re-read the whole conversation at full price. Cheaper: /handoff then /clear. To continue anyway, press Up and resend." >&2
exit 2
