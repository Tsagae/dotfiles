#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Starting setup..."
echo "========================================"

./base-setup.sh
./install-flatpaks.sh
./restore-kebindings.sh
./restore-gnome-favorites.sh

echo "========================================"
echo "Success: Setup completed!"
echo "Remember to enable this gnome extensions: "
echo "	- Launch New Instance"
echo "	- AppIndicator and KStatusNotifierItem Support"
echo "	- Quick Settings Audio Panel"
echo "	- Workspaces indicator by open apps"
echo "	- ddterm"
echo "========================================"
