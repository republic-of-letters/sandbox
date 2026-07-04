#!/usr/bin/env bash
# Scaffold the next collaboration round.
#   ./scripts/new-round.sh "fifty cent crossings"
# Creates branch round/R<NNN>-<slug>, copies the template, stamps ASK.md, prints the id.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "$#" -lt 1 ]; then
  echo "usage: $0 \"short slug words\"" >&2
  exit 2
fi

# slug: lowercase, spaces -> hyphens, drop anything that isn't [a-z0-9-]
slug=$(printf '%s' "$*" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -s ' ' '-' \
  | tr -cd 'a-z0-9-' \
  | sed -E 's/^-+//; s/-+$//')
[ -n "$slug" ] || { echo "error: slug is empty after normalisation" >&2; exit 2; }

# next number: max R<NNN> across local folders AND remote round branches (so two
# proposers scaffolding concurrently don't collide), + 1, zero-padded to 3
if git rev-parse --git-dir >/dev/null 2>&1; then
  git fetch origin --quiet 2>/dev/null || true
fi
next=$( { ls -d exchange/R[0-9]* 2>/dev/null | sed -E 's#.*/R([0-9]+).*#\1#'; \
          git branch -r 2>/dev/null | sed -nE 's#.*origin/round/R([0-9]+).*#\1#p'; } \
  | sort -n | tail -1)
next=$(( 10#${next:-0} + 1 ))
id=$(printf 'R%03d' "$next")
folder="exchange/${id}-${slug}"
branch="round/${id}-${slug}"
today=$(date +%F)

[ -e "$folder" ] && { echo "error: $folder already exists" >&2; exit 1; }

# branch (only if this is a git repo)
if git rev-parse --git-dir >/dev/null 2>&1; then
  git switch -c "$branch"
fi

cp -R exchange/_TEMPLATE "$folder"

# stamp the ask
ask="$folder/ASK.md"
sed -i.bak -E \
  -e "s/^round:.*/round:    ${id}/" \
  -e "s/^created:.*/created:  ${today}/" \
  "$ask"
rm -f "$ask.bak"

echo "created round ${id}"
echo "  folder : $folder"
echo "  branch : $branch"
echo "next: edit $ask (set topic:/kind:), write $folder/run.py, then open the PR (see AGENTS.md §4)"
