#!/usr/bin/env bash
input=$(cat)

format_reset() {
  local resets=$1 fmt=${2:-%H:%M}
  [ -z "$resets" ] && return
  date -d "@${resets}" "+${fmt}" 2>/dev/null
}

minibar() {
  local pct=$1 cells=10
  local bar=""
  for ((i=0; i<cells; i++)); do
    local cell_mid=$(( i * 100 / cells + 100 / cells / 2 ))
    if [ "$pct" -ge "$cell_mid" ]; then
      bar+=$'\e[38;5;214m•\e[0m'
    else
      bar+=$'\e[38;5;238m•\e[0m'
    fi
  done
  printf '%b' "$bar"
}

format_limit() {
  local used_pct=$1 resets_at=$2 fmt=${3:-%H:%M}
  local remaining reset_in
  remaining=$(printf '%.0f' "$used_pct")
  local str="$(minibar "$remaining")"
  if [ -n "$resets_at" ]; then
    reset_in=$(format_reset "$resets_at" "$fmt")
    [ -n "$reset_in" ] && str+=" →${reset_in}"
  fi
  echo "$str"
}

parts=()

five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
[ -n "$five_used" ] && parts+=("$(format_limit "$five_used" "$five_resets")")

week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
[ -n "$week_used" ] && parts+=("$(format_limit "$week_used" "$week_resets" "%a %H:%M")")


if [ ${#parts[@]} -gt 0 ]; then
  output=""
  for i in "${!parts[@]}"; do
    [ $i -gt 0 ] && output+="  |  "
    output+="${parts[$i]}"
  done
  printf '%s' "$output"
fi
