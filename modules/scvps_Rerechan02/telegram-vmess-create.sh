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
uuid=$(cat /proc/sys/kernel/random/uuid)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/v2ray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`

acs=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`

ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF`

grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`


vmesslink1="vmess://$(echo $acs | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
systemctl restart v2ray

TEKS=$(cat <<EOF
<b>───────────────────</b>
   VMESS ACCOUNT   
<b>───────────────────</b>
<b>Remarks     : </b><code>${user}</code>
<b>Domain      : </b><code>${domain}</code>
<b>Port Tls    : </b><code>443</code>
<b>Port Ntls   : </b><code>80, 2082, 8080</code>
<b>ID          : </b><code>${uuid}</code>
<b>Encryption  : </b><code>none</code>
<b>Path        : </b><code>/whatever, /multipath</code>
<b>ServiceName : </b><code>vmess-grpc</code>
<b>───────────────────</b>
<b>Link TLS    :</b>
<pre>${vmesslink1}</pre>
<b>───────────────────</b>
<b>Link NTLS   :</b>
<pre>${vmesslink2}</pre>
<b>───────────────────</b>
<b>Link GRPC   :</b>
<pre>${vmesslink3}</pre>
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
echo -e "    VMESS ACCOUNT   "
echo -e " ───────────────────"
echo -e " Remarks     : ${user}" 
echo -e " Domain      : ${domain}" 
echo -e " Port Tls    : 443" 
echo -e " Port Ntls   : 80, 2082, 8080" 
echo -e " ID          : ${uuid}"
echo -e " Encryption  : none" 
echo -e " Path        : /whatever, /multipath"
echo -e " ServiceName : vmess-grpc"
echo -e " ───────────────────"
echo -e " Link TLS    : ${vmesslink1}" 
echo -e " ───────────────────"
echo -e " Link NTLS   : ${vmesslink2}" 
echo -e " ───────────────────"
echo -e " Link GRPC   : ${vmesslink3}" 
echo -e " ───────────────────"
echo -e " Expired On : $exp" 
echo -e "╚───────────────────╝"
echo "" 
