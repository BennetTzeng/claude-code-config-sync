#!/usr/bin/env bash
# Claude Code status line: model | ctx% | cwd | repo | 5h% 7d%
# Uses jq when installed; otherwise falls back to Python (the HP machine has no jq).
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
  cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
  repo=$(printf '%s' "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
  used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
  five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
  week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
else
  PY=python; python -c "" 2>/dev/null || PY=python3
  # One Python call prints the six fields on separate lines.
  fields=$(printf '%s' "$input" | "$PY" -c '
import sys, json
d = json.load(sys.stdin)
def g(*ks):
    x = d
    for k in ks:
        x = x.get(k) if isinstance(x, dict) else None
    return x
r = g("workspace", "repo")
print(g("model", "display_name") or "Claude")
print(g("workspace", "current_dir") or d.get("cwd") or "?")
print(r["owner"] + "/" + r["name"] if isinstance(r, dict) and r.get("owner") else "")
for v in (g("context_window", "used_percentage"), g("rate_limits", "five_hour", "used_percentage"), g("rate_limits", "seven_day", "used_percentage")):
    print("" if v is None else v)
' 2>/dev/null | tr -d '\r')
  { read -r model; read -r cwd; read -r repo; read -r used; read -r five; read -r week; } <<< "$fields"
  model=${model:-Claude}
fi

out="$model"
[ -n "$used" ] && out="$out | ctx:$(printf '%.0f' "$used")%"
out="$out | $cwd"
[ -n "$repo" ] && out="$out | $repo"

if [ -n "$five" ] || [ -n "$week" ]; then
  limits=""
  [ -n "$five" ] && limits="5h:$(printf '%.0f' "$five")%"
  [ -n "$week" ] && limits="${limits:+$limits }7d:$(printf '%.0f' "$week")%"
  out="$out | $limits"
fi

printf "%s" "$out"
