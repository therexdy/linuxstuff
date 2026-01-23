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
echo "Samba Server"

if /usr/sbin/smbd -F ; then
    printf -- "0_0\n"
else
    printf -- "Could not start smbd in foreground\nEntering bash shell\n"
    /bin/bash
fi
