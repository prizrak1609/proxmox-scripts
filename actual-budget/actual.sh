#!/usr/bin/env bash

tmp_dir=$(mktemp -d)

curl -L https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func -o "$tmp_dir/build.func"

# remove
# lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/"$var_install".sh)" $?
# from script so it is usable now
sed -i '/lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https:\/\/raw.githubusercontent.com\/community-scripts\/ProxmoxVE\/main\/install\/"$var_install".sh)" $?/d' "$tmp_dir/build.func"

source <(cat "$tmp_dir/build.func")

APP="Actual Budget"
var_tags="finance"
var_cpu="1"
var_ram="1024"
var_disk="2"
var_os="debian"
var_version="12"
var_unprivileged="0"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -f /opt/actualbudget_version.txt ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  NODE_VERSION="22"
  setup_nodejs
  RELEASE=$(curl -fsSL https://api.github.com/repos/actualbudget/actual/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ -f /opt/actualbudget-data/config.json ]]; then
    if [[ ! -f /opt/actualbudget_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/actualbudget_version.txt)" ]]; then
      msg_info "Stopping ${APP}"
      systemctl stop actualbudget
      msg_ok "${APP} Stopped"

	  msg_info "Updating Mono-to-Actual"
      $STD cd /home/mono-to-actual
	  $STD git fetch origin main
	  $STD git reset --hard origin/main
      msg_ok "Updated Mono-to-Actual"

      msg_info "Updating ${APP} to ${RELEASE}"
      $STD npm update -g @actual-app/sync-server
      echo "${RELEASE}" >/opt/actualbudget_version.txt
      msg_ok "Updated ${APP} to ${RELEASE}"

      msg_info "Starting ${APP}"
      systemctl start actualbudget
      msg_ok "Restarted ${APP}"
    else
      msg_info "${APP} is already up to date"
    fi
  else
    msg_info "Old Installation Found, you need to migrate your data and recreate to a new container"
    msg_info "Please follow the instructions on the ${APP} website to migrate your data"
    msg_info "https://actualbudget.org/docs/backup-restore/backup"
    exit 1
  fi
  exit
}

start
build_container

lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/actual-budget/actual-install.sh)"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:5006${CL}"