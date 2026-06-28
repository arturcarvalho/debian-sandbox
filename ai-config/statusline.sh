#!/usr/bin/env bash
input=$(cat)

format_reset() {
  local resets=$1
  [ -z "$resets" ] && return
  date -d "@${resets}" '+%H:%M' 2>/dev/null
}

minibar() {
  local pct=$1 cells=4
  local levels=("⣀" "⣄" "⣤" "⣦" "⣶" "⣷" "⣿")
  local bar=""
  for ((i=0; i<cells; i++)); do
    local cell_start=$((i * 100 / cells))
    local cell_end=$(((i + 1) * 100 / cells))
    if [ "$pct" -ge "$cell_end" ]; then
      bar+="⣿"
    elif [ "$pct" -le "$cell_start" ]; then
      bar+="⣀"
    else
      local idx=$(( (pct - cell_start) * 6 / (100 / cells) ))
      bar+="${levels[$idx]}"
    fi
  done
  echo "$bar"
}

format_limit() {
  local label=$1 used_pct=$2 resets_at=$3
  local remaining reset_in
  remaining=$(printf '%.0f' "$used_pct")
  local str="${label}: $(minibar "$remaining")"
  if [ -n "$resets_at" ]; then
    reset_in=$(format_reset "$resets_at")
    [ -n "$reset_in" ] && str+=" ${reset_in}"
  fi
  echo "$str"
}

parts=()

five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
[ -n "$five_used" ] && parts+=("$(format_limit "sess" "$five_used" "$five_resets")")

week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
[ -n "$week_used" ] && parts+=("$(format_limit "week" "$week_used" "$week_resets")")


if [ ${#parts[@]} -gt 0 ]; then
  output=""
  for i in "${!parts[@]}"; do
    [ $i -gt 0 ] && output+="  |  "
    output+="${parts[$i]}"
  done
  printf '%s' "$output"
fi
