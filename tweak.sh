#!/bin/bash

# Check for sudo privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Function to install a package
install_package() {
    echo "Installing $1..."
    sudo apt install -y $1
}

# Function to add a repository and install a package
install_from_repo() {
    echo "Adding repository for $1..."
    sudo curl -fsSLo $2 $3
    echo $4 | sudo tee $5
    sudo apt update
    sudo apt install -y $1
}

# Ask user to install curl
read -p "Would you like to install curl? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_package "curl"
fi

# Ask user to install Brave browser
read -p "Would you like to install the Brave browser? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_from_repo "brave-browser" "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
        "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
        "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        "/etc/apt/sources.list.d/brave-browser-release.list"
fi

# Ask user to remove Snap
read -p "Snap is a dogshit way to run applications in Linux, would you like to remove Snap? [y/n] " answer
case $answer in
    [Yy]* )
        echo "Let's take out the trash!"
        apt-get autoremove --purge snapd
        apt-mark hold snapd
        apt-get install gnome-software --no-install-recommends
        ;;
    [Nn]* )
        echo "Keeping for now"
        ;;
    * )
        echo "Please answer yes or no."
        exit 1
        ;;
esac

# Ask user to install VSCode
read -p "Would you like to install Visual Studio Code? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Add Microsoft repository for VSCode
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    # Update package lists and install VSCode
    sudo apt-get update
    sudo apt-get install -y code
else
    echo "Skipping VSCode installation."
fi

# Prettify the Gnome Desktop
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.nautilus.desktop icon-size 'small'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

# Continue with the rest of your script...
