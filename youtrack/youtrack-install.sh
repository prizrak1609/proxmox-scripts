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

msg_info "Configuring youtrack"
$STD mkdir /home/youtrack && cd /home/youtrack
$STD curl -L https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/youtrack/youtrack-docker-compose.yaml -o docker-compose.yaml
msg_ok "Configured youtrack"

motd_ssh
customize

msg_info "Starting youtrack"
$STD docker compose up -d
msg_ok "Started youtrack"