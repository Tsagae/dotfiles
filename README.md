# Personal Config Migration

This repository is being migrated to a chezmoi source repo.

## Current shape

- `dot_zshrc`, `dot_gitconfig`, and `dot_config/micro/*` are now the source-of-truth files for chezmoi.
- `.ssh` and shell history are intentionally left outside the repo.

## Intended flow

1. On a fresh host, clone this repo and run `./complete-setup.sh`.
2. Inside a distrobox container, clone this repo and run `./bootstrap-chezmoi.sh`.
3. Keep `.ssh` and shell history outside chezmoi.

## Next migration step

Decide whether distrobox should start self-bootstrapping from this repo or keep using a manual apply step for now.