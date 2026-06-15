#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

# --- Configuration ---

BASE_FLATPAKS=( # all from flathub
    "com.mattjakeman.ExtensionManager"
	"dev.vencord.Vesktop"
	"org.gnome.NetworkDisplays"
	"de.swsnr.turnon"
	"com.github.tchx84.Flatseal"
	"org.mozilla.thunderbird"
	"com.spotify.Client"
	"com.jeffser.Nocturne"
	"org.mozilla.thunderbird"
	"org.signal.Signal"
)

UTILITY_FLATPAKS=(
#    "org.gnome.Solanum"
#	 "org.zdoom.UZDoom"
#    "org.gnome.gitlab.YaLTeR.Identity"
#    "io.httpie.Httpie"
#    "io.github.fizzyizzy05.binary"
#    "org.geeqie.Geeqie"
#    "dev.bragefuglseth.Keypunch"
#    "io.gitlab.adhami3310.Converter"
#	 "io.gitlab.liferooter.TextPieces"
#	 "se.sjoerd.Graphs"
#	 "ca.littlesvr.asunder"
#	 "org.videolan.VLC"
)

ALL_FLATPAKS=("${BASE_FLATPAKS[@]}" "${UTILITY_FLATPAKS[@]}")

echo "========================================"
echo "Updating installed Flatpaks..."
echo "========================================"

flatpak update -y

echo "========================================"
echo "Installing ${#ALL_FLATPAKS[@]} Flatpaks in total..."
echo "========================================"

flatpak install -y flathub "${ALL_FLATPAKS[@]}"

# Check if the installation succeeded
if [ $? -eq 0 ]; then
    echo "========================================"
    echo "Success: All Flatpaks are installed and ready to go!"
    echo "========================================"
else
    echo "========================================"
    echo "Error: Something went wrong during the Flatpak installation."
    echo "========================================"
    exit 1
fi
