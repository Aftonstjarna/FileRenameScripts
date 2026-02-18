#!/usr/bin/env bash
set -euo pipefail

### CONFIG ###
ROOT_JELLYFIN_DIR="/var/lib/jellyfin"
FLATPAK_JELLYFIN_DIR="$HOME/.var/app/org.jellyfin.JellyfinServer/data/jellyfin"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/jellyfin-flatpak-backup-$TIMESTAMP"

### FUNCTIONS ###
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

### CHECKS ###
info "Checking source directory..."
[[ -d "$ROOT_JELLYFIN_DIR" ]] || die "Root Jellyfin directory not found: $ROOT_JELLYFIN_DIR"

info "Checking Flatpak target directory..."
mkdir -p "$FLATPAK_JELLYFIN_DIR"

### BACKUP EXISTING FLATPAK DATA ###
if [[ -n "$(ls -A "$FLATPAK_JELLYFIN_DIR" 2>/dev/null)" ]]; then
    info "Existing Flatpak Jellyfin data detected."
    info "Creating backup at: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -a "$FLATPAK_JELLYFIN_DIR/." "$BACKUP_DIR/"
fi

### COPY DATA ###
info "Copying Jellyfin data from root install to Flatpak..."

sudo rsync -aHAX --numeric-ids \
    --info=progress2 \
    --delete \
    "$ROOT_JELLYFIN_DIR/" \
    "$FLATPAK_JELLYFIN_DIR/"

### FIX PERMISSIONS ###
info "Fixing ownership for Flatpak sandbox..."
chown -R "$(id -u):$(id -g)" "$FLATPAK_JELLYFIN_DIR"

### DONE ###
info "Migration complete."

cat <<EOF

NEXT STEPS:
1. Start Jellyfin Flatpak:
   flatpak run org.jellyfin.JellyfinServer

2. Verify:
   - Users
   - Libraries
   - Playback
   - Plugins

3. After confirming everything works, you may remove the old root install:
   sudo systemctl disable jellyfin
   sudo apt remove jellyfin   (or equivalent)

Backup location (if needed):
$BACKUP_DIR

EOF
