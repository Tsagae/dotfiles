# shellcheck shell=bash
# Shared helpers. Sourced by ./dotfiles and the modules in lib/.

DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-https://github.com/Tsagae/dotfiles.git}"
DOTFILES_PUSH_URL="${DOTFILES_PUSH_URL:-git@github.com:Tsagae/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

# Where the host's ~/.ssh is bind-mounted (read-only) inside distroboxes.
HOST_SSH_MOUNT="${HOST_SSH_MOUNT:-/etc/host-ssh}"
# Marker inside the *container filesystem* (not the home): recreating a box
# with the same home re-runs the system part of the setup.
# shellcheck disable=SC2034 # used by ./dotfiles
CONTAINER_MARKER="/var/lib/dotfiles/bootstrapped"

# ---------------------------------------------------------------- logging ---
if [[ -t 1 ]]; then
	_c_blue=$'\033[1;34m' _c_yellow=$'\033[1;33m' _c_red=$'\033[1;31m' _c_green=$'\033[1;32m' _c_off=$'\033[0m'
else
	_c_blue='' _c_yellow='' _c_red='' _c_green='' _c_off=''
fi
section() { printf '\n%s========== %s ==========%s\n' "$_c_blue" "$*" "$_c_off"; }
log() { printf '%s==>%s %s\n' "$_c_blue" "$_c_off" "$*"; }
ok() { printf '%s==>%s %s\n' "$_c_green" "$_c_off" "$*"; }
warn() { printf '%s==> WARNING:%s %s\n' "$_c_yellow" "$_c_off" "$*" >&2; }
die() {
	printf '%s==> ERROR:%s %s\n' "$_c_red" "$_c_off" "$*" >&2
	exit 1
}

have() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------ environment ---
is_container() {
	[[ -e /run/.containerenv || -e /.dockerenv || -n "${CONTAINER_ID:-}" ]]
}

is_fedora() {
	[[ -r /etc/os-release ]] && grep -qE '^ID=fedora$' /etc/os-release
}

# The (non-root) user whose home we configure. When running as root
# (distrobox init_hooks), this is the owner of $HOME, which distrobox sets
# to the box's home directory.
resolve_target_user() {
	if [[ -n "${DOTFILES_USER:-}" ]]; then
		TARGET_USER="$DOTFILES_USER"
	elif ((EUID != 0)); then
		TARGET_USER="$(id -un)"
	elif [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != root ]]; then
		TARGET_USER="$SUDO_USER"
	else
		TARGET_USER="$(stat -c %U "${HOME:-/root}")"
	fi
	if ((EUID != 0)); then
		TARGET_HOME="$HOME"
	elif [[ -n "${DOTFILES_HOME:-}" ]]; then
		TARGET_HOME="$DOTFILES_HOME"
	elif [[ "$(stat -c %U "${HOME:-/root}")" == "$TARGET_USER" ]]; then
		TARGET_HOME="$HOME"
	else
		TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
	fi
	[[ "$TARGET_USER" != root ]] || die "Refusing to configure root's home. Set DOTFILES_USER."
	export TARGET_USER TARGET_HOME
}

# Run a command as root (directly when already root, else through sudo).
as_root() {
	if ((EUID == 0)); then "$@"; else sudo "$@"; fi
}

# Run a command as the target user (drops privileges when running as root).
as_user() {
	if ((EUID != 0)); then
		"$@"
		return
	fi
	local envs=(HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER"
		DOTFILES_USER="$TARGET_USER" DOTFILES_HOME="$TARGET_HOME"
		PATH="$TARGET_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin")
	if have runuser; then
		runuser -u "$TARGET_USER" -- env "${envs[@]}" "$@"
	else
		su "$TARGET_USER" -s /bin/sh -c 'exec env "$@"' sh "${envs[@]}" "$@"
	fi
}
