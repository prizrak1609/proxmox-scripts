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
$STD apt-get install -y gnupg
$STD wget --quiet --output-document=- https://packages.openmediavault.org/public/archive.key | gpg --dearmor --yes --output "/usr/share/keyrings/openmediavault-archive-keyring.gpg"

$STD cat <<EOF >> /etc/apt/sources.list.d/openmediavault.list
deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://packages.openmediavault.org/public sandworm main
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://downloads.sourceforge.net/project/openmediavault/packages sandworm main
## Uncomment the following line to add software from the proposed repository.
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://packages.openmediavault.org/public sandworm-proposed main
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://downloads.sourceforge.net/project/openmediavault/packages sandworm-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://packages.openmediavault.org/public sandworm partner
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] https://downloads.sourceforge.net/project/openmediavault/packages sandworm partner
EOF

$STD export LANG=C.UTF-8
$STD export DEBIAN_FRONTEND=noninteractive
$STD export APT_LISTCHANGES_FRONTEND=none
$STD apt-get update
$STD apt-get upgrade -y
$STD apt-get -y --auto-remove --show-upgraded \
    --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    --option DPkg::Options::="--force-confdef" \
    --option DPkg::Options::="--force-confold" \
    install openmediavault openmediavault-apt openmediavault-filebrowser openmediavault-ftp openmediavault-hosts \
    openmediavault-keyring openmediavault-snmp
$STD omv-confdbadm populate
$STD omv-salt deploy run systemd-networkd
msg_ok "Installed Dependencies"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

$STD shutdown now