#!/bin/sh

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
echo "Nginx Reverse Proxy with Self-Signed TLS"

if [ ! -f /etc/nginx/certs/privkey.pem ]; then
    apk add --no-cache openssl
    mkdir -p /etc/nginx/certs
    openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout /etc/nginx/certs/privkey.pem -out /etc/nginx/certs/fullchain.pem -subj "/C=IN/ST=Karnataka/O=Venkata/OU=Dept_of_STEM"
fi

nginx -g 'daemon off;'

