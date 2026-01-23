#!/bin/bash

rexdy='
 ____              _
|  _ \ _____  ____| |_   _
| |_) / _ \ \/ / _` | | | |
|  _ <  __/>  < (_| | |_| |
|_| \_\___/_/\_\__,_|\__, |
                     |___/
'
echo "$rexdy"

python3 -m http.server 80 --directory /public > /dev/null 2>&1 &

if [[ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]];then
    printf -- "Domain Name: $DOMAIN\n"
    if certbot certonly --webroot -w /public -d "$DOMAIN"; then
        printf -- "Done.\nContainer will stop now.\n"
    else
        printf -- "\n\t[E] Failed to run certbot.\n\n"
    fi
else
    printf -- "\n\t[E] Cert(s) already exist.\n\n"
fi

