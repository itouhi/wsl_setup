#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/ssh_aliases_init.sh [TARGET_FILE]

Examples:
  scripts/ssh_aliases_init.sh
  scripts/ssh_aliases_init.sh ~/.bash_aliases

If TARGET_FILE is omitted, ~/.bash_aliases is used when it exists.
Otherwise, ~/.bashrc is used.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TARGET_FILE="${1:-}"
if [[ -z "$TARGET_FILE" ]]; then
  if [[ -f "$HOME/.bash_aliases" ]]; then
    TARGET_FILE="$HOME/.bash_aliases"
  else
    TARGET_FILE="$HOME/.bashrc"
  fi
fi

mkdir -p "$(dirname "$TARGET_FILE")"
touch "$TARGET_FILE"

ensure_alias() {
  local name="$1"
  local value="$2"
  local file="$3"
  local alias_line="alias ${name}='${value}'"

  if grep -Eq "^[[:space:]]*alias[[:space:]]+${name}=" "$file"; then
    sed -i -E "s|^[[:space:]]*alias[[:space:]]+${name}=.*$|${alias_line}|" "$file"
  else
    printf '\n%s\n' "$alias_line" >> "$file"
  fi
}

ensure_alias "ssh" "ssh.exe" "$TARGET_FILE"
ensure_alias "ssh-add" "ssh-add.exe" "$TARGET_FILE"

echo "Configured SSH aliases in: $TARGET_FILE"
echo "  alias ssh='ssh.exe'"
echo "  alias ssh-add='ssh-add.exe'"
echo "Run: source $TARGET_FILE"
