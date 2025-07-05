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
$STD apt-get install -y sqlite3
msg_ok "Installed Dependencies"

setup_go

msg_info "Installing SFTPGo"
curl -fsSL https://ftp.osuosl.org/pub/sftpgo/apt/gpg.key | gpg --dearmor -o /usr/share/keyrings/sftpgo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/sftpgo-archive-keyring.gpg] https://ftp.osuosl.org/pub/sftpgo/apt bookworm main" >/etc/apt/sources.list.d/sftpgo.list
$STD apt-get update
$STD apt-get install -y sftpgo
msg_ok "Installed SFTPGo"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"