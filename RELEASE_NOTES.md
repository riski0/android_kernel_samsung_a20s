# Samsung Galaxy A20s Kernel - KernelSU & SUSFS Edition

## Release Information

**Device:** Samsung Galaxy A20s (SM-A207F/DS)  
**Kernel Version:** 4.9.x  
**Android Version:** Android 10 (Q)  
**Build Date:** 2024-01-08  
**Branch:** testing/enable-kernelsu-manager

## Features

### ✨ KernelSU Integration
- **Full KernelSU Support** - Kernel-level root solution
- **KernelSU Manager Compatible** - Works with official KernelSU manager app
- **Debug Mode Enabled** - For testing and development purposes
- **LSM Security Hooks** - Proper security integration

### 🛡️ SUSFS (Kernel-level Hiding Framework)
Complete stealth capabilities for root detection bypass:

#### Path & Mount Hiding
- ✅ Hide specific paths from detection (SUS_PATH)
- ✅ Hide mount points (SUS_MOUNT)
- ✅ Hide file statistics (SUS_KSTAT)
- ✅ Hide overlayfs mounts (SUS_OVERLAYFS)

#### Advanced Features
- ✅ **Magic Mount Support** - Dynamic module mounting
- ✅ **SU Binary Hiding** - Hide su binary from detection
- ✅ Automatic mount management
- ✅ Bind mount auto-add and auto-umount
- ✅ Symbol hiding (KernelSU/SUSFS symbols)

#### Spoofing Capabilities
- ✅ Kernel version spoofing (uname)
- ✅ Kernel command line spoofing
- ✅ Boot config spoofing
- ✅ File open redirection

#### Logging
- ✅ Debug logging enabled for troubleshooting
- ✅ Detailed SUSFS operation logs

## What's New in This Build

### Configuration Changes
1. **Enabled CONFIG_KSU_DEBUG** - Debug mode for testing
2. **Enabled CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT** - Required for KernelSU manager
3. **Enabled CONFIG_KSU_SUSFS_SUS_SU** - Hide su binary for better stealth

### Previous Features (Already Enabled)
- KernelSU core functionality
- SUSFS framework
- All hiding and spoofing features
- Automatic mount management
- LSM security hooks

## Download Links

### Pre-built Images

**Note:** Due to build environment limitations, pre-built images are not available in this repository. Please build from source using the instructions below.

### Source Code

**GitHub Repository:**
```
https://github.com/riski0/android_kernel_samsung_a20s
```

**Clone Command:**
```bash
git clone https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
git checkout testing/enable-kernelsu-manager
```

## Building from Source

### Quick Start

1. **Install Dependencies:**
```bash
sudo apt update
sudo apt install -y build-essential bc bison flex libssl-dev \
    libelf-dev git wget curl zip unzip python3 device-tree-compiler
```

2. **Download Toolchains:**
```bash
mkdir -p toolchain && cd toolchain
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc
cd ..
```

3. **Build Kernel:**
```bash
./build_kernel_improved.sh
```

### Detailed Instructions
See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for complete build guide.

## Installation

### Prerequisites
- Unlocked bootloader
- Custom recovery (TWRP recommended)
- Backup of current boot.img

### Method 1: Using AnyKernel3 (Recommended)

1. Download/build AnyKernel3 flashable zip
2. Boot to recovery
3. Flash the zip file
4. Reboot
5. Install KernelSU manager app

### Method 2: Fastboot Flash

```bash
# Flash boot image
fastboot flash boot boot-kernelsu.img
fastboot reboot
```

### Method 3: Using Magisk/KernelSU Manager

1. Copy boot-kernelsu.img to device
2. Use KernelSU manager to install
3. Reboot

## Post-Installation

### 1. Install KernelSU Manager

Download from: https://github.com/tiann/KernelSU/releases

### 2. Verify Installation

```bash
# Check kernel version
adb shell uname -r

# Check KernelSU
adb shell su -c "id"

# Check SUSFS
adb shell su -c "dmesg | grep susfs"
```

### 3. Configure SUSFS

Use KernelSU manager app to configure hiding features:
- Add apps to hide list
- Configure mount hiding
- Enable/disable specific features

## Testing Checklist

After installation, verify:

- [ ] Device boots successfully
- [ ] No bootloop or kernel panic
- [ ] KernelSU manager app works
- [ ] Root access can be granted/revoked
- [ ] SUSFS hiding features work
- [ ] System is stable (no random reboots)
- [ ] Performance is acceptable
- [ ] SafetyNet/Play Integrity status (if needed)

## Known Issues

### Current Limitations
- Debug mode is enabled (may impact performance slightly)
- Some root detection apps may still detect root
- Battery life may be slightly affected

### Troubleshooting

**Device won't boot:**
- Flash stock boot.img from recovery
- Check if bootloader is properly unlocked

**KernelSU not working:**
- Verify kernel version in Settings > About Phone
- Reinstall KernelSU manager app
- Check logs: `adb shell dmesg | grep ksu`

**Root detection still works:**
- Configure SUSFS properly in KernelSU manager
- Add detecting apps to hide list
- Check SUSFS logs: `adb shell dmesg | grep susfs`

## Configuration Details

### Enabled Kernel Configs

```
CONFIG_KSU=y
CONFIG_KSU_DEBUG=y
CONFIG_KSU_LSM_SECURITY_HOOKS=y
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_TRY_UMOUNT=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y
CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y
CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y
CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y
CONFIG_KSU_SUSFS_SUS_OVERLAYFS=y
CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SUS_SU=y
CONFIG_KSU_MANUAL_HOOK=y
```

## Version Information

- **Kernel:** Linux 4.9.x
- **KernelSU:** Integrated (latest)
- **SUSFS:** v1.5.5 (NON-GKI variant)
- **Defconfig:** a20s_eur_open_defconfig

## Credits

- **KernelSU:** [tiann](https://github.com/tiann/KernelSU)
- **SUSFS:** Integrated hiding framework
- **Original Kernel:** Samsung Electronics
- **Build Configuration:** Enhanced for testing

## Disclaimer

⚠️ **WARNING:**
- This is a **TESTING BUILD** with debug mode enabled
- Not recommended for daily use in production
- May void warranty
- Flash at your own risk
- Always backup your data before flashing

## Support & Community

### Reporting Issues
- Check existing issues first
- Provide kernel logs: `adb shell dmesg`
- Include device info and steps to reproduce

### Useful Commands

```bash
# Kernel logs
adb shell dmesg | grep -E "ksu|susfs"

# Check root
adb shell su -c "id"

# Check mounts
adb shell su -c "mount | grep overlay"

# SUSFS status
adb shell su -c "cat /proc/susfs"
```

## License

This kernel is based on Samsung's GPL-licensed kernel source code.
- Kernel: GPL v2
- KernelSU: GPL v3
- SUSFS: Integrated component

## Changelog

### 2024-01-08 - Testing Build
- ✅ Enabled KernelSU debug mode
- ✅ Enabled magic mount support
- ✅ Enabled SU binary hiding
- ✅ Updated build scripts
- ✅ Added comprehensive documentation

### Previous
- ✅ Initial KernelSU integration
- ✅ SUSFS framework integration
- ✅ All hiding features enabled

---

**For detailed build instructions, see:** [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)  
**For testing guide, see:** [TESTING_KERNELSU.md](TESTING_KERNELSU.md)
