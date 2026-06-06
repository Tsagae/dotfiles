#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Starting setup..."
echo "========================================"

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
	"micro"
	"btop"
	"util-linux"
	"stow"
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
echo "Symlinking doftiles and setting default shell..."
echo "========================================"

stow -t ~ dotfiles

sudo chsh -s $(which zsh) matteo # doing it with sudo just for automation since chsh requires password input
# parametrize with the name of the user that runs the script?

./install-flatpaks.sh

echo "========================================"
echo "Success: Setup completed!"
echo "Remember to enable this gnome extensions: "
echo "	- Launch New Instance"
echo "	- AppIndicator and KStatusNotifierItem Support"
echo "	- Quick Settings Audio Panel"
echo "	- Workspaces indicator by open apps"
echo "	- ddterm"
echo "========================================"
