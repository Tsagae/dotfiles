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
echo "Installing ${#PACKAGES[@]} packages..."
echo "========================================"

sudo dnf install -y "${PAKCAGES[@]}"

echo "========================================"
echo "Running dnf clean..."
echo "========================================"

sudo dnf clean all
