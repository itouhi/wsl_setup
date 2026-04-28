#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/git_init.sh [USER_NAME] [EMAIL]
  scripts/git_init.sh --name USER_NAME --email EMAIL

If USER_NAME or EMAIL is omitted, you will be prompted to enter it.
EOF
}

USER_NAME=""
EMAIL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      USER_NAME="${2:-}"
      shift 2
      ;;
    --email)
      EMAIL="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "$USER_NAME" ]]; then
        USER_NAME="$1"
      elif [[ -z "$EMAIL" ]]; then
        EMAIL="$1"
      else
        echo "Too many positional arguments: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$USER_NAME" ]]; then
  read -r -p "Git user.name: " USER_NAME
fi

if [[ -z "$EMAIL" ]]; then
  read -r -p "Git user.email: " EMAIL
fi

if [[ -z "$USER_NAME" || -z "$EMAIL" ]]; then
  echo "user.name and user.email are required." >&2
  exit 1
fi

git config --global user.name "$USER_NAME"
git config --global user.email "$EMAIL"

# 1Password SSH agent compatibility on WSL.
git config --global core.sshCommand ssh.exe

echo "Configured global git settings:"
echo "  user.name      = $(git config --global user.name)"
echo "  user.email     = $(git config --global user.email)"
echo "  core.sshCommand= $(git config --global core.sshCommand)"