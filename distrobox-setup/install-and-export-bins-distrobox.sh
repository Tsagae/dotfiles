#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

# --- Configuration ---
BOX_NAME="fedorabox"
EXPORT_PATH="/var/home/matteo/.local/bin"

# Define your list of binaries here
BINARIES=(
    "wol"
    "rsync"
    "tldr"
)
# --- Execution ---
echo "========================================"
echo "Installing packages: ${BINARIES[*]}"
echo "========================================"

# 1. Update container
distrobox-enter -n "$BOX_NAME" -- sudo dnf up -y

# 2. Install all packages in a single command
# "${BINARIES[@]}" expands the array into a space-separated list for dnf
distrobox-enter -n "$BOX_NAME" -- sudo dnf install -y "${BINARIES[@]}"

# 3. Check if the bulk installation succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Installation successful! Exporting..."
    echo "========================================"

    # 4. Loop through the array to export each binary individually
    for PKG in "${BINARIES[@]}"; do
        echo "--> Exporting $PKG to $EXPORT_PATH..."
        distrobox-enter -n "$BOX_NAME" -- distrobox-export --bin "/usr/bin/$PKG" --export-path "$EXPORT_PATH"
    done

    echo ""
    echo "All done! Your packages are ready to use."
else
    echo ""
    echo "Error: The dnf installation failed. Aborting the export process."
    exit 1
fi

# This script assumes that the package name you install via dnf matches the exact name of the binary located in /usr/bin/.
# For tools like wol, htop, or fzf, this maps perfectly 1:1. However, if you ever install a package where the binary name differs
# from the package name (for example, installing the bind-utils package to get the dig binary), the export step will fail
# because it will look for /usr/bin/bind-utils. For standard single-binary packages, this will work perfectly.
