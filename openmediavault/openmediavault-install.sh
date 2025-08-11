#!/usr/bin/bash

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

$STD echo deb https://packages.openmediavault.org/public main | sudo tee /etc/apt/sources.list.d/openmediavault.list

$STD apt-get update
$STD apt-get upgrade -y
$STD apt-get install -y openmediavault openmediavault-apt openmediavault-filebrowser openmediavault-ftp openmediavault-hosts \
    openmediavault-keyring openmediavault-snmp 
msg_ok "Installed Dependencies"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"