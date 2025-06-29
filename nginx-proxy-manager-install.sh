#!/usr/bin/bash

export FUNCTIONS_FILE_PATH="$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/alpine-install.func)"

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add docker docker-compose --no-cache
msg_ok "Installing Dependencies"

msg_info "Configuring docker"
rc-update add docker
service docker start
msg_ok "Configuring docker"

msg_info "Configuring nginx-proxy-manager"
mkdir data
mkdir letsencrypt
curl -L https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/nginx-proxy-manager-docker-compose.yaml -o docker-compose.yaml
msg_ok "Configuring nginx-proxy-manager"

msg_info "Starting nginx-proxy-manager"
docker-compose up -d
msg_ok "Starting nginx-proxy-manager"