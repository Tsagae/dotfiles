#sudo rm -f /usr/bin/flatpak

sudo dnf install flatpak  # Use 'apt install flatpak' for Ubuntu/Debian, or 'pacman -S flatpak' for Arch

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install an app
#flatpak install flathub com.unity.UnityHub
flatpak install flathub com.jetbrains.Rider

# Run the app
#flatpak run com.unity.UnityHub
flatpak run com.jetbrains.Rider

# A Quick Note on Sandboxing
# Because Flatpak uses bubblewrap to sandbox applications, you are essentially running a sandbox (Flatpak) inside a sandbox (Podman/Docker via Distrobox).
# Because you created the container with the --init flag, Podman usually handles the namespace permissions well enough to allow this nested sandboxing,
# but be aware that heavily restricted host systems (like immutable distros with strict SELinux policies) might occasionally require you to pass --unshare-all
# or additional root capabilities to the container during creation if Bubblewrap throws permission errors.
