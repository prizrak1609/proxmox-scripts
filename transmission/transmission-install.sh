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
$STD echo "runas_user=root" >> /etc/conf.d/transmission-daemon
$STD echo "logfile=/var/log/transmission/transmission.log" >> /etc/conf.d/transmission-daemon

$STD mkdir -p /var/lib/transmission/config/resume/
$STD mkdir -p /var/lib/transmission/config/torrents/
$STD mkdir -p /var/lib/transmission/config/blocklists/
$STD adduser transmission root
$STD echo "{\"rpc-whitelist-enabled\": false, \"rpc-host-whitelist-enabled\": false, \"port-forwarding-enabled\": false}" > /var/lib/transmission/config/settings.json
msg_ok "Installed Transmission"

motd_ssh
customize
