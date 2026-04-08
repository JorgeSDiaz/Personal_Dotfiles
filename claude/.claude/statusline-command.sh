#!/usr/bin/env bash
# Claude Code status line — sin dependencia de jq

input=$(cat)

# --- Colors (ANSI escape codes) ---
RESET="\033[0m"
CYAN="\033[96m"
YELLOW="\033[93m"
MAGENTA="\033[95m"
GREEN="\033[92m"
RED="\033[91m"
GRAY="\033[37m"
DIM="\033[2m"

SEP="${DIM} | ${RESET}"

# --- Nerd Font icons ---
ICON_FOLDER=$(python3 -c "import sys; sys.stdout.write('\uf07b')")   # nf-fa-folder
ICON_MODEL=$(python3 -c "import sys; sys.stdout.write('\uf292')")    # nf-fa-diamond (sparkle)
ICON_BRANCH=$(python3 -c "import sys; sys.stdout.write('\ue725')")   # nf-dev-git_branch
ICON_CTX=$(python3 -c "import sys; sys.stdout.write('\uf080')")      # nf-fa-bar-chart
ICON_TOKENS=$(python3 -c "import sys; sys.stdout.write('\uf0e7')")   # nf-fa-bolt

# Helper: extraer valor de JSON con python3
json_get() {
  python3 -c "
import sys, json
try:
  d = json.loads(sys.argv[1])
  keys = '${2}'.lstrip('.').split('.')
  val = d
  for k in keys:
    val = val[k]
  print(str(val)) if val is not None else print('')
except:
  print('')
" "$input" 2>/dev/null
}

# --- Git branch ---
cwd=$(json_get "$input" '.workspace.current_dir')
[ -z "$cwd" ] && cwd=$(json_get "$input" '.cwd')
[ -z "$cwd" ] && cwd=$(pwd)
branch_str=""
git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
[ -z "$git_branch" ] && git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
[ -n "$git_branch" ] && branch_str="${YELLOW}${ICON_BRANCH} ${git_branch}${RESET}"

# --- Model ---
model=$(python3 -c "
import sys, json
try:
  d = json.loads(sys.argv[1])
  m = d.get('model', {})
  print(m.get('id') or m.get('display_name') or '')
except:
  print('')
" "$input" 2>/dev/null)
model_str=""
[ -n "$model" ] && model_str="${MAGENTA}${ICON_MODEL} ${model}${RESET}"

# --- Context % ---
used_pct=$(python3 -c "
import sys, json
try:
  d = json.loads(sys.argv[1])
  v = d.get('context_window', {}).get('used_percentage', '')
  print(str(v) if v != '' else '')
except:
  print('')
" "$input" 2>/dev/null)

ctx_str=""
if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null)
  if [ -n "$pct_int" ]; then
    if [ "$pct_int" -ge 80 ]; then
      ctx_str="${RED}${ICON_CTX} ${pct_int}%${RESET}"
    else
      ctx_str="${GREEN}${ICON_CTX} ${pct_int}%${RESET}"
    fi
  fi
fi

# --- Tokens ---
total_input=$(python3 -c "
import sys, json
try:
  d = json.loads(sys.argv[1])
  u = d.get('context_window', {}).get('current_usage', {})
  total = (u.get('input_tokens') or 0) + (u.get('cache_read_input_tokens') or 0) + (u.get('cache_creation_input_tokens') or 0)
  print(str(total) if total > 0 else '')
except:
  print('')
" "$input" 2>/dev/null)

tokens_str=""
if [ -n "$total_input" ] && [ "$total_input" != "0" ]; then
  formatted=$(python3 -c "print(f'{int(\"$total_input\"):,}')" 2>/dev/null)
  [ -z "$formatted" ] && formatted="$total_input"
  label="tokens"
  [ "$total_input" = "1" ] && label="token"
  tokens_str="${GRAY}${ICON_TOKENS} ${formatted} ${label}${RESET}"
fi

parts=()
[ -n "$branch_str" ] && parts+=("$branch_str")
[ -n "$model_str" ]  && parts+=("$model_str")
[ -n "$ctx_str" ]    && parts+=("$ctx_str")
[ -n "$tokens_str" ] && parts+=("$tokens_str")

result=""
for part in "${parts[@]}"; do
  [ -z "$result" ] && result="$part" || result="${result}${SEP}${part}"
done
echo -e "$result"
