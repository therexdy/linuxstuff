#!/bin/bash

# Hi, I am Rexdy. Thanks for using my work, please support me by starring this repository on github at https://github.com/therexdy/linuxstuff and if you want to talk to me you can drop a message in my instagram DMs at https://instagram.com/therexdy
# This script installs QEMU and virt-manager for using Virtual Machines on Arch-Linux

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

packages=( qemu-full libvirt virt-manager edk2-ovmf )

while true; do
    printf -- "1.Install\n2.Uninstall\nq.Quit\n"
    read -r answer
    case "$answer" in
        "1")
            printf -- "Installing please wait....\n"
            sudo pacman -Syy --noconfirm --needed "${packages[@]}"
            sudo systemctl enable --now libvirtd.service
            sudo usermod -aG libvirt $USER
            printf -- "\nChanges will take effect after next login.\n\n"
            printf -- "Done\n"
            break
            ;;
        "2")
            printf -- "Uninstalling please wait....\n"
            sudo systemctl disable --now libvirtd.service
            sudo pacman -Rns --noconfirm "${packages[@]}"
            rm -rf ~/.config/libvirt
            rm -rf ~/.local/share/libvirt
            sudo rm -rf /var/lib/libvirt
            printf -- "\nPurged.\n\n"
            break
            ;;
        "q")
            exit
            ;;
        *)
            printf -- "Invalid choice\n"
            ;;
    esac
done
