#!/bin/bash

# Exit immediately if a command fails
set -e

echo "========================================"
echo "Setting up distrobox containers..."
echo "========================================"

sudo dnf install -y distrobox

mkdir -p ~/distrobox-homes
podman build -t my-dev-base .
distrobox-assemble create -R

echo "========================================"
echo "Distrobox setup complete!"
echo "========================================"
