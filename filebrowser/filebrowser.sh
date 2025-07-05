#!/usr/bin/env bash

tmp_dir=$(mktemp -d)

curl -L https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func -o "$tmp_dir/build.func"

# remove
# lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/"$var_install".sh)" $?
# from script so it is usable now
sed -i '/lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https:\/\/raw.githubusercontent.com\/community-scripts\/ProxmoxVE\/main\/install\/"$var_install".sh)" $?/d' "$tmp_dir/build.func"

source <(cat "$tmp_dir/build.func")

APP="FileBrowser"
var_tags="files"
var_cpu="2"
var_ram="2048"
var_disk="1"
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
	INSTALL_PATH="/usr/local/bin/filebrowser"
	
	if [ -f "${INSTALL_PATH}" ]
	then
		$STD msg_info "Updating ${APP}"
		$STD curl -fsSL "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz" | tar -xzv -C /usr/local/bin &>/dev/null
		$STD chmod +x "${INSTALL_PATH}"
		$STD msg_ok "Updated ${APP}"
	else
		$STD msg_ok "No ${INSTALL_PATH} was found"
	fi
    exit
}

start
build_container

lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/prizrak1609/proxmox-scripts/refs/heads/main/filebrowser/filebrowser-install.sh)"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/${CL}"