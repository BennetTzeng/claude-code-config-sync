#!/usr/bin/env bash
# Claude Code status line — Complete version
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

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
