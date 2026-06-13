#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Installing oh-my-zsh..."
echo "========================================"

rm -rf ~/.oh-my-zsh
rm -rf ~/.zsh_custom
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_custom/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "========================================"
echo "Symlinking doftiles..."
echo "========================================"

rm -f ~/.zshrc
rm -f ~/.gitconfig
stow -t ~ dotfiles

rm -f ~/.config/micro/bindings.json
rm -f ~/.config/micro/settings.json
mkdir -p ~/.config/micro
stow -t ~/.config/micro micro

echo "========================================"
echo "Setting default shell..."
echo "========================================"

sudo chsh -s $(which zsh) matteo # doing it with sudo just for automation since chsh requires password input
# parametrize with the name of the user that runs the script?
