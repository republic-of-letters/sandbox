#!/usr/bin/env bash
# The protocol guard. Runs in CI on every PR; run it locally before pushing.
# Fails (exit 1) if the data boundary or round structure is violated.
set -uo pipefail

cd "$(dirname "$0")/.."

MAX_BYTES=${MAX_BYTES:-5242880}        # 5 MB — the raw-data tripwire
DATA_EXT='parquet|feather|arrow|duckdb|db|h5|hdf5|pkl|npy|npz'
fail=0

note() { printf '  %s\n' "$1"; }

# files to inspect: everything tracked, minus .git
files=$(find . -type f -not -path './.git/*')

echo "[1/4] file size <= $((MAX_BYTES / 1024 / 1024)) MB"
while IFS= read -r f; do
  [ -z "$f" ] && continue
  size=$(wc -c < "$f" | tr -d ' ')
  if [ "$size" -gt "$MAX_BYTES" ]; then
    note "TOO BIG ($((size / 1024)) KB): $f"
    fail=1
  fi
done <<< "$files"

echo "[2/4] no raw-data file extensions"
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if printf '%s' "$f" | grep -qiE "\.($DATA_EXT)\$"; then
    note "DATA FILE (must not be committed): $f"
    fail=1
  fi
done <<< "$files"

echo "[3/4] every exchange/R*/ round has an ASK.md"
for d in exchange/R[0-9]*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}ASK.md" ]; then
    note "MISSING ASK.md: $d"
    fail=1
  fi
done

echo "[4/4] every topics/T*/ topic has a TOPIC.md"
for d in topics/T[0-9]*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}TOPIC.md" ]; then
    note "MISSING TOPIC.md: $d"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK — protocol checks pass"
else
  echo "FAILED — see above (AGENTS.md §11)"
fi
exit "$fail"
