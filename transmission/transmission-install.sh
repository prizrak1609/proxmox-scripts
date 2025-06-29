#!/usr/bin/bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Transmission"
$STD apk -U update
$STD apk upgrade --no-cache
$STD apk add transmission-daemon --no-cache

$STD rc-update add transmission-daemon

$STD service transmission-daemon start
msg_ok "Installed Transmission"

motd_ssh
customize
