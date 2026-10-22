#!/usr/bin/env bash
# Bootstrap: clone (or update) the dotfiles repo into ~/dotfiles and run it.
#
#   Host:       curl -fsSL https://raw.githubusercontent.com/Tsagae/dotfiles/main/bootstrap.sh | bash -s -- host
#   Distrobox:  curl -fsSL https://raw.githubusercontent.com/Tsagae/dotfiles/main/bootstrap.sh | bash -s -- container [profile...]
#
# In a distrobox this is normally run automatically, as root, by the init_hooks
# in distrobox/distrobox.ini. It is self-contained on purpose (it runs before
# the repo exists).
#
# Environment overrides: DOTFILES_REPO_URL, DOTFILES_BRANCH, DOTFILES_CLONE_DIR,
# DOTFILES_USER, DOTFILES_PROFILES.

set -euo pipefail

# Everything is wrapped in main() so that bash reads the whole script before
# running anything (safe with `curl ... | bash`).
main() {
	REPO_URL="${DOTFILES_REPO_URL:-https://github.com/Tsagae/dotfiles.git}"
	BRANCH="${DOTFILES_BRANCH:-main}"

	say() { printf '\033[1;34m[dotfiles-bootstrap]\033[0m %s\n' "$*"; }
	die() {
		printf '\033[1;31m[dotfiles-bootstrap] ERROR:\033[0m %s\n' "$*" >&2
		exit 1
	}
	have() { command -v "$1" >/dev/null 2>&1; }

	is_container() { [[ -e /run/.containerenv || -e /.dockerenv || -n "${CONTAINER_ID:-}" ]]; }

	mode="${1:-}"
	if [[ "$mode" == host || "$mode" == container ]]; then
		shift
	else
		if is_container; then mode=container; else mode=host; fi
	fi

	# --- who are we configuring? -------------------------------------------------
	if ((EUID == 0)); then
		if [[ -n "${DOTFILES_USER:-}" ]]; then
			user="$DOTFILES_USER"
		elif [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]]; then
			user="$SUDO_USER"
		else
			# distrobox init_hooks: HOME is the box's home, owned by the user.
			user="$(stat -c %U "${HOME:-/root}")"
		fi
		[[ "$user" != root ]] || die "Cannot determine the target user (set DOTFILES_USER)."
		if [[ "$(stat -c %U "${HOME:-/root}")" == "$user" ]]; then
			home="$HOME"
		else
			home="$(getent passwd "$user" | cut -d: -f6)"
		fi
		export DOTFILES_USER="$user" DOTFILES_HOME="$home"
		as_root() { "$@"; }
		as_user() {
			if have runuser; then
				runuser -u "$user" -- env HOME="$home" USER="$user" "$@"
			else
				su "$user" -s /bin/sh -c 'exec env "$@"' sh HOME="$home" USER="$user" "$@"
			fi
		}
	else
		user="$(id -un)"
		home="$HOME"
		as_root() { sudo "$@"; }
		as_user() { "$@"; }
	fi

	clone_dir="${DOTFILES_CLONE_DIR:-$home/dotfiles}"

	# Host setup requires ~/.ssh up front (for git push SSH URL and distrobox volume mounts).
	if [[ "$mode" == host ]]; then
		[[ -d "$home/.ssh" ]] || die "$home/.ssh directory does not exist. Please set up your SSH keys before running host setup."
	fi

	# --- make sure git is available ---------------------------------------------
	if ! have git || ! have curl; then
		say "Installing git/curl"
		if have dnf; then
			as_root dnf install -y git curl ca-certificates
		elif have apt-get; then
			as_root env DEBIAN_FRONTEND=noninteractive apt-get update -y
			as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y git curl ca-certificates
		elif have pacman; then
			as_root pacman -Sy --needed --noconfirm git curl ca-certificates
		elif have zypper; then
			as_root zypper --non-interactive install git curl ca-certificates
		elif have apk; then
			as_root apk add git curl ca-certificates bash
		else
			die "No supported package manager to install git."
		fi
	fi

	# --- clone or update ----------------------------------------------------------
	if [[ -d "$clone_dir/.git" ]]; then
		say "Updating existing clone in $clone_dir"
		as_user git -C "$clone_dir" pull --ff-only --quiet ||
			say "Could not fast-forward $clone_dir (local changes?), using it as is"
	elif [[ -e "$clone_dir" ]]; then
		die "$clone_dir exists and is not a git repository."
	else
		say "Cloning $REPO_URL ($BRANCH) into $clone_dir"
		as_user git clone --quiet --branch "$BRANCH" "$REPO_URL" "$clone_dir"
	fi

	say "Running: dotfiles $mode $*"
	exec "$clone_dir/dotfiles" "$mode" "$@"
}

main "$@"
