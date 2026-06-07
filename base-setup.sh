#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Updating installed packages..."
echo "========================================"

sudo dnf up -y

echo "========================================"
echo "Lazygit installation..."
echo "========================================"

sudo dnf install -y dnf-plugins-core
sudo dnf copr enable dejan/lazygit -y

echo "========================================"
echo "Adding rpmfusion Nonfree..."
echo "========================================"

# rpmfusion Nonfree
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

PAKCAGES=(
	"zsh"
	"stow"
	"micro"
	"btop"
	"util-linux"
	"lazygit"
	"gnome-tweaks"
	"steam"
)


echo "========================================"
echo "Installing ${#ALL_FLATPAKS[@]}..."
echo "========================================"

sudo dnf install -y "${PAKCAGES[@]}"

echo "========================================"
echo "Running dnf clean..."
echo "========================================"

sudo dnf clean all

echo "========================================"
echo "Installing oh-my-zsh..."
echo "========================================"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_custom/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "========================================"
echo "Symlinking doftiles..."
echo "========================================"

rm ~/.zshrc
stow -t ~ dotfiles

rm ~/.config/micro/bindings.json
rm ~/.config/micro/settings.json
stow -t ~/.config/micro micro

echo "========================================"
echo "Setting default shell..."
echo "========================================"

sudo chsh -s $(which zsh) matteo # doing it with sudo just for automation since chsh requires password input
# parametrize with the name of the user that runs the script?

