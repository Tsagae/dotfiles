#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Installing oh-my-zsh..."
echo "========================================"

rm -rf ~/.oh-my-zsh
rm -rf ~/.zsh_custom
mkdir -p ~/.zsh_custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_custom/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "========================================"
echo "Removing old target files..."
echo "========================================"

rm -f ~/.zshrc
rm -f ~/.gitconfig
rm -f ~/.config/micro/bindings.json
rm -f ~/.config/micro/settings.json
mkdir -p ~/.config/micro

echo "========================================"
echo "Applying chezmoi source state..."
echo "========================================"

./bootstrap-chezmoi.sh

echo "========================================"
echo "Setting default shell..."
echo "========================================"

sudo chsh -s "$(command -v zsh)" "$USER" # doing it with sudo just for automation since chsh requires password input
