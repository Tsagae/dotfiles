#!/bin/bash

# Exit immediately if a command fails
set -e

cat ./keybindings-dump/dump_media-keys | dconf load /org/gnome/settings-daemon/plugins/media-keys/
cat ./keybindings-dump/dump_wm_keybindings | dconf load /org/gnome/desktop/wm/keybindings/
cat ./keybindings-dump/dump_shell_keybindings | dconf load /org/gnome/shell/keybindings/
cat ./keybindings-dump/dump_mutter_keybindings | dconf load /org/gnome/mutter/keybindings/
cat ./keybindings-dump/dump_wayland_keybindings | dconf load /org/gnome/mutter/wayland/keybindings/

echo "========================================"
echo "Keybindings restore successful!"
echo "========================================"
