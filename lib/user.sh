# shellcheck shell=bash
# User-level setup: oh-my-zsh, symlinks, ~/.ssh link, profile snippets.
# Everything here runs as the target user and only touches $HOME.

ZSH_CUSTOM_DIR="$HOME/.zsh_custom"
ZSHRC_D="$HOME/.zshrc.d"

_git_clone_or_pull() { # <url> <dir>
	if [[ -d "$2/.git" ]]; then
		git -C "$2" pull --ff-only --quiet || warn "Could not update $2"
	else
		rm -rf "$2"
		git clone --depth=1 --quiet "$1" "$2"
	fi
}

install_oh_my_zsh() {
	section "oh-my-zsh"
	have git || die "git is required"
	# Plain git clone instead of the upstream installer: no prompts, no chsh,
	# and it does not overwrite ~/.zshrc.
	_git_clone_or_pull https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
	mkdir -p "$ZSH_CUSTOM_DIR/plugins" "$ZSH_CUSTOM_DIR/themes"
	_git_clone_or_pull https://github.com/zsh-users/zsh-autosuggestions.git \
		"$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
	ok "oh-my-zsh ready"
}

# Symlink one file, backing up whatever was there before.
_link() { # <source> <target>
	local src="$1" dst="$2"
	if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
		return 0
	fi
	mkdir -p "$(dirname "$dst")"
	if [[ -e "$dst" || -L "$dst" ]]; then
		local backup
		backup="$BACKUP_DIR/${dst#"$HOME"/}"
		mkdir -p "$(dirname "$backup")"
		mv "$dst" "$backup"
		log "Backed up $dst -> $backup"
	fi
	ln -s "$src" "$dst"
	log "Linked $dst -> $src"
}

# Mirror $DOTFILES_DIR/home into $HOME, file by file.
link_dotfiles() {
	section "Linking dotfiles into $HOME"
	BACKUP_DIR="$HOME/.local/state/dotfiles/backup/$(date +%Y%m%d-%H%M%S)"
	local src rel
	while IFS= read -r -d '' src; do
		rel="${src#"$DOTFILES_DIR/home/"}"
		_link "$src" "$HOME/$rel"
	done < <(find "$DOTFILES_DIR/home" \( -type f -o -type l \) -print0)
	_link "$DOTFILES_DIR/dotfiles" "$HOME/.local/bin/dotfiles"
	mkdir -p "$ZSHRC_D"
	ok "Dotfiles linked"
}

# Link zsh snippets of the selected profiles into ~/.zshrc.d/ and remove
# stale links pointing into the repo.
link_profile_snippets() {
	mkdir -p "$ZSHRC_D"
	local l
	for l in "$ZSHRC_D"/*.zsh; do
		[[ -L "$l" && "$(readlink "$l")" == "$DOTFILES_DIR/"* ]] && rm -f "$l"
	done
	local p f
	for p in "$@"; do
		for f in "$DOTFILES_DIR/profiles/$p"/*.zsh; do
			[[ -e "$f" ]] || continue
			ln -sfn "$f" "$ZSHRC_D/$p-$(basename "$f")"
			log "Linked $ZSHRC_D/$p-$(basename "$f")"
		done
	done
}

# ~/.ssh -> host's ~/.ssh mounted read-only at $HOST_SSH_MOUNT.
link_host_ssh() {
	if [[ ! -d "$HOST_SSH_MOUNT" ]]; then
		warn "$HOST_SSH_MOUNT not mounted: skipping ~/.ssh link (see README, distrobox.ini volume)"
		return 0
	fi
	if [[ -L "$HOME/.ssh" && "$(readlink "$HOME/.ssh")" == "$HOST_SSH_MOUNT" ]]; then
		return 0
	fi
	if [[ -e "$HOME/.ssh" || -L "$HOME/.ssh" ]]; then
		local backup
		backup="$HOME/.ssh.bak-$(date +%Y%m%d-%H%M%S)"
		mv "$HOME/.ssh" "$backup"
		log "Moved existing ~/.ssh to $backup"
	fi
	ln -s "$HOST_SSH_MOUNT" "$HOME/.ssh"
	ok "Linked ~/.ssh -> $HOST_SSH_MOUNT (read-only)"
}

# Run the user-level setup scripts of the given profiles.
run_profile_setups() {
	local p
	for p in "$@"; do
		if [[ -f "$DOTFILES_DIR/profiles/$p/setup.sh" ]]; then
			section "Profile '$p': user setup"
			bash "$DOTFILES_DIR/profiles/$p/setup.sh"
		fi
	done
}

# Make sure the repo can be pushed to over SSH while it was cloned via HTTPS.
set_push_url() {
	[[ -d "$DOTFILES_DIR/.git" ]] || return 0
	local cur
	cur="$(git -C "$DOTFILES_DIR" remote get-url --push origin 2>/dev/null || true)"
	if [[ "$cur" == https://github.com/* ]]; then
		git -C "$DOTFILES_DIR" remote set-url --push origin "$DOTFILES_PUSH_URL"
		log "Push URL set to $DOTFILES_PUSH_URL"
	fi
}
