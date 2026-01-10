# Samsung Galaxy A20s Kernel - KernelSU & SUSFS Edition

[![Kernel Version](https://img.shields.io/badge/Kernel-4.9.x-blue.svg)](https://github.com/riski0/android_kernel_samsung_a20s)
[![Android](https://img.shields.io/badge/Android-10%20(Q)-green.svg)](https://github.com/riski0/android_kernel_samsung_a20s)
[![KernelSU](https://img.shields.io/badge/KernelSU-Enabled-orange.svg)](https://kernelsu.org/)
[![SUSFS](https://img.shields.io/badge/SUSFS-v1.5.5-red.svg)](https://github.com/riski0/android_kernel_samsung_a20s)
[![CI Build](https://github.com/riski0/android_kernel_samsung_a20s/actions/workflows/kernel-ci.yml/badge.svg)](https://github.com/riski0/android_kernel_samsung_a20s/actions/workflows/kernel-ci.yml)

Custom kernel for Samsung Galaxy A20s with integrated KernelSU and SUSFS support for advanced root management and detection bypass.

## 🌟 Features

### KernelSU Integration
- ✅ **Full KernelSU Support** - Kernel-level root solution
- ✅ **Manager App Compatible** - Works with official KernelSU manager
- ✅ **Debug Mode** - Enhanced logging for development
- ✅ **LSM Security Hooks** - Proper security integration
- ✅ **Magic Mount Support** - Dynamic module mounting

### SUSFS Framework (v1.5.5)
Complete kernel-level hiding capabilities:

#### Hiding Features
- 🛡️ Path hiding (SUS_PATH)
- 🛡️ Mount point hiding (SUS_MOUNT)
- 🛡️ File statistics hiding (SUS_KSTAT)
- 🛡️ Overlayfs hiding (SUS_OVERLAYFS)
- 🛡️ SU binary hiding (SUS_SU)
- 🛡️ Symbol hiding (KernelSU/SUSFS)

#### Spoofing Capabilities
- 🎭 Kernel version spoofing (uname)
- 🎭 Command line spoofing
- 🎭 Boot config spoofing
- 🎭 File open redirection

#### Management
- ⚙️ Automatic mount management
- ⚙️ Bind mount auto-add/umount
- ⚙️ Try-umount support
- ⚙️ Debug logging enabled

## 📋 Device Information

| Specification | Details |
|---------------|---------|
| **Device** | Samsung Galaxy A20s |
| **Model** | SM-A207F/DS |
| **Codename** | a20s |
| **SoC** | Qualcomm Snapdragon 450 |
| **Architecture** | ARM64 (aarch64) |
| **Android Version** | 10 (Q) |
| **Kernel Version** | 4.9.x |

## 🚀 Quick Start

### Prerequisites
- Unlocked bootloader
- Custom recovery (TWRP recommended)
- Basic knowledge of kernel flashing
- Backup of current boot partition

### Installation

1. **Download Pre-built Kernel (Recommended)**
   - Visit [GitHub Actions](https://github.com/riski0/android_kernel_samsung_a20s/actions/workflows/kernel-ci.yml)
   - Download the latest successful build artifacts
   - Extract the kernel Image and DTBs from the artifacts

   **OR Clone and Build from Source:**
   ```bash
   git clone -b testing/enable-kernelsu-manager https://github.com/riski0/android_kernel_samsung_a20s.git
   cd android_kernel_samsung_a20s
   ```

2. **Build from Source (Optional)**
   ```bash
   # Install dependencies
   sudo apt install -y build-essential bc bison flex libssl-dev libelf-dev git device-tree-compiler
   
   # Download toolchains
   mkdir -p toolchain && cd toolchain
   git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
   git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc
   cd ..
   
   # Build
   chmod +x build_kernel_improved.sh
   ./build_kernel_improved.sh
   ```

3. **Flash Kernel**
   - Boot to recovery
   - Flash AnyKernel3 zip, or
   - Use fastboot: `fastboot flash boot boot.img`

4. **Install KernelSU Manager**
   - Download from [KernelSU Releases](https://github.com/tiann/KernelSU/releases)
   - Install APK
   - Grant root access

## 🤖 Continuous Integration

This repository includes automated CI/CD via GitHub Actions that builds the kernel on every push to the `main` branch.

### Automated Build Features
- ✅ **Automatic Compilation** - Kernel is built automatically on push
- ✅ **Artifact Storage** - Build artifacts stored for 30 days
- ✅ **Build Verification** - Ensures kernel compiles successfully
- ✅ **Multiple Formats** - Image, Image.gz, Image.lz4, and DTBs

### Accessing CI Builds
1. Go to [Actions tab](https://github.com/riski0/android_kernel_samsung_a20s/actions/workflows/kernel-ci.yml)
2. Select the latest successful workflow run
3. Download the artifacts (requires GitHub login)
4. Extract and use the kernel images

### Build Artifacts Include
- `Image` - Uncompressed kernel image
- `Image.gz` - Gzip compressed kernel
- `Image.lz4` - LZ4 compressed kernel  
- `*.dtb` - Device tree binaries for SDM450
- `*.ko` - Kernel modules (if any)
- `BUILD_INFO.txt` - Build information and version details

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) | Complete build guide with toolchain setup |
| [RELEASE_NOTES.md](RELEASE_NOTES.md) | Release information and changelog |
| [TESTING_KERNELSU.md](TESTING_KERNELSU.md) | Testing configuration details |
| [DOWNLOAD_LINKS.md](DOWNLOAD_LINKS.md) | Download links and resources |

## 🔧 Configuration

### Enabled Kernel Options

```ini
# KernelSU Core
CONFIG_KSU=y
CONFIG_KSU_DEBUG=y
CONFIG_KSU_LSM_SECURITY_HOOKS=y
CONFIG_KSU_MANUAL_HOOK=y

# SUSFS Framework
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y

# Hiding Features
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_SUS_OVERLAYFS=y
CONFIG_KSU_SUSFS_SUS_SU=y

# Advanced Features
CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y
CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y

# Auto Management
CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y
CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y
CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y
CONFIG_KSU_SUSFS_TRY_UMOUNT=y
```

## 🧪 Testing

### Verification Commands

```bash
# Check kernel version
adb shell uname -a

# Verify KernelSU
adb shell su -c "id"

# Check KernelSU logs
adb shell su -c "dmesg | grep ksu"

# Check SUSFS logs
adb shell su -c "dmesg | grep susfs"

# List mounts
adb shell su -c "mount | grep overlay"
```

### Testing Checklist

- [ ] Device boots successfully
- [ ] No kernel panic or bootloop
- [ ] KernelSU manager installs and works
- [ ] Root access can be granted/revoked
- [ ] SUSFS hiding features functional
- [ ] System stability (no random reboots)
- [ ] Acceptable performance
- [ ] Battery life normal

## 📦 Build Output

After successful build:

```
out/arch/arm64/boot/
├── Image              # Main kernel image (~25MB)
├── dtb.img            # Device tree blob
└── dtbo.img           # Device tree overlay

out/
├── vmlinux            # Kernel with debug symbols
├── System.map         # Symbol table
└── .config            # Build configuration
```

## 🔗 Links & Resources

### Official Resources
- **KernelSU:** https://kernelsu.org/
- **KernelSU GitHub:** https://github.com/tiann/KernelSU
- **KernelSU Manager:** [Download Latest](https://github.com/tiann/KernelSU/releases)

### Community
- **Telegram:** https://t.me/KernelSU
- **XDA Thread:** Coming soon

### Tools
- **AnyKernel3:** https://github.com/osm0sis/AnyKernel3
- **Proton Clang:** https://github.com/kdrag0n/proton-clang

## ⚠️ Disclaimer

**This is a TESTING BUILD with debug mode enabled.**

- Not recommended for daily production use
- May void device warranty
- Flash at your own risk
- Always backup before flashing
- Author not responsible for bricked devices

## 🐛 Known Issues

- Debug mode may slightly impact performance
- Some root detection apps may still detect root
- Battery life may be slightly affected in debug mode

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 Changelog

### 2024-01-08 - Testing Build
- ✅ Enabled CONFIG_KSU_DEBUG for testing
- ✅ Enabled CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT
- ✅ Enabled CONFIG_KSU_SUSFS_SUS_SU
- ✅ Added comprehensive documentation
- ✅ Improved build scripts

### Previous
- ✅ Initial KernelSU integration
- ✅ SUSFS framework integration
- ✅ All hiding features enabled

## 📄 License

- **Kernel Source:** GPL v2 (Samsung Electronics)
- **KernelSU:** GPL v3
- **SUSFS:** Integrated component
- **Documentation:** CC BY-SA 4.0

## 👥 Credits

- **Samsung Electronics** - Original kernel source
- **tiann** - KernelSU developer
- **SUSFS Team** - Hiding framework
- **Community** - Testing and feedback

## 📞 Support

### Getting Help

1. Read all documentation files
2. Check existing GitHub issues
3. Collect kernel logs: `adb shell dmesg`
4. Create detailed issue report

### Useful Commands

```bash
# Full kernel log
adb shell dmesg > kernel.log

# KernelSU specific
adb shell su -c "dmesg | grep -i ksu" > ksu.log

# SUSFS specific
adb shell su -c "dmesg | grep -i susfs" > susfs.log

# Check configuration
adb shell su -c "cat /proc/config.gz | gunzip | grep KSU"
```

---

**Repository:** https://github.com/riski0/android_kernel_samsung_a20s  
**Branch:** testing/enable-kernelsu-manager  
**Last Updated:** 2024-01-08

**⭐ Star this repository if you find it useful!**
