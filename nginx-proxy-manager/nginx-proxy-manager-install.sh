#!/usr/bin/bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add docker docker-compose --no-cache
msg_ok "Installed Dependencies"

msg_info "Configuring docker"
$STD rc-update add docker
$STD service docker start
msg_ok "Configured docker"

msg_info "Configuring nginx-proxy-manager"
$STD mkdir /data
$STD mkdir /letsencrypt
$STD curl -L https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/nginx-proxy-manager/nginx-proxy-manager-docker-compose.yaml -o docker-compose.yaml
msg_ok "Configured nginx-proxy-manager"

motd_ssh
customize

msg_info "Starting nginx-proxy-manager"
$STD docker compose up -d
msg_ok "Started nginx-proxy-manager"