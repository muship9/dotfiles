#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="${HOME}/.cache/gh-notify-poll"
SEEN_FILE="${CACHE_DIR}/seen.txt"
MODE="${1:-realtime}"

mkdir -p "$CACHE_DIR"

notify() {
  local title="$1" body="$2"
  terminal-notifier -title "$title" -message "$body" >/dev/null 2>&1 || true
}

fetch_filtered() {
  gh api notifications --paginate \
    --jq '.[] | select(.reason == "mention" or .reason == "team_mention" or .reason == "review_requested") | [.id, .repository.full_name, .subject.type, .subject.title, .subject.url, .reason] | @tsv'
}

run_realtime() {
  local tsv
  if ! tsv=$(fetch_filtered); then
    echo "ERROR: gh api notifications failed" >&2
    exit 1
  fi

  local current_ids
  current_ids=$(printf '%s\n' "$tsv" | awk -F'\t' 'NF{print $1}')

  if [[ ! -f "$SEEN_FILE" ]]; then
    printf '%s\n' "$current_ids" >"$SEEN_FILE"
    exit 0
  fi

  local new_tsv
  new_tsv=$(awk -F'\t' 'NR==FNR{seen[$0]=1;next} NF && !($1 in seen){print}' \
    "$SEEN_FILE" <(printf '%s\n' "$tsv"))

  local new_count
  new_count=$(printf '%s\n' "$new_tsv" | awk 'NF' | wc -l | tr -d ' ')

  if [[ "$new_count" -ge 3 ]]; then
    local latest_title
    latest_title=$(awk -F'\t' 'NF{print $4; exit}' <<<"$new_tsv")
    notify "GitHub: ${new_count} new notifications" "Latest: ${latest_title}"
  elif [[ "$new_count" -ge 1 ]]; then
    while IFS=$'\t' read -r id repo type title url reason; do
      [[ -z "${id:-}" ]] && continue
      notify "${repo}" "${title}"
    done <<<"$new_tsv"
  fi

  printf '%s\n' "$current_ids" >"$SEEN_FILE"
}

run_digest() {
  local tsv
  if ! tsv=$(fetch_filtered); then
    echo "ERROR: gh api notifications failed" >&2
    exit 1
  fi

  local count
  count=$(printf '%s\n' "$tsv" | awk -F'\t' 'NF' | wc -l | tr -d ' ')

  if [[ "$count" -eq 0 ]]; then
    notify "GitHub未読: 0件" "Inbox Zero"
  else
    local latest
    latest=$(awk -F'\t' 'NF{print $2 " - " $4; exit}' <<<"$tsv")
    notify "GitHub未読: ${count}件" "最新: ${latest}"
  fi
}

case "$MODE" in
  realtime) run_realtime ;;
  digest)   run_digest ;;
  *)
    echo "Unknown mode: $MODE (expected: realtime | digest)" >&2
    exit 2
    ;;
esac
