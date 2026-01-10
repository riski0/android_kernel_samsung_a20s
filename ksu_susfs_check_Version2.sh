#!/usr/bin/env bash
# ksu_susfs_check.sh
# Non-destructive basic checks for KernelSU-Next + susfs on a connected device via adb.
# Usage: ./ksu_susfs_check.sh
# Requirements: adb on PATH, device unlocked for adb, run from host machine.
# NOTE: Run only on test devices. This script collects logs and does not modify device state.

set -u

OUTDIR="ksu_susfs_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

log() { printf '%s\n' "$*" | tee -a "$OUTDIR/run.log"; }

log "Starting KernelSU-Next + susfs quick check"
log "Output directory: $OUTDIR"

# 1) adb connected
log "Checking adb devices..."
ADB_DEVICES=$(adb devices | sed -n '2,$p' | sed '/^$/d')
if [ -z "$ADB_DEVICES" ]; then
  log "ERROR: No adb devices found. Connect device and enable adb."
  exit 1
fi
log "Connected devices:"
echo "$ADB_DEVICES" | tee -a "$OUTDIR/devices.txt"

# Choose first device (if multiple)
DEVICE_SER=$(echo "$ADB_DEVICES" | head -n1 | awk '{print $1}')
log "Using device: $DEVICE_SER"

# Helper to run adb shell command and save
run_shell() {
  local name="$1"; shift
  log "Running: adb -s $DEVICE_SER shell \"$*\""
  adb -s "$DEVICE_SER" shell "$@" 2>&1 | tee "$OUTDIR/$name.txt"
}

# Collect basic system info
run_shell uname "uname -a"
run_shell uptime "uptime"
run_shell getprop "getprop ro.build.fingerprint; getprop ro.product.model; getprop ro.product.device"

# dmesg (head + full)
log "Collecting dmesg head..."
run_shell dmesg_head "dmesg | head -n 200"
log "Collecting full dmesg (may require time)..."
adb -s "$DEVICE_SER" shell "dmesg" > "$OUTDIR/dmesg_full.txt" 2>&1 || log "Warning: dmesg may be restricted"

# /proc files
run_shell proc_filesystems "cat /proc/filesystems || true"
run_shell proc_mounts "cat /proc/mounts || true"
run_shell proc_modules "cat /proc/modules || true"

# Check for susfs in filesystems
log "Checking for 'susfs' in /proc/filesystems..."
adb -s "$DEVICE_SER" shell "grep -i susfs /proc/filesystems || true" | tee -a "$OUTDIR/proc_filesystems.txt"

# Check /proc/config.gz for KSU/SUSFS (if available)
log "Checking /proc/config.gz for KSU/SUSFS (if available)..."
adb -s "$DEVICE_SER" shell "if [ -f /proc/config.gz ]; then zcat /proc/config.gz | grep -E 'KSU|SUSFS' || true; else echo '/proc/config.gz not found'; fi" > "$OUTDIR/proc_config_gz_check.txt" 2>&1

# Check mount entries for susfs
log "Checking mounts for susfs..."
adb -s "$DEVICE_SER" shell "cat /proc/mounts | grep -i susfs || true" > "$OUTDIR/mounts_susfs.txt" 2>&1

# Check su behavior (non-interactive)
log "Testing 'su -c id' (may fail if su prompts or not installed)..."
adb -s "$DEVICE_SER" shell "su -c id 2>&1" > "$OUTDIR/su_id.txt" || true
log "su -c id output (saved to $OUTDIR/su_id.txt)"

# Check which su
run_shell which_su "which su || true"

# Search kernel logs and logcat for ksu/susfs keywords
log "Collecting kernel and logcat entries for keywords..."
adb -s "$DEVICE_SER" shell "dmesg | grep -i -E 'susfs|ksu|kernelsu|kernelsu-next' || true" > "$OUTDIR/dmesg_susfs_ksu.txt" 2>&1
adb -s "$DEVICE_SER" logcat -d | grep -i -E 'susfs|ksu|kernelsu|kernelsu-next' > "$OUTDIR/logcat_susfs_ksu.txt" 2>&1 || true

# SELinux mode
run_shell selinux "getenforce || true"

# Quick checks summary
log "Quick checks summary:"
if grep -qi susfs "$OUTDIR/proc_filesystems.txt" || grep -qi susfs "$OUTDIR/mounts_susfs.txt"; then
  log " - susfs appears present in filesystems or mounts"
else
  log " - susfs NOT detected in /proc/filesystems or mounts"
fi

if grep -qi 'uid=0' "$OUTDIR/su_id.txt" 2>/dev/null; then
  log " - su -c id returned uid=0 (root access available)"
else
  log " - su -c id did NOT return uid=0 (su may be missing, hidden, or require interaction)"
fi

log "All outputs saved to $OUTDIR. Review the files for details."
log "If you want, run more targeted tests (mount/unmount, manager install, SELinux AVC search)."

exit 0
