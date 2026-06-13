#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Starting setup..."
echo "========================================"

./base-setup.sh
./dotfiles-setup.sh
./install-flatpaks.sh
./restore-kebindings.sh
./restore-gnome-favorites.sh
./install-extensions.sh

echo "========================================"
echo "Setup completed!"
echo "========================================"
