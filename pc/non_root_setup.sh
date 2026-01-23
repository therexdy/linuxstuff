#!/bin/bash

# Hi, I am Rexdy. Thanks for using my work, please support me by starring this repository on github at https://github.com/therexdy/linuxstuff and if you want to talk to me you can drop a message in my instagram DMs at https://instagram.com/therexdy
# I have written this script to automate the process of installing and setting up an Arch Linux system(primarily for software development). This script must be run as a non root user after doing the initil installation as a root user and logging in as a non root user, post reboot. Please use https://wiki.archlinux.org/title/Installation_guide to do the initial steps as root user.
# This script installs sway window manager and it's configured in the way I like it. Feel free to modify the configuration or install KDE Desktop Environment for a standard desktop experience.

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
    printf -- "Network connection failed :(\n"
    exit
fi

sudo -v

error_printf(){
    printf -- "\n [E] %s\n\n" "$1"
}
info_printf(){
    printf -- "\n [I] %s\n\n" "$1"
}
check_install(){
    if ! command -v "$1" > /dev/null 2>&1; then
        sudo pacman -Syy --noconfirm --needed "$1"
    fi
}

setup_reflector(){
    check_install reflector
    mkdir -p ./backup/pacman.d/
    sudo cp /etc/pacman.d/mirrorlist ./backup/pacman.d/ 
    info_printf "Updating mirrors....\n"
    sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist > /dev/null 2>&1
    info_printf "Updated mirrors.\n"
    sudo pacman -Syu --noconfirm --needed
}

neovim_setup(){
    check_install neovim
    info_printf "Setting up Neovim\n"
    if [[ ! -d "./dotstuff/.git" ]]; then
        git clone https://codeberg.org/therexdy/dotstuff.git
    fi
    check_install rsync
    mkdir -p "$HOME/.config/nvim/"
    mkdir -p "$HOME/.local/share/nvim/undo/"
    rsync -a --delete ./dotstuff/dotconfig/nvim/ "$HOME/.config/nvim"
}

basic_setup(){
    setup_reflector
    info_printf "Performing basic setup\n"
    local list=( neovim git gcc go zip unzip nftables ncdu clang bash-completion rsync usbutils ripgrep curl wget htop openssh )
    sudo pacman -S --noconfirm --needed "${list[@]}"
    if [[ ! -d "./dotstuff" ]]; then
        git clone https://codeberg.org/therexdy/dotstuff.git 
    fi
    if [[ -f "$HOME/.bashrc" ]]; then
        cp "$HOME/.bashrc" ./backup/bashrc
    fi
    cp ./dotstuff/bashrc "$HOME/.bashrc"
    if [[ -f "$HOME/.profile" ]]; then
        cp "$HOME/.profile" ./backup/dotprofile
    fi
    cp ./dotstuff/dotprofile "$HOME/.profile"
    neovim_setup
}

bluetooth_setup(){
    info_printf "Setting up Bluetooth\n"
    bluetooth_packages=(bluez bluez-utils blueman)
    sudo pacman -S --noconfirm --needed "${bluetooth_packages[@]}"
    sudo systemctl enable --now bluetooth.service
}

setup_dotfiles() {
    info_printf "Setting Dotfiles\n"
    if [[ ! -d "./dotstuff/.git" ]]; then
        git clone https://codeberg.org/therexdy/dotstuff.git 
    fi
    check_install rsync 
    if [[ -d "$HOME/.config" ]]; then
        mkdir -p ./backup/dotconfig 
        rsync -a "$HOME/.config/" ./backup/dotconfig 
    else
        mkdir -p "$HOME/.config/"
    fi
    rsync -a ./dotstuff/dotconfig/ "$HOME/.config"
     
    if [[ ! -d "./bigfiles/.git" ]]; then
        git clone https://codeberg.org/therexdy/bigfiles.git
    fi
    mkdir -p "$HOME/.local/share/fonts"
    rsync -a ./bigfiles/fonts/ "$HOME/.local/share/fonts/"
    mkdir -p "$HOME/Pictures/wp/"
    rsync -a ./bigfiles/wp/ "$HOME/Pictures/wp"

    if [[ ! -f /etc/environment ]]; then
        sudo touch /etc/environment
    else
        sudo cp /etc/environment ./backup/etcenv
    fi
    sudo bash -c 'cat ./dotstuff/etcenv >> /etc/environment'
}

cups_setup(){
    info_printf "Printer Setup\n"
    sudo pacman -S --noconfirm --needed cups cups-filters system-config-printer ghostscript foomatic-db foomatic-db-engine
    sudo usermod -aG lp "$USER"
    sudo systemctl enable --now cups.service

    while true; do
        printf -- "Which printer do you use?\n1.HP\n2.HP 1020\n3.Canon\n4.Samsung\n5.Skip printer specific setup\n"
        read -r answer
        case "$answer" in
            "1")
                sudo pacman -S --noconfirm --needed hplip
                yay_setup
                yay -S --noconfirm --needed hplip-plugin
                break
                ;;
            "2")
                sudo pacman -S --noconfirm --needed hplip
                yay_setup
                yay -S --noconfirm --needed foo2zjs-nightly
                break
                ;;
            "3")
                sudo pacman -S --noconfirm --needed gutenprint
                break
                ;;
            "4")
                sudo pacman -S --noconfirm --needed splix
                break
                ;;
            "5")
                break
                ;;
            *)
                info_printf "Invalid choice."
                ;;
        esac
    done
    info_printf "Printer setup will take effect post reboot."
}

yay_setup(){
    info_printf "Setting up yay\n"
    if command -v yay > /dev/null 2>&1; then
        return
    fi
    if [[ ! -d "./yay/.git" ]]; then
        git clone https://aur.archlinux.org/yay.git
    fi
    cd yay
    makepkg -si
    cd ..
}

