#!/usr/bin/bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add docker docker-compose git --no-cache
msg_ok "Installed Dependencies"

msg_info "Configuring docker"
$STD rc-update add docker
$STD service docker start
$STD sleep 5s
msg_ok "Configured docker"

msg_info "Configuring pastefy"
$STD mkdir -p /home/pastefy && cd /home/pastefy
$STD git clone https://github.com/interaapps/pastefy.git .
$STD sed -i "s/pastefy:$/pastefy:\n restart: always/" docker-compose.yaml
$STD sed -i "s/SERVER_NAME: \"http:\/\/localhost:9999\"/SERVER_NAME: \"https:\/\/snippets.ollaris.org\"/" docker-compose.yaml
msg_ok "Configured pastefy"

motd_ssh
customize

msg_info "Starting pastefy"
$STD docker compose up -d
$STD docker builder prune -af
msg_ok "Started pastefy"
