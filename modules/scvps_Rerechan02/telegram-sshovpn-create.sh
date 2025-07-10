#!/usr/bin/env bash

username="$1"
password="$2"
masa="$3"

if [[ -z "$username" || -z "$password" || -z "$masa" ]]; then
    echo "Usage: $0 <username> <password> <expired_days>"
    exit 1
fi

# Notif Telegram
telegram_bot_token=$(cat /usr/local/etc/v2ray/bot.key)
telegram_chatid=$(cat /usr/local/etc/v2ray/client.id)

# Data
domain=$(cat /usr/local/etc/v2ray/domain)
if [[ -s /root/.ip ]]; then
  ip=$(cat /root/.ip)
else
  ip=$(hostname -I | awk '{print $1}')
fi

nameserver=$(cat /etc/slowdns/nameserver 2>/dev/null)
pubkey=$(cat /etc/slowdns/server.pub 2>/dev/null)

# Cek apakah kosong
if [[ -z "$nameserver" ]]; then
    nameserver="not set"
fi

if [[ -z "$pubkey" ]]; then
    pubkey="not set"
fi

clear
exp=$(date +%F -d "$masa days")
useradd -e $exp -M -N -s /bin/false $username && echo "$username:$password" | chpasswd
clear

# Notif Telegram (Fix Full Info Sama dengan echo -e)
TEKS=$(cat <<EOF
<b>Success Create SSH Account</b>
<b>———————————————————</b>
<b>Domain:</b> <code>$domain</code> / <code>$ip</code>
<b>Username:</b> <code>$username</code>
<b>Password:</b> <code>$password</code>
<b>———————————————————</b>
<b>Port OpenSSH:</b> <code>443</code>
<b>Port WS HTTP:</b> <code>80, 2082, 8080</code>
<b>Port WS TLS:</b> <code>443</code>
<b>Port Socks5:</b> <code>443, 1080</code>
<b>Port UDP Custom:</b> <code>1-65535</code> &amp; <code>36712</code>
<b>Port BadVPN:</b> <code>7300</code>
<b>———————————————————</b>
<b>DNS:</b> <code>1.1.1.1/8.8.8.8</code>
<b>Publik Key:</b> <code>${pubkey}</code>
<b>Nameserver:</b> <code>${nameserver}</code>
<b>———————————————————</b>
<b>Config HTTP Custom:</b> <code>${domain}:1-65535@${username}:${password}</code>
<b>———————————————————</b>
<b>Payload:</b> <code>GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]</code>
<b>———————————————————</b>
<b>Expired:</b> <code>$exp</code>
<b>———————————————————</b>
EOF
)

curl -s -X POST "https://api.telegram.org/bot$telegram_bot_token/sendMessage" \
    -d "chat_id=$telegram_chatid" \
    -d "parse_mode=HTML" \
    --data-urlencode "text=$TEKS" > /dev/null

clear
echo -e " Success Create SSH Account "
echo -e "———————————————————"
echo -e "Domain: $domain / $ip "
echo -e "Username: $username "
echo -e "Password: $password "
echo -e "———————————————————"
echo -e "Port OpenSSH: 443"
echo -e "Port WS HTTP: 80, 2082, 8080"
echo -e "Port WS TLS: 443"
echo -e "Port Socks5: 443, 1080"
echo -e "Port UDP Custom: 1-65535 & 36712"
echo -e "Port BadVPN: 7300"
echo -s "Port Slowdns: 53, 5300"
echo -e "———————————————————"
echo -e "DNS: 1.1.1.1, 8.8.8.8"
echo -e "Nameserver: ${nameserver}"
echo -e "Publik Key: ${pubkey}"
echo -e "———————————————————"
echo -e "Config HTTP Custom: ${domain}:1-65535@${username}:${password}"
echo -e "———————————————————"
echo -e "Payload: GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "———————————————————"
echo -e "Expired: $exp"
echo -e "———————————————————"
