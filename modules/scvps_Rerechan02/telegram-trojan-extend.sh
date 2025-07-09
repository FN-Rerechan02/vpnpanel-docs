#!/usr/bin/env bash

user="$1"
PASSWORD="$2"
masaaktif="$3"


if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$EXPIRED" ]]; then
    echo "Usage: $0 <username> <password> <expired_days>"
    exit 1
fi

clear
    exp=$(grep -wE "^#! $user" "/usr/local/etc/v2ray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))
    exp3=$(($exp2 + $masaaktif))
    exp4=$(date -d "$exp3 days" +"%Y-%m-%d")
    sed -i "/#! $user/c\#! $user $exp4" /usr/local/etc/v2ray/config.json
    systemctl restart v2ray >/dev/null 2>&1
    clear
    echo -e "╔───────────────────────────╗"
    echo -e " RENEW ACCOUNT SUCCESSFULLY "
    echo -e " ───────────────────────────"
    echo ""
    echo " Client Name : $user"
    echo " Expired On  : $exp4"
    echo ""
    echo -e "╚───────────────────────────╝"
    echo ""