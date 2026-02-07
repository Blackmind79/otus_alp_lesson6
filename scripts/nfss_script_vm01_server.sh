#!/usr/bin/env bash

set -euo pipefail;

# -------------------------------------------------
function dt_log {
  echo "$(date +'%d.%m.%Y %H:%M:%S %Z(UTC%z)'): $1"
}
SECONDS=0
dt_log "Start script..."
# -------------------------------------------------

VM_CLIENT="192.168.122.175"
SHARED_FOLDER="/srv/share"

dt_log "Install server package nfs-kernel-server"
sudo apt-get update && sudo apt-get install -y nfs-kernel-server

dt_log "Check ports..."
sudo ss -tulpn | grep -E ":2049|:111"

dt_log "Create shared folders and set rights..."
sudo mkdir -p "${SHARED_FOLDER}/upload"
sudo chown -R nobody:nogroup "${SHARED_FOLDER}"
sudo chmod 0777 "${SHARED_FOLDER}/upload"

sudo tee -a /etc/exports <<EOF
${SHARED_FOLDER} ${VM_CLIENT}/32(rw,sync,root_squash)
EOF

# Show changes
sudo cat /etc/exports | grep -vE "^#|^$"

dt_log "Export folder"
sudo exportfs -r
sudo exportfs -s

# -------------------------------------------------
TS_IN_SECONDS=${SECONDS}
TS_IN_MINUTES=$(echo "scale=2;${SECONDS}/60 " | bc)

dt_log "...end script. Time spent in seconds ${SECONDS} (${TS_IN_MINUTES} in minutes)"