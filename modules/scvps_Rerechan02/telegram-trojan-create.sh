#!/usr/bin/env bash

# Mengambil input dari argumen baris perintah
user="$1"
PASSWORD="$2"
masaaktif="$3"

# Validasi untuk memastikan semua argumen yang diperlukan telah diberikan
if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$EXPIRED" ]]; then
    echo "Penggunaan: $0 <username> <password> <masa_aktif_hari>"
    echo "Contoh: $0 'user_test' 'pass123' '30'"
    exit 1
fi

# Notif Tele
telegram_bot_token=$(cat /usr/local/etc/v2ray/bot.key)
telegram_chatid=$(cat /usr/local/etc/v2ray/client.id)

domain=$(cat /usr/local/etc/v2ray/domain)
clear
password=$(cat /proc/sys/kernel/random/uuid)
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#trojan$/a\#! '"$user $exp"'\
},{"password": "'""$password""'","email": "'""$user""'"' /usr/local/etc/v2ray/config.json
systemctl restart v2ray
trojanlink="trojan://${password}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink1="trojan://${password}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
TEKS=$(cat <<EOF
<b>───────────────────</b>
  TROJAN ACCOUNT
<b>───────────────────</b>
<b>Remarks    : </b><code>${user}</code>
<b>Host/IP    : </b><code>${domain}</code>
<b>port       : </b><code>443</code>
<b>Password   : </b><code>${password}</code>
<b>Encryption : </b><code>none</code>
<b>Path       : </b><code>/trojan</code>
<b>ServiceName: </b><code>trojan-grpc</code>
<b>───────────────────</b>
<b>Link WS   :</b>
<pre>${trojanlink}</pre>
<b>───────────────────</b>
<b>Link GRPC :</b>
<pre>${trojanlink1}</pre>
<b>───────────────────</b>
<b>Expired On : </b><code>$exp</code>
<b>───────────────────</b>
EOF
)

curl -s -X POST "https://api.telegram.org/bot$telegram_bot_token/sendMessage" \
    -d "chat_id=$telegram_chatid" \
    -d "parse_mode=HTML" \
    --data-urlencode "text=$TEKS" > /dev/null

clear
echo -e "╔───────────────────╗"
echo -e "   TROJAN ACCOUNT"
echo -e " ───────────────────"
echo -e " Remarks    : ${user}"
echo -e " Host/IP    : ${domain}"
echo -e " port       : 443"
echo -e " Password   : $password"
echo -e " Encryption : none"
echo -e " Path       : /trojan"
echo -e " ServiceName: trojan-grpc"
echo -e " ───────────────────"
echo -e " Link WS   : ${trojanlink}"
echo -e " ───────────────────"
echo -e " Link GRPC : ${trojanlink1}"
echo -e " ───────────────────"
echo -e " Expired On : $exp"
echo -e "╚───────────────────╝"
echo ""
