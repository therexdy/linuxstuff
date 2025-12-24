#!/bin/bash

# Hi, I am Rexdy. Thanks for using my work, please support me by starring this repository on github at https://github.com/therexdy/linuxstuff and if you want to talk to me you can drop a message in my instagram DMs at https://instagram.com/therexdy
# This script installs the packages that I use and also sets up Neovim with my config.

set -euo pipefail
rexdy='
 ____              _
|  _ \ _____  ____| |_   _
| |_) / _ \ \/ / _` | | | |
|  _ <  __/>  < (_| | |_| |
|_| \_\___/_/\_\__,_|\__, |
                     |___/
'
echo "$rexdy"

if ! ping -c 3 8.8.8.8 > /dev/null 2>&1; then
    echo "Network connection failed :("
    exit
fi

sudo -v

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

install_snap_if_needed() {
    if ! command -v snap &> /dev/null; then
        sudo apt update > /dev/null
        sudo apt install -y snapd > /dev/null
        sudo systemctl enable --now snapd.socket > /dev/null
        
        if [ ! -L /snap ]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
        
        sudo snap install core > /dev/null
        
        export PATH="/snap/bin:$PATH"
    fi
}

DISTRO=$(detect_distro)
echo "Your GNU/Linux distribution is $DISTRO"

echo "Installing please wait...."
case "$DISTRO" in
    ubuntu)
        sudo snap install nvim --classic > /dev/null
        sudo apt update > /dev/null
        sudo apt install -y --no-install-recommends git npm > /dev/null
        ;;
    debian)
        install_snap_if_needed
        sudo snap install nvim --classic > /dev/null
        sudo apt update > /dev/null
        sudo apt install -y --no-install-recommends git npm > /dev/null
        ;;
    arch|manjaro)
        sudo pacman -Syu --noconfirm > /dev/null
        sudo pacman -S --noconfirm --needed neovim git npm > /dev/null
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

if [[ ! -f "./netsetup.sh" ]]; then
    git clone https://github.com/therexdy/linuxstuff.git > /dev/null
    sudo bash ./linuxstuff/utils/netsetup.sh
    rm -rf linuxscripts
else
    sudo bash ./netsetup.sh
fi

echo "Setting up Neovim config...."
if ! git clone https://gist.github.com/e1369727587d2f1a446c6ab4009496c9.git > /dev/null 2>&1; then
    echo "Failed to setup Neovim config :("
fi

mkdir -p "$HOME/.config/nvim"

if [ -f "$HOME/.config/nvim/init.lua" ]; then
    mv "$HOME/.config/nvim/init.lua" "./init.lua.backup.$(date +%s)"
fi

cp ./e1369727587d2f1a446c6ab4009496c9/init.lua "$HOME/.config/nvim/"
rm -rf ./e1369727587d2f1a446c6ab4009496c9

echo "Done"
