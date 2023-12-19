#!/bin/bash

# Function to add an app to GNOME dock favorites
add_to_gnome_dock() {
    local desktop_file=$1
    local current_favorites=$(gsettings get org.gnome.shell favorite-apps)
    local updated_favorites=$(echo $current_favorites | sed "s/]/, '$desktop_file']/")
    gsettings set org.gnome.shell favorite-apps "$updated_favorites"
}

# Function to install a package
install_package() {
    local package_name=$1
    local desktop_file=$2
    echo "Installing $package_name..."
    sudo apt install -y $package_name
    add_to_gnome_dock "$desktop_file"
}

# Function to download and install a .deb package
install_deb_package() {
    local package_name=$1
    local desktop_file=$2
    local package_url=$3
    echo "Downloading and installing $package_name..."
    wget -O /tmp/$package_name.deb $package_url
    sudo apt install -y /tmp/$package_name.deb
    rm -f /tmp/$package_name.deb
    add_to_gnome_dock "$desktop_file"
}

# Function to add a repository and install a package
install_from_repo() {
    local package_name=$1
    local desktop_file=$2
    local keyring=$3
    local keyring_url=$4
    local repo_entry=$5
    local repo_list=$6
    echo "Adding repository for $package_name..."
    sudo curl -fsSLo $keyring $keyring_url
    echo $repo_entry | sudo tee $repo_list
    sudo apt update
    sudo apt install -y $package_name
    add_to_gnome_dock "$desktop_file"
}

# Function to add Terminal to the far left of the dock
add_terminal_to_dock() {
    local current_favorites=$(gsettings get org.gnome.shell favorite-apps)
    local updated_favorites="['org.gnome.Terminal.desktop', ${current_favorites:1:-1}]"
    gsettings set org.gnome.shell favorite-apps "$updated_favorites"
}

# Ask user to install curl
read -p "Curl is necessary to add the repos and install the packages used by this script. \nWould you like to install curl? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_package "curl" ""
fi

# Ask user to install Brave browser
read -p "Would you like to install the Brave browser? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_from_repo "brave-browser" "brave-browser.desktop" "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
        "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
        "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        "/etc/apt/sources.list.d/brave-browser-release.list"
fi

# Ask user to install Element Desktop
read -p "Would you like to install Element Desktop? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_from_repo "element-desktop" "element-desktop.desktop" "/usr/share/keyrings/element-io-archive-keyring.gpg" \
        "https://packages.element.io/debian/element-io-archive-keyring.gpg" \
        "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" \
        "/etc/apt/sources.list.d/element-io.list"
fi

# Ask user to install Visual Studio Code
read -p "Would you like to install Visual Studio Code? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_from_repo "code" "code.desktop" "/usr/share/keyrings/packages.microsoft.gpg" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        "/etc/apt/sources.list.d/vscode.list"
fi

# Ask user to install Mark Text
read -p "Would you like to install Mark Text? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    marktext_deb_url="https://github.com/marktext/marktext/releases/download/v[VERSION]/marktext-amd64.deb"
    install_deb_package "marktext" "marktext.desktop" "$marktext_deb_url"
fi

# Ask user to install Obsidian
read -p "Would you like to install Obsidian? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_deb_package "obsidian" "obsidian.desktop" "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.4.16/obsidian_1.4.16_amd64.deb"
fi

# Ask user to install Spotify
read -p "Would you like to install Spotify? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_from_repo "spotify-client" "spotify.desktop" "/etc/apt/trusted.gpg.d/spotify.gpg" \
        "https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg" \
        "deb http://repository.spotify.com stable non-free" \
        "/etc/apt/sources.list.d/spotify.list"
fi

# Ask user to Prettify the Gnome Desktop
read -p "Would you like to make Gnome a bit more normal looking like Windows and OSX? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Prettify the Gnome Desktop and add Terminal to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.desktop.background show-desktop-icons false
    gsettings set org.gnome.nautilus.desktop icon-size 'small'
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    add_terminal_to_dock
else
    echo "Skipping Gnome Prettification."
fi

# Ask user to remove Snap
read -p "Snap is a dogshit way to run applications in Linux, would you like to remove Snap? [y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    echo "Let's take out the trash!"
    sudo apt-get autoremove --purge snapd
    sudo apt-mark hold snapd
    sudo apt-get install gnome-software --no-install-recommends
fi
