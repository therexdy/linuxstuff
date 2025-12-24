#!/bin/bash

# Hi, I am Rexdy. Thanks for using my work, please support me by starring this repository on github at https://github.com/therexdy/linuxstuff and if you want to talk to me you can drop a message in my instagram DMs at https://instagram.com/therexdy
# This script installs CUPS and the drivers required for a printer from HP, Samsung and Canon.

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

error_printf(){
    printf -- "\n [E] %s\n\n" "$1"
}
info_printf(){
    printf -- "\n [I] %s\n\n" "$1"
}


cups_setup(){
    sudo pacman -S --noconfirm --needed cups cups-filters system-config-printer ghostscript foomatic-db foomatic-db-engine
    sudo usermod -aG lp "$USER"
    sudo systemctl enable --now cups.service

    while true; do
        printf -- "Which printer do you use?\n1.HP\n2.HP 1020\n3.Canon\n4.Samsung\nq.Quit\n"
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
            "q")
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
    if command -v yay > /dev/null 2>&1; then
        return
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
}


yay_setup
cups_setup

info_printf "Please reboot and after that"
info_printf "Configure printer at: http://localhost:631"
