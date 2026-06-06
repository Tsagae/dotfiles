#!/bin/bash

# Exit immediately if a command fails
set -e

dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ./keybindings-dump/dump_media-keys
dconf dump /org/gnome/desktop/wm/keybindings/ > ./keybindings-dump/dump_wm_keybindings
dconf dump /org/gnome/shell/keybindings/ > ./keybindings-dump/dump_shell_keybindings
dconf dump /org/gnome/mutter/keybindings/ > ./keybindings-dump/dump_mutter_keybindings
dconf dump /org/gnome/mutter/wayland/keybindings/ > ./keybindings-dump/dump_wayland_keybindings

echo "========================================"
echo "Keybindings dump successful!"
echo "========================================"
