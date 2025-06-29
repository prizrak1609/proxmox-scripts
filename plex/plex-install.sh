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
$STD echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
$STD curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
$STD apt-get update
msg_ok "Installed Dependencies"

msg_info "Installing Plex"
$STD apt-get install plexmediaserver
msg_ok "Installed Plex: open https://localhost:32400/web to configure"