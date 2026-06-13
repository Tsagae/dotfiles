#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

# --- Configuration ---
EXTENSIONS=( # extensions uiids
    "launch-new-instance%40gnome-shell-extensions.gcampax.github.com"
    "appindicatorsupport%40rgcjonas.gmail.com"
    "quick-settings-audio-panel%40rayzeq.github.io"
    "workspaces-by-open-apps%40favo02.github.com"
    "ddterm%40amezin.github.com"
    "caffeine%40patapon.info"
)

echo "========================================"
echo "Installing gnome extensions..."
echo "========================================"

# 1. Create a new empty array to hold the formatted URLs
INSTALL_ARGS=()

# 2. Loop through the extensions and build the URLs
for ext in "${EXTENSIONS[@]}"; do
    INSTALL_ARGS+=("gnome-extensions://${ext}/?action=install")
done

# 3. Execute the command using the array as arguments
# We place this directly in the 'if' statement so it works properly alongside 'set -e'
if gnome-browser-connector "${INSTALL_ARGS[@]}"; then
    echo "========================================"
    echo "Success: All extensions have been installed successfully!"
    echo "========================================"
else
    echo "========================================"
    echo "Error: Something went wrong during the extensions installation."
    echo "========================================"
    exit 1
fi
