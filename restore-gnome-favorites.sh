#!/bin/bash

# Exit immediately if a command fails
set -e

gsettings set org.gnome.shell favorite-apps "$(cat ./dump_gnome_favorites)"

echo "========================================"
echo "Favorite apps restore successful!"
echo "========================================"
