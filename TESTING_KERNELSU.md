# KernelSU & SUSFS Testing Configuration

## Overview
This document describes the testing configuration for kernel 4.9 with KernelSU manager and SUSFS support enabled.

## Enabled Features

### KernelSU Core
- `CONFIG_KSU=y` - KernelSU function support
- `CONFIG_KSU_DEBUG=y` - Debug mode for testing and development
- `CONFIG_KSU_LSM_SECURITY_HOOKS=y` - LSM security hooks integration
- `CONFIG_KSU_MANUAL_HOOK=y` - Manual hook support

### SUSFS (Kernel-level hiding framework)
- `CONFIG_KSU_SUSFS=y` - SUSFS main support
- `CONFIG_KSU_SUSFS_ENABLE_LOG=y` - Enable logging for debugging

#### Path Hiding
- `CONFIG_KSU_SUSFS_SUS_PATH=y` - Hide specific paths from detection
- `CONFIG_KSU_SUSFS_SUS_MOUNT=y` - Hide mount points
- `CONFIG_KSU_SUSFS_SUS_KSTAT=y` - Hide file statistics
- `CONFIG_KSU_SUSFS_SUS_OVERLAYFS=y` - Hide overlayfs mounts

#### Mount Management
- `CONFIG_KSU_SUSFS_TRY_UMOUNT=y` - Automatic unmount support
- `CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y` - Auto-add KernelSU default mounts
- `CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y` - Auto-add bind mounts
- `CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y` - Auto-unmount bind mounts
- `CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y` - **Magic mount support for KernelSU manager**

#### Advanced Hiding
- `CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y` - Hide KernelSU/SUSFS symbols
- `CONFIG_KSU_SUSFS_SPOOF_UNAME=y` - Spoof kernel version information
- `CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y` - Spoof kernel command line
- `CONFIG_KSU_SUSFS_OPEN_REDIRECT=y` - Redirect file open operations
- `CONFIG_KSU_SUSFS_SUS_SU=y` - **Hide su binary for better stealth**

## Changes Made for Testing

### 1. Enable KernelSU Manager Support
Changed `CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT` from `n` to `y`:
- Enables magic mount functionality required by KernelSU manager app
- Allows dynamic module mounting without system modifications

### 2. Enable SU Binary Hiding
Changed `CONFIG_KSU_SUSFS_SUS_SU` from `n` to `y`:
- Hides su binary from detection by root-checking apps
- Improves stealth capabilities for testing

### 3. Enable Debug Mode
Added `CONFIG_KSU_DEBUG=y`:
- Enables debug logging for development and testing
- Helps troubleshoot issues during testing phase

## Building for Testing

```bash
# Use the provided build script
./build_kernel.sh

# Or manually:
export ARCH=arm64
make O=out a20s_eur_open_defconfig
make O=out -j$(nproc)
```

## Testing Checklist

- [ ] KernelSU manager app can be installed
- [ ] Magic mount functionality works
- [ ] Root access can be granted/revoked
- [ ] SUSFS hiding features work correctly
- [ ] No kernel panics or crashes
- [ ] System stability under load
- [ ] SafetyNet/Play Integrity bypass (if applicable)

## Version Information

- Kernel Version: 4.9
- KernelSU: Integrated
- SUSFS Version: v1.5.5 (NON-GKI variant)
- Device: Samsung Galaxy A20s (a20s_eur_open)

## Notes

- Debug mode should be disabled for production builds
- All SUSFS features are enabled for comprehensive testing
- Configuration file: `arch/arm64/configs/a20s_eur_open_defconfig`

## References

- KernelSU: https://github.com/tiann/KernelSU
- SUSFS: Integrated kernel-level hiding framework
