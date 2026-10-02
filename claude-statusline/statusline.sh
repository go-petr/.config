#!/usr/bin/env bash
# Claude Code status line: model, ctx/5h/7d gradient gauges, cost, git.
input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
dir=$(j '.workspace.current_dir')
cost=$(j '.cost.total_cost_usd')
ctx=$(j '.context_window.used_percentage')
h5=$(j '.rate_limits.five_hour.used_percentage')
h5_reset=$(j '.rate_limits.five_hour.resets_at')
d7=$(j '.rate_limits.seven_day.used_percentage')

E=$'\e'
RST="$E[0m"; DIM="$E[2m"; BOLD="$E[1m"
GRAD=(77 113 149 185 221 215 209 203)   # green → yellow → red, one per cell
EMPTY="$E[38;5;238m"

# Value colour by threshold
pct_color() {
  local p=$1
  if   (( p >= 75 )); then printf '%s' "$E[38;5;203m"
  elif (( p >= 50 )); then printf '%s' "$E[38;5;221m"
  else                     printf '%s' "$E[38;5;77m"
  fi
}

# gauge LABEL PCT → "label ▰▰▰▱▱▱▱▱ 41%"
gauge() {
  local label=$1 p filled out="" i
  p=$(printf '%.0f' "$2")
  filled=$(( (p * 8 + 50) / 100 ))
  (( p > 0 && filled == 0 )) && filled=1
  for i in {0..7}; do
    if (( i < filled )); then out+="$E[38;5;${GRAD[i]}m▰"; else out+="${EMPTY}▱"; fi
  done
  printf '%s%s%s %s%s %s%s%%%s' "$DIM" "$label" "$RST" "$out" "$RST" "$(pct_color "$p")" "$p" "$RST"
}

fmt_time() {
  local t=$1
  [[ $t =~ ^[0-9]+$ ]] || t=$(date -j -f '%Y-%m-%dT%H:%M:%S' "${t%%[.Z+]*}" +%s 2>/dev/null || date -d "$t" +%s 2>/dev/null)
  [[ -n $t ]] && { date -r "$t" +%H:%M 2>/dev/null || date -d "@$t" +%H:%M; }
}

parts=()
[[ -n $model ]] && parts+=("$E[38;5;141m✦ $BOLD$model$RST")
[[ -n $ctx ]] && parts+=("$(gauge ctx "$ctx")")
if [[ -n $h5 ]]; then
  seg=$(gauge 5h "$h5")
  [[ -n $h5_reset ]] && r=$(fmt_time "$h5_reset") && [[ -n $r ]] && seg+=" ${DIM}↻${r}${RST}"
  parts+=("$seg")
fi
[[ -n $d7 ]] && parts+=("$(gauge 7d "$d7")")
[[ -n $cost ]] && parts+=("$E[38;5;222m\$$(printf '%.2f' "$cost")$RST")

if [[ -n $dir ]] && branch=$(git -C "$dir" branch --show-current 2>/dev/null) && [[ -n $branch ]]; then
  dirty=""
  [[ -n $(git -C "$dir" status --porcelain -uno 2>/dev/null | head -1) ]] && dirty="$E[38;5;209m*"
  parts+=("$E[38;5;74m $branch$dirty$RST")
fi

out=""
for p in "${parts[@]}"; do out+="${out:+  }$p"; done
printf '%s' "$out"
