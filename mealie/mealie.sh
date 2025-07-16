#!/usr/bin/env bash

tmp_dir=$(mktemp -d)

curl -L https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func -o "$tmp_dir/build.func"

# remove
# lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/"$var_install".sh)" $?
# from script so it is usable now
sed -i '/lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https:\/\/raw.githubusercontent.com\/community-scripts\/ProxmoxVE\/main\/install\/"$var_install".sh)" $?/d' "$tmp_dir/build.func"

source <(cat "$tmp_dir/build.func")

APP="Mealie"
var_tags="recipes"
var_cpu="1"
var_ram="512"
var_disk="2"
var_os="alpine"
var_version="3.22"
var_unprivileged="0"
var_verbose="yes"
var_fuse="no"
var_tun="no"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  $STD docker compose down
  $STD docker compose rm -f
  $STD docker system prune -af
  $STD docker compose pull   
  $STD docker compose up -d

  exit
}

start
build_container

lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/mealie/mealie-install.sh)"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"