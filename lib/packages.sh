# shellcheck shell=bash
# Cross-distro package installation.
#
# Package list format (packages/*.txt, profiles/*/packages.txt):
#
#   # comment
#   <name>   [<pm>=<alt-name>[,<alt-name2>]] ...
#
# <name> is the package name used by default (Fedora naming).
# <pm>   is one of: dnf apt pacman zypper apk
# Use <pm>=- to skip the package on that package manager.
#
# Example:
#   procps-ng   apt=procps zypper=procps
#   lazygit     apt=-

detect_pm() {
	local pm
	for pm in dnf apt-get pacman zypper apk; do
		if have "$pm"; then
			[[ "$pm" == apt-get ]] && pm=apt
			echo "$pm"
			return
		fi
	done
	echo unknown
}

PM="${PM:-$(detect_pm)}"

# Print resolved package names (one per line) for the current PM.
resolve_packages() {
	local file line name tok key val resolved
	for file in "$@"; do
		[[ -r "$file" ]] || continue
		while IFS= read -r line || [[ -n "$line" ]]; do
			line="${line%%#*}"
			read -r -a toks <<<"$line"
			((${#toks[@]})) || continue
			name="${toks[0]}"
			resolved="$name"
			for tok in "${toks[@]:1}"; do
				key="${tok%%=*}" val="${tok#*=}"
				[[ "$key" == "$PM" ]] && resolved="$val"
			done
			[[ "$resolved" == "-" ]] && continue
			tr ',' '\n' <<<"$resolved"
		done <"$file"
	done
}

_pm_refreshed=0
pkg_refresh() {
	((_pm_refreshed)) && return 0
	_pm_refreshed=1
	case "$PM" in
	apt) as_root env DEBIAN_FRONTEND=noninteractive apt-get update -y ;;
	pacman) as_root pacman -Sy --noconfirm ;;
	zypper) as_root zypper --non-interactive refresh ;;
	apk) as_root apk update ;;
	dnf) : ;;
	esac
}

pkg_upgrade() {
	case "$PM" in
	dnf) as_root dnf upgrade -y ;;
	apt) pkg_refresh && as_root env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y ;;
	pacman) as_root pacman -Syu --noconfirm ;;
	zypper) as_root zypper --non-interactive update ;;
	apk) as_root apk upgrade ;;
	esac
}

_pm_install_cmd() {
	case "$PM" in
	dnf) as_root dnf install -y "$@" ;;
	apt) as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@" ;;
	pacman) as_root pacman -S --needed --noconfirm "$@" ;;
	zypper) as_root zypper --non-interactive install "$@" ;;
	apk) as_root apk add "$@" ;;
	*) return 1 ;;
	esac
}

pkg_is_installed() {
	case "$PM" in
	dnf | zypper) rpm -q --whatprovides "$1" >/dev/null 2>&1 ;;
	apt) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed" ;;
	pacman) pacman -Q "$1" >/dev/null 2>&1 ;;
	apk) apk info -e "$1" >/dev/null 2>&1 ;;
	*) return 1 ;;
	esac
}

# Install packages. Tries one batch first (fast); if that fails, installs them
# one by one and reports the ones that could not be installed (non-fatal).
# Sets PKG_MISSING to the list of packages that failed.
pkg_install() {
	PKG_MISSING=()
	(($#)) || return 0
	[[ "$PM" != unknown ]] || die "No supported package manager found (dnf/apt/pacman/zypper/apk)."
	local todo=() p
	for p in "$@"; do pkg_is_installed "$p" || todo+=("$p"); done
	if ((${#todo[@]} == 0)); then
		log "All ${#} packages already installed."
		return 0
	fi
	log "Installing ${#todo[@]} package(s) with $PM: ${todo[*]}"
	pkg_refresh
	_pm_install_cmd "${todo[@]}" && return 0
	warn "Batch install failed, retrying packages one by one..."
	for p in "${todo[@]}"; do
		_pm_install_cmd "$p" || PKG_MISSING+=("$p")
	done
	((${#PKG_MISSING[@]} == 0)) || warn "Could not install: ${PKG_MISSING[*]}"
	return 0
}

pkg_install_lists() {
	local pkgs=()
	mapfile -t pkgs < <(resolve_packages "$@")
	pkg_install "${pkgs[@]}"
}

# Fedora: enable the lazygit COPR (lazygit is not in the official repos).
fedora_enable_lazygit_copr() {
	[[ "$PM" == dnf ]] || return 0
	if ! dnf copr --help >/dev/null 2>&1; then
		as_root dnf install -y dnf5-plugins || as_root dnf install -y dnf-plugins-core
	fi
	if ! dnf repolist 2>/dev/null | grep -q 'copr.*lazygit'; then
		log "Enabling COPR dejan/lazygit"
		as_root dnf copr enable -y dejan/lazygit
	fi
}

# Fallback for distros without a lazygit package: install the upstream binary
# into /usr/local/bin.
install_lazygit_binary() {
	have lazygit && return 0
	local arch tag tmp
	case "$(uname -m)" in
	x86_64) arch=x86_64 ;;
	aarch64 | arm64) arch=arm64 ;;
	*)
		warn "lazygit: unsupported architecture $(uname -m)"
		return 0
		;;
	esac
	tag="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
		sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')" || true
	[[ -n "$tag" ]] || {
		warn "lazygit: could not determine latest release"
		return 0
	}
	log "Installing lazygit $tag from GitHub releases"
	tmp="$(mktemp -d)"
	curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${tag}/lazygit_${tag}_Linux_${arch}.tar.gz" |
		tar -xz -C "$tmp" lazygit &&
		as_root install -m 0755 "$tmp/lazygit" /usr/local/bin/lazygit
	rm -rf "$tmp"
}
