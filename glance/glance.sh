#!/usr/bin/env bash

tmp_dir=$(mktemp -d)

curl -L https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func -o "$tmp_dir/build.func"

# remove
# lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/"$var_install".sh)" $?
# from script so it is usable now
sed -i '/lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https:\/\/raw.githubusercontent.com\/community-scripts\/ProxmoxVE\/main\/install\/"$var_install".sh)" $?/d' "$tmp_dir/build.func"

source <(cat "$tmp_dir/build.func")

APP="Glance"
var_tags="homepage"
var_cpu="1"
var_ram="256"
var_disk="1"
var_os="debian"
var_version="12"
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

  if [[ ! -f /etc/systemd/system/glance.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/glanceapp/glance/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping Service"
    systemctl stop glance
    msg_ok "Stopped Service"

    msg_info "Updating ${APP} to v${RELEASE}"
    cd /opt
    curl -fsSL "https://github.com/glanceapp/glance/releases/download/v${RELEASE}/glance-linux-amd64.tar.gz" -o $(basename "https://github.com/glanceapp/glance/releases/download/v${RELEASE}/glance-linux-amd64.tar.gz")
    rm -rf /opt/glance/glance
    tar -xzf glance-linux-amd64.tar.gz -C /opt/glance
    echo "${RELEASE}" >"/opt/${APP}_version.txt"
    msg_ok "Updated ${APP} to v${RELEASE}"

    msg_info "Starting Service"
    systemctl start glance
    msg_ok "Started Service"

    msg_info "Cleaning up"
    rm -rf /opt/glance-linux-amd64.tar.gz
    msg_ok "Cleaned"
    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}."
  fi
  exit
}

start
build_container

lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/glance/glance-install.sh)"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"