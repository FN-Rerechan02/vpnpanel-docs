#!/usr/bin/env bash

# Mengambil input dari argumen baris perintah
user="$1"
PASSWORD="$2"
masaaktif="$3"

# Validasi untuk memastikan semua argumen yang diperlukan telah diberikan
if [[ -z "$user" || -z "$PASSWORD" || -z "$masaaktif" ]]; then
    echo "Penggunaan: $0 <username> <password> <masa_aktif_hari>"
    echo "Contoh: $0 'user_test' 'pass123' '30'"
    exit 1
fi

# Notif Tele
telegram_bot_token=$(cat /usr/local/etc/v2ray/bot.key)
telegram_chatid=$(cat /usr/local/etc/v2ray/client.id)

domain=$(cat /usr/local/etc/v2ray/domain)
clear
uuid=$(cat /proc/sys/kernel/random/uuid)
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#vless$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/v2ray/config.json
vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"
systemctl restart v2ray

TEKS=$(cat <<EOF
<b>───────────────────</b>
   VLESS ACCOUNT   
<b>───────────────────</b>
<b>Remarks     : </b><code>${user}</code>
<b>Domain      : </b><code>${domain}</code>
<b>Port Tls    : </b><code>443</code>
<b>Port Ntls   : </b><code>80, 2082, 8080</code>
<b>UUID/ID     : </b><code>${uuid}</code>
<b>Path        : </b><code>/whatever, /custom</code>
<b>ServiceName : </b><code>vless-grpc</code>
<b>───────────────────</b>
<b>Link TLS    :</b>
<pre>${vlesslink1}</pre>
<b>───────────────────</b>
<b>Link NTLS   :</b>
<pre>${vlesslink2}</pre>
<b>───────────────────</b>
<b>Link GRPC   :</b>
<pre>${vlesslink3}</pre>
<b>───────────────────</b>
<b>Expired On  : </b><code>$exp</code>
<b>───────────────────</b>
EOF
)

curl -s -X POST "https://api.telegram.org/bot$telegram_bot_token/sendMessage" \
    -d "chat_id=$telegram_chatid" \
    -d "parse_mode=HTML" \
    --data-urlencode "text=$TEKS" > /dev/null

clear
echo -e "╔───────────────────╗"
echo -e "    VLESS ACCOUNT   "
echo -e " ───────────────────"
echo -e " Remarks     : ${user}" 
echo -e " Domain      : ${domain}" 
echo -e " Port Tls    : 443" 
echo -e " Port Ntls   : 80, 2082, 8080" 
echo -e " UUID/ID     : ${uuid}"
echo -e " Path        : /whatever, /custom"
echo -e " ServiceName : vless-grpc"
echo -e " ───────────────────"
echo -e " Link TLS    : ${vlesslink1}"
echo -e " ───────────────────"
echo -e " Link NTLS   : ${vlesslink2}"
echo -e " ───────────────────"
echo -e " Link GRPC   : ${vlesslink3}"
echo -e " ───────────────────"
echo -e " Expired On  : $exp"
echo -e "╚───────────────────╝"
echo ""
