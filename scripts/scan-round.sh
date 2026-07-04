#!/usr/bin/env bash
# Static safety triage for a round's code, run by the Runner BEFORE executing it on
# the data server (AGENTS.md §5.2). It greps for risky patterns and flags them.
#
#   bash scripts/scan-round.sh exchange/R007-some-slug
#
# This is triage, NOT proof. A clean scan means "nothing obvious"; the Runner still
# reads the code. A hit doesn't always mean malice (could be a false positive) — it
# means "stop and look". Exit 1 if any HIGH-risk pattern is found, else 0.
#
# Proposers can run it on their own round before opening the PR to avoid rejection.
# Patterns are POSIX ERE (portable across GNU and BSD grep) — no \b, \s, or lookahead.
set -uo pipefail

# Tables data/SCHEMA.md marks "never load whole", as an ERE alternation
# (e.g. 'trades|ticks'). Set per project — SETUP.md step 4. Empty = check skipped.
BIG_TABLES_ERE="${BIG_TABLES_ERE:-}"

target="${1:-.}"
[ -d "$target" ] || { echo "usage: $0 <round-folder>" >&2; exit 2; }

files=$(find "$target" -type f \( -name '*.py' -o -name '*.sh' -o -name '*.ipynb' \
        -o -name '*.R' -o -name '*.jl' \) -not -path '*/result/*')
if [ -z "$files" ]; then echo "no code files under $target — nothing to scan"; exit 0; fi

hits=0
scan() {  # scan <severity> <label> <ere-pattern>
  local sev="$1" label="$2" pat="$3" found
  found=$(grep -nEH "$pat" $files 2>/dev/null) || true
  [ -z "$found" ] && return 0
  echo "  [$sev] $label"
  printf '%s\n' "$found" | sed 's/^/      /'
  [ "$sev" = "HIGH" ] && hits=$((hits + 1))
  return 0
}

echo "scanning: $target"
echo

# --- HIGH: outbound network / exfiltration ---------------------------------
scan HIGH "network egress" \
  'import[[:space:]]+(requests|httpx|aiohttp|urllib|socket|ftplib|smtplib|telnetlib|paramiko|fabric)|(requests|httpx|aiohttp|urllib|urllib2|urllib3|socket|paramiko)\.[a-zA-Z]|(curl|wget|nc|scp|rsync)[[:space:]]'
# --- HIGH: shell / process spawn -------------------------------------------
scan HIGH "shell or process spawn" \
  'os\.(system|popen|exec[lv]|spawn)|subprocess|pty\.|commands\.getoutput'
# --- HIGH: dynamic code execution ------------------------------------------
# Match builtin eval/exec/compile only — NOT method calls like re.compile() or
# df.eval() (excluded via a non-identifier, non-dot char before the name).
scan HIGH "dynamic code execution" \
  '(^|[^A-Za-z0-9_.])(eval|exec|compile)\(|__import__\(|pickle\.load|marshal\.load|base64\.(b64decode|decodebytes)|\.fromhex\('
# --- HIGH: destructive filesystem ------------------------------------------
scan HIGH "deletes/mutates files" \
  'shutil\.rmtree|os\.remove\(|os\.unlink\(|os\.rmdir\(|os\.rename\(|os\.replace\(|rm[[:space:]]+-rf'
# --- HIGH: secrets / other users data --------------------------------------
scan HIGH "secret / credential access" \
  '\.ssh|id_rsa|\.aws|/etc/passwd|/etc/shadow|keychain|netrc|(TOKEN|SECRET|PASSWORD|API_?KEY)'
# --- HIGH: runtime package / code fetch ------------------------------------
scan HIGH "installs packages / fetches code at runtime" \
  '(pip|pip3|apt|apt-get|brew)[[:space:]]+install|git[[:space:]]+clone'

# --- WARN: operational, not malicious --------------------------------------
scan WARN "writes via open(...,'w') — confirm the path is under ./result/" \
  "open\([^,]*,[[:space:]]*['\"]w"
if [ -n "$BIG_TABLES_ERE" ]; then
  scan WARN "may load a never-load-whole table eagerly (use scan_parquet + predicate / duckdb)" \
    "read_parquet\([^)]*($BIG_TABLES_ERE)"
fi

# environment access beyond DATA_ROOT (inline so we can exclude the allowed var)
env_found=$(grep -nEH 'os\.environ|getenv\(' $files 2>/dev/null | grep -v 'DATA_ROOT' || true)
if [ -n "$env_found" ]; then
  echo "  [WARN] environment access beyond DATA_ROOT"
  printf '%s\n' "$env_found" | sed 's/^/      /'
fi

echo
if [ "$hits" -gt 0 ]; then
  echo "SCAN: $hits HIGH-risk pattern group(s) found — DO NOT run until reviewed (AGENTS.md §5.2)"
  exit 1
else
  echo "SCAN: no HIGH-risk patterns. Still read the code before running."
  exit 0
fi
