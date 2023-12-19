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

# Function to download and install a .deb package
install_deb_package() {
    echo "Downloading and installing $1..."
    wget -O /tmp/$1.deb $2
    sudo apt install -y /tmp/$1.deb
    rm -f /tmp/$1.deb
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
fi

# Ask user to install Element Desktop
read -p "Would you like to install Element Desktop? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Add Element repository and install Element Desktop
    sudo apt install -y wget apt-transport-https
    sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
    sudo apt update
    sudo apt install -y element-desktop
fi

# Ask user to install Mark Text
read -p "Would you like to install Mark Text? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Direct link to the Mark Text .deb package
    # Note: Update the link below with the current version's URL
    marktext_deb_url="https://github.com/marktext/marktext/releases/download/v[VERSION]/marktext-amd64.deb"
    install_deb_package "marktext" "$marktext_deb_url"
fi

# Ask user to install Obsidian
read -p "Would you like to install Obsidian? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_deb_package "obsidian" "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.4.16/obsidian_1.4.16_amd64.deb"
fi



# Ask user to Prettify the Gnome Desktop
read -p "Would you like to make Gnome a bit more normal looking like Windows and OSX? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Prettify the Gnome Desktop
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.desktop.background show-desktop-icons false
    gsettings set org.gnome.nautilus.desktop icon-size 'small'
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
else
    echo "Skipping Gnome Prettification."
fi

# Ask user to remove Snap
read -p "Snap is a dogshit way to run applications in Linux, would you like to remove Snap? [y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    echo "Let's take out the trash!"
    apt-get autoremove --purge snapd
    apt-mark hold snapd
    apt-get install gnome-software --no-install-recommends
fi
