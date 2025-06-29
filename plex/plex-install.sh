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
$STD apt-get install -y curl

$STD echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
$STD curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

$STD apt-get update
$STD apt-get upgrade -y
$STD apt-get install -y plexmediaserver {va-driver-all,ocl-icd-libopencl1,intel-opencl-icd,vainfo,intel-gpu-tools}
msg_ok "Installed Dependencies"

msg_info "Enabling Hardware Acceleration"
chgrp video /dev/dri
chmod 755 /dev/dri
chmod 660 /dev/dri/*

$STD adduser $(id -u -n) video
$STD adduser $(id -u -n) render
$STD adduser plex video
$STD adduser plex render
msg_info "Enabled Hardware Acceleration"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"