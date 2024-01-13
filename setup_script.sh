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

#Function to remove all the loopback devices that Snap uses to access libraries
remove_snap_loopbacks() {
    echo "Removing Snap loopback devices..."
    for loopdev in $(losetup -l | awk '/snap/ {print $1}'); do
        sudo losetup -d "$loopdev" && echo "Detached $loopdev"
    done
    echo "All Snap loopback devices removed."
}


# Ask user to install curl
read -p "Curl is necessary to add the repos and install the packages used by this script. \nWould you like to install curl? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_package "curl" ""
fi


# Ask user to install gnome-tweaks
read -p "gnome-tweaks allows for some modifications to the desktop schema via Tweaks in the application menue \nWould you like to install gnome-tweaks? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    install_package "gnome-tweaks" ""
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
    # Remove existing GPG key file if it exists
    sudo rm -f /usr/share/keyrings/packages.microsoft.gpg

    # Add the GPG key for Visual Studio Code
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
    
    # Add Visual Studio Code repository
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    
    # Update and install Visual Studio Code
    sudo apt update
    sudo apt install -y code
    add_to_gnome_dock "code.desktop"
fi



# Ask user to install Mark Text
read -p "Would you like to install Mark Text? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    latest_release_data=$(curl -s https://api.github.com/repos/marktext/marktext/releases/latest)
    marktext_deb_url=$(echo "$latest_release_data" | grep "browser_download_url.*deb\"" | cut -d '"' -f 4)

    if [ -n "$marktext_deb_url" ]; then
        echo "Downloading and installing Mark Text from $marktext_deb_url"
        wget -O /tmp/marktext.deb "$marktext_deb_url"
        sudo apt install -y /tmp/marktext.deb
        rm -f /tmp/marktext.deb
        add_to_gnome_dock "marktext.desktop"
    else
        echo "Failed to find Mark Text .deb download URL."
    fi
fi

# Ask user to install Obsidian
read -p "Would you like to install Obsidian? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    latest_release_data=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest)
    obsidian_deb_url=$(echo "$latest_release_data" | grep "browser_download_url.*deb\"" | cut -d '"' -f 4)

    if [ -n "$obsidian_deb_url" ]; then
        echo "Downloading and installing Obsidian from $obsidian_deb_url"
        wget -O /tmp/obsidian.deb "$obsidian_deb_url"
        sudo apt install -y /tmp/obsidian.deb
        rm -f /tmp/obsidian.deb
        add_to_gnome_dock "obsidian.desktop"
    else
        echo "Failed to find Obsidian .deb download URL."
    fi
fi


# Ask user to install Spotify
read -p "Would you like to install Spotify? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Remove existing GPG key file if it exists
    sudo rm -f /usr/share/keyrings/spotify.gpg

    # Add the GPG key for Spotify
    curl -sSL https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify.gpg
    
    # Add Spotify repository
    echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    
    # Update and install Spotify
    sudo apt update
    sudo apt install -y spotify-client
    add_to_gnome_dock "spotify.desktop"
fi



# Ask user to Prettify the Gnome Desktop
read -p "Would you like to make Gnome a bit more normal looking like Windows and OSX? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Prettify the Gnome Desktop and add Terminal to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.ding show-trash true
    gsettings set org.gnome.nautilus.desktop icon-size 'small'
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.ding show-home false
    gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'

    add_terminal_to_dock
else
    echo "Skipping Gnome Prettification."
fi

# Ask user to Improve Terminal
read -p "Would you like to make the Terminal a bit cooler like a cool hacker doing big heckin' hacks? [Y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    # Get the default profile ID
    DEFAULT_PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

    # Check if the DEFAULT_PROFILE_ID is not empty
    if [[ -n $DEFAULT_PROFILE_ID ]]; then
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT_PROFILE_ID/ use-theme-colors false
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT_PROFILE_ID/ foreground-color 'rgb(0,255,0)'
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT_PROFILE_ID/ background-color 'rgb(0,0,0)'
        echo "You're like yer man the robut from the show now boi."
    else
        echo "Could not find the default GNOME Terminal profile ID."
    fi
fi


# Ask user to remove Snap
read -p "Snap is a dogshit way to run applications in Linux, would you like to remove Snap and any installed snap packages? [y/n] " answer
if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
    echo "Let's take out the trash!"

    # Remove all installed snap packages
    echo "Removing all installed snap packages..."
    installed_snaps=$(snap list | awk '/^snapd/ {next} /^Name/ {next} {print $1}')
    for snap in $installed_snaps; do
        echo "Removing snap: $snap"
        sudo snap remove "$snap"
    done

    # Remove snapd
    echo "Removing snapd..."
    sudo apt-get purge snapd -y
    sudo apt-mark hold snapd

    # Install gnome-software as an alternative
    sudo apt-get install gnome-software --no-install-recommends

    # Remove snap loopbacks
    remove_snap_loopbacks
fi

