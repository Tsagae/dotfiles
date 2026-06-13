#!/bin/bash

# Exit immediately if a command fails
set -e

#https://distrobox.it/useful_tips/
#Resolve “Error cannot open display: :0”
#If your container is not able to connect to your host xserver, make sure to install xhost on the host machine and run xhost +si:localuser:$USER. If you wish to enable this functionality on future reboots add the above command to your ~/.distroboxrc

#-$ cat ~/.distroboxrc
#xhost +si:localuser:$USER >/dev/null


./setup-containers.sh
./install-and-export-bins-distrobox.sh

echo "========================================"
echo "Distrobox containers and binaries setup complete!"
echo "========================================"
