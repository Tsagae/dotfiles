#!/bin/bash

# Exit immediately if a command fails
set -e

sudo dnf up -y
sudo dnf install -y dnf-plugins-core
sudo dnf copr enable dejan/lazygit

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

sudo dnf clean all

stow -t ~ ./dotfiles

chsh -s $(which zsh)

./install-flatpaks.sh

echo "========================================"
echo "Success: Setup completed!"
echo "========================================"
