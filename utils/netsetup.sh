#!/bin/bash

# Hi, I am Rexdy. Thanks for using my work, please support me by starring this repository on github at https://github.com/therexdy/linuxstuff and if you want to talk to me you can drop a message in my instagram DMs at https://instagram.com/therexdy
# This script installs the packages related to networking that I use.

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

DISTRO=$(detect_distro)
echo "Your GNU/Linux distribution is $DISTRO"

echo "Installing please wait...."
case "$DISTRO" in
    ubuntu|debian)
        sudo apt-get update > /dev/null
        sudo apt-get -y --no-install-recommends install iproute2 net-tools isc-dhcp-client wpasupplicant network-manager iw wireless-tools rfkill iputils-ping traceroute mtr nmap netcat-openbsd tcpdump curl wget ethtool bind9-host dnsutils nftables bmon > /dev/null
        ;;
    arch|manjaro)
        sudo pacman -Sy --noconfirm > /dev/null
        sudo pacman -S --noconfirm --needed iproute2 net-tools dhcpcd wpa_supplicant networkmanager iw wireless_tools rfkill iputils traceroute mtr nmap netcat tcpdump curl wget ethtool bind nftables bmon > /dev/null
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "Done"
