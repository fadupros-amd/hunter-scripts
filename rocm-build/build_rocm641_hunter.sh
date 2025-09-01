#!/bin/bash
# ROCm build based on the rocminstaller file - user space
# ROCm 6.4.1 - RHEL9
# 
#
# Missing dependencies to be added (manually if needed)
# Further validation needed (e.g., version file ...)
########################################

set -euo pipefail

# === Configuration ===
ROCM_TARGET_VERSION="6.4.1"
ROCM_TARGET_DIR="/localscratch/86111.hunter-pbs01/rocm"
ROCM_RUNFILE="rocm-installer_1.1.1.60401-30-83~el9.run"
ROCM_URL="https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-${ROCM_TARGET_VERSION}/el9/${ROCM_RUNFILE}"
LOGFILE="${ROCM_TARGET_DIR}/install.log"

# === Logging Functions ===
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"
}

log_phase_start() {
    echo -e "\n==========>>> BEGIN: $1 ==========" | tee -a "$LOGFILE"
}

log_phase_end() {
    echo "==========<<< END: $1   ==========" | tee -a "$LOGFILE"
    echo "" | tee -a "$LOGFILE"
}

abort() {
    echo "ERROR: $*" | tee -a "$LOGFILE" >&2
    exit 1
}

# === Environment Variables ===
set_env_vars() {
    export ROCM_PATH="${ROCM_TARGET_DIR}/rocm-${ROCM_TARGET_VERSION}"
    export PATH="$ROCM_PATH/bin:$PATH"
    export LD_LIBRARY_PATH="$ROCM_PATH/lib:$ROCM_PATH/lib64:$LD_LIBRARY_PATH"
    export HIP_PATH="$ROCM_PATH/hip"
    export HSA_PATH="$ROCM_PATH/hsa"
    export DEVICE_LIB_PATH="$ROCM_PATH/amdgcn/bitcode"
    log "ROCm environment variables set for this session."
}

# === Action: Download ROCm Installer ===
download_rocm() {
    log_phase_start "DOWNLOAD"

    mkdir -p "$ROCM_TARGET_DIR"
    cd "$ROCM_TARGET_DIR"

    if [ -f "$ROCM_RUNFILE" ]; then
        log "Runfile already exists: $ROCM_RUNFILE"
    else
        log "Downloading ROCm runfile..."
        wget -O "$ROCM_RUNFILE" "$ROCM_URL" >> "$LOGFILE" 2>&1 || abort "Download failed"
        log "Download complete."
    fi

    log_phase_end "DOWNLOAD"
}

# === Action: Install ROCm ===
install_rocm() {
    log_phase_start "INSTALL"

    cd "$ROCM_TARGET_DIR"

    log "Extracting ROCm installer..."
    bash "$ROCM_RUNFILE" --noexec --target ./rocm-installer >> "$LOGFILE" 2>&1

    if grep -q "^SUDO=" rocm-installer/rocm-installer.sh; then
        sed -i 's/^SUDO=.*/SUDO=/' rocm-installer/rocm-installer.sh
        log "Patched SUDO setting in installer."
    fi

    log "Validating dependencies..."
    cd rocm-installer
    ./rocm-installer.sh rocm deps=validate >> "$LOGFILE" 2>&1 || abort "Dependency validation failed"
    cd ..

    log "Installing ROCm to $ROCM_TARGET_DIR"
    cd rocm-installer
    ./rocm-installer.sh rocm verbose target="$ROCM_TARGET_DIR" postrocm >> "$LOGFILE" 2>&1 || abort "ROCm installation failed"
    cd ..

    set_env_vars

    log_phase_end "INSTALL"
    echo "INSTALLATION SUCCESSFUL"
}

# === Action: Uninstall ROCm ===
uninstall_rocm() {
    log_phase_start "UNINSTALL"

    cd "$ROCM_TARGET_DIR/rocm-installer" || abort "Installer directory not found"
    ./rocm-installer.sh uninstall-rocm verbose target="$ROCM_TARGET_DIR" >> "$LOGFILE" 2>&1 || abort "Uninstallation failed"

    log "ROCm uninstalled from $ROCM_TARGET_DIR"
    log_phase_end "UNINSTALL"
    echo "UNINSTALLATION SUCCESSFUL"
}

# === Action: Check ROCm Installation ===
check_rocm() {
    log_phase_start "CHECK"

    set_env_vars

    log "Checking rocminfo"
    if command -v "$ROCM_PATH/bin/rocminfo" >/dev/null 2>&1; then
        "$ROCM_PATH/bin/rocminfo" >> "$LOGFILE" 2>&1 || abort "rocminfo failed"
        log "rocminfo: OK"
    else
        log "rocminfo not found."
    fi


    log "Checking for RVS"
    if command -v rvs >/dev/null 2>&1; then
        rvs -d >> "$LOGFILE" 2>&1 && log "RVS: GPU(s) detected"
    else
        log "RVS not installed — skipping."
    fi

    log_phase_end "CHECK"
    echo "CHECKS COMPLETED SUCCESSFULLY"
}

# === Help Menu ===
show_help() {
    cat <<EOF
Usage: $0 [ACTION...]

Available actions:
  download     - Download ROCm runfile
  install      - Install ROCm into \$ROCM_TARGET_DIR
  uninstall    - Uninstall ROCm from \$ROCM_TARGET_DIR
  check        - Run basic ROCm validation tests
  help         - Show this help message

Examples:
  $0 download install
  $0 check
EOF
}

# === Log Setup ===
mkdir -p "$(dirname "$LOGFILE")"
touch "$LOGFILE"

# === Command Dispatcher ===
if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

for action in "$@"; do
    case "$action" in
        download)  download_rocm ;;
        install)   install_rocm ;;
        uninstall) uninstall_rocm ;;
        check)     check_rocm ;;
        help)      show_help ;;
        *)         abort "Unknown action: $action. Try '$0 help'" ;;
    esac
done



