#!/bin/bash

set -e

name="samba"
image="localhost/smbrex:latest"
containerfile="./setup/Containerfile_samba"

if [[ $# -ne 1 ]]; then
    printf -- "[E] invalid number of args\n"
    exit 1
fi

running() {
    podman ps --filter "name=^${name}$" --format '{{.ID}}' | grep -q .
}

exists() {
    podman ps -a --filter "name=^${name}$" --format '{{.ID}}' | grep -q .
}

image_exists() {
    podman images --format '{{.Repository}}:{{.Tag}}' | grep -qx "$image"
}

case "$1" in
    stop)
        if ! running; then
            printf -- "[I] container not running\n"
            exit 0
        fi
        podman stop "$name"
        yes | podman image prune
        ;;
    start)
        if ! image_exists; then
            if [[ ! -f "$containerfile" ]]; then
                printf -- "[E] Containerfile_samba not found\n"
                exit 1
            fi
            printf -- "creating smbrex image\n"
            podman build -t "$image" -f "$containerfile" ./setup/
        fi

        mkdir -p shares/{actshr,arcshr,nvsshr,media}

        if ! exists; then
            podman run -d \
                --name "$name" \
                -p 445:445 \
                -v ./shares/sharename:/sharename \
                -v ./smb.conf:/etc/samba/smb.conf \
                "$image"
            podman exec -it "$name" bash
        elif ! running; then
            podman start "$name"
	    podman attach "$name"
        else
            podman restart "$name"
        fi
        ;;
    *)
        printf -- "[E] invalid args\n"
        exit 1
        ;;
esac