audio_setup(){
    info_printf "Setting up audio\n"
    local audio_packages=(pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol)
    sudo -v
    (yes | sudo pacman -S --needed "${audio_packages[@]}") || true
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
}

tlp_setup(){
    info_printf "Coming soon...."
}

zig_setup(){
    printf -- "Link for latest version of Zig cannot be determined automatically:\n"
    info_printf "Need human intervention"
    printf -- "Please visit\n https://ziglang.org/download/ \nto determine the latest stable version of Zig\n"

    while true; do
        printf -- "Enter the version number in the exact format shown on the website(e.g 0.15.2)\n"
        read -r version
        local link="https://ziglang.org/download/$version/zig-x86_64-linux-$version.tar.xz" 
        printf -- "Downloading Zig, please don't kill this process.\n"
        if wget -O zig.tar.xz "$link"; then
            printf -- "Download complete, installing..."
            break
        else
            error_printf "Zig download failed"
            printf -- "Skip Zig install? (1/0)\n"
            read -r skip
            if [[ "$skip" == "1" ]]; then
                return
            fi
        fi
    done

    mkdir -p ./zig
    tar -xJf zig.tar.xz -C ./zig

    mkdir -p "$HOME/.local/bin/zig"
    check_install rsync
    rsync -a --delete ./zig/ "$HOME/.local/bin/zig"
    if [[ ! -f "$HOME/.profile" ]]; then
        touch "$HOME/.profile"
    fi

    if ! grep -q ".local/bin/zig" "$HOME/.profile" 2> /dev/null; then
        tee -a "$HOME/.profile" << EOF

append_path "$HOME/.local/bin/zig"
EOF
    fi

}

prog_setup(){
    local dev_packages=( git neovim podman podman-compose base-devel go gcc clang nodejs npm binutils make cmake gdb valgrind strace curl wget nmap traceroute ethtool bind-tools )
    sudo pacman -S --noconfirm --needed "${dev_packages[@]}"

    neovim_setup

    while true; do
        printf -- "Install Zig? (0/1)\n"
        read -r answer
        case "$answer" in
            "1")
                zig_setup
                break
                ;;
            "0")
                break
                ;;
            *)
                error_printf "Please enter 0/1"
                ;;
        esac
    done

}

sway_setup(){
    basic_setup

    local desktop_packages=( sway swaybg swaylock swayidle waybar wl-clipboard grim slurp vlc imv thunar thunar-volman xdg-user-dirs tumbler ffmpeg ffmpegthumbnailer thunar-archive-plugin gvfs gvfs-smb gvfs-afc gvfs-mtp gvfs-nfs samba wofi mako xdg-desktop-portal-wlr udisks2 ghostty qt5ct qt6ct gnome-themes-extra breeze ly fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool kdeconnect mesa vulkan-intel vulkan-radeon libva-mesa-driver intel-media-driver ntfs-3g polkit-gnome gedit okular engrampa network-manager-applet )

    sudo pacman -S --noconfirm --needed "${desktop_packages[@]}"
    setup_dotfiles
    sudo systemctl enable ly@tty10.service
    if ! grep -q "^username=" /etc/ly/config.ini 2>/dev/null; then
        echo "username=$(id -un)" | sudo tee -a /etc/ly/config.ini > /dev/null
    fi

    audio_setup
    printf -- "Audio setup done.\n"

    while true; do
        printf -- "Install Bluetooth? (0/1)\n"
        read -r answer
        case "$answer" in
            "1")
                bluetooth_setup
                break
                ;;
            "0")
                break
                ;;
            *)
                error_printf "Please enter 0/1"
                ;;
        esac
    done

    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee -a /etc/NetworkManager/conf.d/20-connectivity.conf > /dev/null << 'EOF'
[connectivity]
enabled=false
EOF

    while true; do
        printf -- "Printer setup? (0/1)\n"
        read -r answer
        case "$answer" in
            "1")
                cups_setup
                break
                ;;
            "0")
                break
                ;;
            *)
                error_printf "Please enter 0/1"
                ;;
        esac
    done
    
    yay_setup

    while true; do
        printf -- "Install LibreWolf? (0/1)\n"
        read -r answer
        case "$answer" in
            "1")
                yay -S --noconfirm --needed librewolf-bin
                break
                ;;
            "0")
                break
                ;;
            *)
                error_printf "Please enter 0/1"
                ;;
        esac
    done

    while true; do
        printf -- "Programming setup? (0/1)\n"
        read -r answer
        case "$answer" in
            "1")
                prog_setup
                break
                ;;
            "0")
                break
                ;;
            *)
                error_printf "Please enter 0/1"
                ;;
        esac
    done

}

main(){
    sudo -v
    while true; do
        printf -- "Rexdy Arch-Linux setup script\n"
        printf -- "\t1. Fresh desktop setup\n"
        printf -- "\t2. Bluetooth setup\n"
        printf -- "\t3. Printer setup\n"
        printf -- "\t4. Yay install\n"
        printf -- "\t5. Setup TLP\n"
        printf -- "\t6. Setup Neovim\n"
        printf -- "\t7. Programming setup\n"
        printf -- "\tq. Quit\n"
        read -r option
        case "$option" in
            "1")
                sway_setup
                ;;
            "2")
                bluetooth_setup
                ;;
            "3")
                cups_setup
                ;;
            "4")
                yay_setup
                ;;
            "5")
                tlp_setup
                ;;
            "6")
                neovim_setup
                ;;
            "7")
                prog_setup
                ;;
            "q"|"Q")
                exit
                ;;
            *)
                error_printf "Invalid option."
                ;;
        esac
    done
}

main

