#!/usr/bin/env bash
# Download the sandbox dataset so you can test a round locally before opening the PR.
#
#   bash scripts/get-data.sh          # downloads into ./.data/, prints DATA_ROOT
#
# The data is a public NYC-taxi sample attached to this repo as a release named
# "data" (tag data-v1). It is public domain — this script needs no auth.
# ./.data/ is gitignored: the data must never be committed (AGENTS.md §8).
set -euo pipefail

cd "$(dirname "$0")/.."
DEST=".data"
TAG="data-v1"
mkdir -p "$DEST"

# The two canonical tables (see data/SCHEMA.md).
FILES=(trips.parquet zones.parquet)

# Prefer gh (handles the release API + private repos); fall back to the public URL.
have_gh=0; command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && have_gh=1

# Resolve owner/repo from git if possible, else default to the canonical sandbox.
slug="$(git config --get remote.origin.url 2>/dev/null \
        | sed -E 's#(git@github.com:|https://github.com/)##; s/\.git$//')"
slug="${slug:-republic-of-letters/sandbox}"

for f in "${FILES[@]}"; do
  out="$DEST/$f"
  if [ -f "$out" ]; then echo "have $out"; continue; fi
  echo "downloading $f ..."
  if [ "$have_gh" -eq 1 ]; then
    gh release download "$TAG" --repo "$slug" --pattern "$f" --dir "$DEST" --clobber
  else
    curl -fsSL -o "$out" \
      "https://github.com/$slug/releases/download/$TAG/$f"
  fi
done

echo
echo "data ready in $DEST/"
echo "to run a round locally:"
echo "    export DATA_ROOT=\"$(pwd)/$DEST\""
echo "    cd exchange/<your-round> && python run.py"
