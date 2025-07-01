#!/usr/bin/bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
CM="${GN}✔️${CL}"
CROSS="${RD}✖️${CL}"
INFO="${BL}ℹ️${CL}"

APP="FileBrowser"
INSTALL_PATH="/usr/local/bin/filebrowser"
DB_PATH="/usr/local/community-scripts/filebrowser.db"
DEFAULT_PORT=8080

# Get first non-loopback IP & Detect primary network interface dynamically
IFACE=$(ip -4 route | awk '/default/ {print $5; exit}')
IP=$(ip -4 addr show "$IFACE" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)

[[ -z "$IP" ]] && IP=$(hostname -I | awk '{print $1}')
[[ -z "$IP" ]] && IP="0.0.0.0"

OS="Alpine"
SERVICE_PATH="/etc/init.d/filebrowser"
PKG_MANAGER="apk add --no-cache"

function msg_info() {
local msg="$1"
echo -e "${INFO} ${YW}${msg}...${CL}"
}

function msg_error() {
local msg="$1"
echo -e "${CROSS} ${RD}${msg}${CL}"
}

PORT=${DEFAULT_PORT}

msg_info "Installing ${APP} on ${OS}"
$PKG_MANAGER wget tar curl &>/dev/null
curl -fsSL "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz" | 
tar -xzv -C /usr/local/bin &>/dev/null
chmod +x "$INSTALL_PATH"
msg_ok "Installed ${APP}"

msg_info "Creating FileBrowser directory"
mkdir -p /usr/local/community-scripts
chown root:root /usr/local/community-scripts
chmod 755 /usr/local/community-scripts
touch "$DB_PATH"
chown root:root "$DB_PATH"
chmod 644 "$DB_PATH"
msg_ok "Directory created successfully"

CHOICE=$(
  whiptail --backtitle "Proxmox VE Helper Scripts" --radiolist --title "Select" --menu "Would you like to use No 
Authentication? (y/N):" 11 58 2 \
	"1" "Yes" \
	"2" "No" \
	2>&1 1>&2
)

case $CHOICE in
1)
  msg_info "Configuring No Authentication"
	cd /usr/local/community-scripts
	filebrowser config init -a '0.0.0.0' -p "$PORT" -d "$DB_PATH" &>/dev/null
	filebrowser config set -a '0.0.0.0' -p "$PORT" -d "$DB_PATH" &>/dev/null
	filebrowser config init --auth.method=noauth &>/dev/null
	filebrowser config set --auth.method=noauth &>/dev/null
	filebrowser users add ID 1 --perm.admin &>/dev/null
	msg_ok "No Authentication configured"
  ;;
2)
  msg_info "Setting up default authentication"
	cd /usr/local/community-scripts
	filebrowser config init -a '0.0.0.0' -p "$PORT" -d "$DB_PATH" &>/dev/null
	filebrowser config set -a '0.0.0.0' -p "$PORT" -d "$DB_PATH" &>/dev/null
	filebrowser users add admin admin --perm.admin --database "$DB_PATH" &>/dev/null
	msg_ok "Default authentication configured (admin:helper-scripts.com)"
  exit
  ;;
esac

msg_info "Creating service"
cat <<EOF >"$SERVICE_PATH"
#!/sbin/openrc-run

command="/usr/local/bin/filebrowser"
command_args="-r / -d $DB_PATH -p $PORT"
command_background=true
pidfile="/var/run/filebrowser.pid"
directory="/usr/local/community-scripts"
runas_user=root

depend() {
need net
}
EOF
chmod +x "$SERVICE_PATH"
rc-update add filebrowser default &>/dev/null
rc-service filebrowser start &>/dev/null
msg_ok "Service created successfully"

msg_ok "${CM} ${GN}${APP} is reachable at: ${BL}http://$IP:$PORT${CL}"

motd_ssh
customize