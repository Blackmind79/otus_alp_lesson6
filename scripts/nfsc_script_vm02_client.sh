#!/usr/bin/env bash

set -euo pipefail;

# -------------------------------------------------
function dt_log {
  echo "$(date +'%d.%m.%Y %H:%M:%S %Z(UTC%z)'): $1"
}
SECONDS=0
dt_log "Start script..."
# -------------------------------------------------

VM_SERVER="192.168.122.174"
SHARED_FOLDER="/mnt/vm01"
SERVER_FOLDER="/srv/share"

dt_log "Install package nfs-common"
sudo apt-get update && sudo apt-get install -y nfs-common tree

dt_log "Create shared folder [${SHARED_FOLDER}] and add to automount"
sudo mkdir -p "${SHARED_FOLDER}"

dt_log "Backup fstab"
sudo cp /etc/fstab{,.origin}

dt_log "Add mount"
sudo tee -a /etc/fstab <<EOF
${VM_SERVER}:${SERVER_FOLDER} ${SHARED_FOLDER} nfs vers=3,noauto,x-systemd.automount 0 0
EOF

dt_log "Systemctl daemon-reload"
sudo systemctl daemon-reload

dt_log "Systemctl restart remote-fs.target"
sudo systemctl restart remote-fs.target

sudo tree "${SHARED_FOLDER}"
# -------------------------------------------------
TS_IN_SECONDS=${SECONDS}
TS_IN_MINUTES=$(echo "scale=2;${SECONDS}/60 " | bc)

dt_log "...end script. Time spent in seconds ${SECONDS} (${TS_IN_MINUTES} in minutes)"