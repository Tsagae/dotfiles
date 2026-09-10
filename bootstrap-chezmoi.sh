#!/usr/bin/env bash

set -euo pipefail

if ! command -v chezmoi >/dev/null 2>&1; then
	sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
	case ":${PATH}:" in *:"$HOME/.local/bin":*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
fi

repo_url="${1:-}"

if [[ -z "$repo_url" ]]; then
	repo_url="$(git remote get-url origin 2>/dev/null || true)"
fi

if [[ -z "$repo_url" ]]; then
	echo "Usage: $0 <repo-url>"
	echo "Or run it from inside a cloned repo with a configured origin remote."
	exit 1
fi

chezmoi init --apply "$repo_url"