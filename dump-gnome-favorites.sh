#!/bin/bash

# Exit immediately if a command fails
set -e

gsettings get org.gnome.shell favorite-apps > ./dump_gnome_favorites

echo "========================================"
echo "Favorite apps dump successful!"
echo "========================================"
