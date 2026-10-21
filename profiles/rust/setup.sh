#!/usr/bin/env bash
# Install the Rust toolchain with rustup (user-level, in ~/.cargo and ~/.rustup).
set -euo pipefail
if [[ -x "$HOME/.cargo/bin/rustup" ]]; then
	echo "rustup already installed, updating"
	"$HOME/.cargo/bin/rustup" update
else
	# --no-modify-path: PATH is handled by profiles/rust/env.zsh
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
