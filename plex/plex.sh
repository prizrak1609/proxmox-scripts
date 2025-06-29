#!/usr/bin/env bash

tmp_dir=$(mktemp -d)

curl -L https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func -o "$tmp_dir/build.func"

# remove
# lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/"$var_install".sh)" $?
# from script so it is usable now
sed -i '/lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https:\/\/raw.githubusercontent.com\/community-scripts\/ProxmoxVE\/main\/install\/"$var_install".sh)" $?/d' "$tmp_dir/build.func"

source <(cat "$tmp_dir/build.func")

APP="Plex"
var_tags="media"
var_cpu="10"
var_ram="10240"
var_disk="5"
var_os="ubuntu"
var_version="24.10"
var_unprivileged="0"
var_verbose="1"
var_fuse="0"
var_tun="0"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  exit
}

start
build_container

lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/plex/plex-install.sh)"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:32400/web${CL}"