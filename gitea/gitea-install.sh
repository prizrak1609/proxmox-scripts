#!/usr/bin/bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Gitea"
$STD apk add --no-cache gitea shadow
msg_ok "Installed Gitea"

msg_info "Enabling Gitea Service"
$STD rc-update add gitea default
msg_ok "Enabled Gitea Service"

msg_info "Starting Gitea"
$STD service gitea start
$STD sleep 5s
$STD service gitea stop
$STD echo "runas_user=root" >> /etc/conf.d/gitea
$STD adduser gitea wheel
$STD usermod --uid 0 --gid 0 gitea
msg_ok "Started Gitea"

motd_ssh
customize