#!/bin/bash

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
echo "Minecraft Server"
echo

if [[ $# -ne 1 ]]; then
	printf -- "[E] --- Invalid number of args.\n"
	exit
fi

case "$1" in
	"start")
		mkdir -p ./server_files/
		image=$(podman images --format '{{.Repository}}:{{.Tag}}' | awk '/rexmc/ {print $1}')
		if [[ "$image" != "localhost/rexmc:latest" ]]; then
			printf -- "[I] -- Building rexmc image.\n"
			podman build -t rexmc:latest -f ./Containerfile . > /dev/null
		fi

		if [[ ! -f ./server_files/server.jar ]]; then
			printf -- "[I] -- server.jar not found.\n"
			printf -- "Paste the download link of server.jar\n"
			read link
			printf -- "[W] -- Please wait.... Do not kill this process....\n"
			wget -O ./server_files/server.jar "$link" > /dev/null 2>&1
		fi
		if [[ ! -f ./server_files/eula.txt ]]; then
			printf -- "[I] -- Accepting EULA.\n"
			cat <<'EOF' > ./server_files/eula.txt
eula=true
EOF
		fi
		if [[ ! -f ./server_files/server.properties && -f ./server_properties_template ]]; then
			cp ./server_properties_template ./server_files/server.properties
		fi
		podman kube down play.yaml > /dev/null 2>&1
		printf -- "[I] -- Starting server....\n"
		podman kube play play.yaml > /dev/null 2>&1
		;;
	"stop")
		printf -- "[I] -- Stopping server....\n"
		podman kube down play.yaml > /dev/null 2>&1
		;;
	*)
		printf -- "[E] -- Invalid args.\n"
		;;
esac

