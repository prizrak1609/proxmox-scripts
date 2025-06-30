#!/usr/bin/env bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get update
$STD apt-get upgrade -y
$STD apt-get install -y curl
msg_ok "Installed Dependencies"

msg_info "Installing Glance"
RELEASE=$(curl -fsSL https://api.github.com/repos/glanceapp/glance/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
cd /opt
curl -fsSL "https://github.com/glanceapp/glance/releases/download/v${RELEASE}/glance-linux-amd64.tar.gz" -o "glance-linux-amd64.tar.gz"
mkdir -p /opt/glance
tar -xzf glance-linux-amd64.tar.gz -C /opt/glance

curl -L https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/glance/glance-config.yml -o /opt/glance/glance.yml

echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed Glance"

msg_info "Creating Service"
service_path="/etc/systemd/system/glance.service"
echo "[Unit]
Description=Glance Daemon
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/glance
ExecStart=/opt/glance/glance --config /opt/glance/glance.yml
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target" >$service_path

systemctl enable -q --now glance
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/glance-linux-amd64.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"