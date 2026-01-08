# KernelSU-Next & susfs4ksu Build Guide
## Samsung Galaxy A20s (Kernel 4.9)

**Build Date:** 2024-01-08  
**Status:** ✅ Ready for Build

---

## 📦 What's Included

### KernelSU-Next (Magic Version)
- **Repository:** https://github.com/backslashxx/KernelSU
- **Version:** v3.0.0+
- **Type:** Magic/Enhanced version by @backslashxx
- **Features:**
  - Enhanced root management
  - Better compatibility
  - Advanced features
  - Active development

### susfs4ksu
- **Repository:** https://gitlab.com/simonpunk/susfs4ksu
- **Version:** Latest (kernel 4.9 patches)
- **Developer:** @simonpunk
- **Features:**
  - Advanced hiding capabilities
  - Path hiding
  - Mount hiding
  - Kstat hiding
  - Uname spoofing
  - Open redirect
  - SU binary hiding

### NonGKI Kernel Build Methodology
- **Repository:** https://github.com/hseyinblgc/NonGKI_Kernel_Build_2nd
- **Purpose:** Structured build system for Non-GKI kernels
- **Benefits:**
  - Organized patch management
  - Easy integration
  - Automated workflows

---

## 🌟 Features Enabled

### KernelSU-Next Core
- ✅ Full KernelSU-Next support
- ✅ Magic enhancements
- ✅ Debug mode (for testing)
- ✅ Enhanced compatibility

### susfs4ksu Features
- ✅ **Path Hiding** (CONFIG_KSU_SUSFS_SUS_PATH)
  - Hide specific paths from detection
  
- ✅ **Mount Hiding** (CONFIG_KSU_SUSFS_SUS_MOUNT)
  - Hide mount points
  
- ✅ **Kstat Hiding** (CONFIG_KSU_SUSFS_SUS_KSTAT)
  - Hide file statistics
  
- ✅ **Try Umount** (CONFIG_KSU_SUSFS_TRY_UMOUNT)
  - Automatic unmount support
  
- ✅ **Uname Spoofing** (CONFIG_KSU_SUSFS_SPOOF_UNAME)
  - Spoof kernel version
  
- ✅ **Open Redirect** (CONFIG_KSU_SUSFS_OPEN_REDIRECT)
  - Redirect file open operations
  
- ✅ **SU Binary Hiding** (CONFIG_KSU_SUSFS_SUS_SU)
  - Hide su binary from detection
  
- ✅ **Debug Logging** (CONFIG_KSU_SUSFS_ENABLE_LOG)
  - Detailed logging for debugging

---

## 🚀 Quick Start

### Prerequisites
```bash
# Install dependencies
sudo apt update
sudo apt install -y build-essential bc bison flex libssl-dev \
    libelf-dev git device-tree-compiler ccache
```

### Step 1: Clone Repository
```bash
git clone -b testing/enable-kernelsu-manager \
    https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
```

### Step 2: Setup KernelSU-Next & susfs4ksu
```bash
# Run automated setup script
chmod +x setup_kernelsu_next_susfs.sh
./setup_kernelsu_next_susfs.sh
```

**What this does:**
1. Verifies kernel directory
2. Checks KernelSU-Next installation
3. Clones susfs4ksu if needed
4. Copies susfs source files
5. Integrates susfs with KernelSU-Next
6. Updates Makefile and Kconfig
7. Applies kernel patches
8. Updates defconfig
9. Creates build info

### Step 3: Download Toolchains
```bash
mkdir -p toolchain && cd toolchain

# Proton Clang
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang

# GCC Toolchain
git clone --depth=1 \
    https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git \
    gcc

cd ..
```

### Step 4: Build Kernel
```bash
chmod +x build_kernel_improved.sh
./build_kernel_improved.sh
```

**Build time:** 30-60 minutes

### Step 5: Create Flashable ZIP
```bash
./create_flashable_zip.sh
```

**Output:** `KernelSU-A20s-Next-YYYYMMDD-HHMM.zip`

---

## 📋 Manual Integration (Advanced)

If you prefer manual integration:

### 1. Replace KernelSU with KernelSU-Next
```bash
rm -rf KernelSU
git clone https://github.com/backslashxx/KernelSU.git KernelSU
```

### 2. Clone susfs4ksu
```bash
git clone https://gitlab.com/simonpunk/susfs4ksu.git
```

### 3. Copy susfs Files
```bash
# Copy source files
cp susfs4ksu/kernel_patches/fs/susfs.c fs/
cp susfs4ksu/kernel_patches/include/linux/susfs.h include/linux/

# Copy patches
cp susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch KernelSU/
cp susfs4ksu/kernel_patches/50_add_susfs_in_kernel-4.9.patch .
```

### 4. Apply Patches
```bash
# Apply KernelSU patch (may have conflicts with KernelSU-Next)
cd KernelSU
patch -p1 < 10_enable_susfs_for_ksu.patch
cd ..

# Apply kernel patch
patch -p1 < 50_add_susfs_in_kernel-4.9.patch
```

### 5. Update Kconfig
Add to `KernelSU/kernel/Kconfig`:
```kconfig
config KSU_SUSFS
	bool "KernelSU SUSFS support"
	depends on KSU
	default y
	help
	  Enable SUSFS support for KernelSU.

# Add other SUSFS configs...
```

### 6. Update Makefile
Add to `KernelSU/kernel/Makefile`:
```makefile
obj-$(CONFIG_KSU_SUSFS) += ../../fs/susfs.o
```

Add to `fs/Makefile`:
```makefile
obj-$(CONFIG_KSU_SUSFS) += susfs.o
```

### 7. Update Defconfig
Add to `arch/arm64/configs/a20s_eur_open_defconfig`:
```
CONFIG_KSU=y
CONFIG_KSU_DEBUG=y
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_TRY_UMOUNT=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SUS_SU=y
```

---

## 🔍 Verification

### Check Configuration
```bash
# After building
grep "CONFIG_KSU" out/.config
grep "CONFIG_KSU_SUSFS" out/.config
```

### Expected Output
```
CONFIG_KSU=y
CONFIG_KSU_DEBUG=y
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_TRY_UMOUNT=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SUS_SU=y
```

### Check Kernel Version
```bash
strings out/arch/arm64/boot/Image | grep "Linux version"
```

### Check KernelSU-Next Integration
```bash
strings out/vmlinux | grep -i "kernelsu\|ksu_" | head -10
```

### Check susfs Integration
```bash
strings out/vmlinux | grep -i "susfs" | head -10
```

---

## 📱 Post-Installation

### 1. Flash Kernel
```bash
# Via TWRP
adb push KernelSU-A20s-Next-*.zip /sdcard/
# Flash in TWRP

# Via Fastboot
fastboot flash boot boot.img
fastboot reboot
```

### 2. Install KernelSU Manager
- **Download:** https://github.com/tiann/KernelSU/releases/latest
- **Note:** Use standard KernelSU Manager app
- **Compatibility:** Works with KernelSU-Next

### 3. Install susfs Tools
```bash
# Build susfs tools
cd susfs4ksu
./build_ksu_susfs_tool.sh

# Push to device
adb push ksu_module_susfs/tools/ksu_susfs_arm64 /data/adb/ksu/bin/ksu_susfs
adb shell chmod 755 /data/adb/ksu/bin/ksu_susfs
```

### 4. Verify Installation
```bash
# Check kernel
adb shell uname -a

# Check KernelSU
adb shell su -c "id"

# Check susfs
adb shell su -c "ksu_susfs --help"

# Check logs
adb shell dmesg | grep -E "ksu|susfs"
```

---

## 🛠️ Using susfs Tools

### Basic Commands
```bash
# Show help
adb shell su -c "ksu_susfs --help"

# Add path to hide
adb shell su -c "ksu_susfs add_sus_path /system/bin/su"

# Add mount to hide
adb shell su -c "ksu_susfs add_sus_mount /data/adb"

# Enable uname spoofing
adb shell su -c "ksu_susfs enable_spoof_uname"

# List hidden paths
adb shell su -c "ksu_susfs list_sus_path"
```

### Advanced Usage
See susfs4ksu documentation:
- https://gitlab.com/simonpunk/susfs4ksu

---

## 🐛 Troubleshooting

### Build Errors

**Error: "patch failed"**
- Some patches may fail due to KernelSU-Next differences
- Check `.rej` files for failed hunks
- Apply manually if needed

**Error: "CONFIG_KSU_SUSFS not found"**
- Run setup script again
- Check Kconfig file manually

### Runtime Issues

**KernelSU not working:**
```bash
# Check kernel version
adb shell uname -a

# Check logs
adb shell dmesg | grep ksu
```

**susfs not working:**
```bash
# Check if susfs is loaded
adb shell dmesg | grep susfs

# Check susfs tool
adb shell su -c "which ksu_susfs"
```

**Device won't boot:**
- Flash stock boot.img
- Check kernel logs
- Disable debug mode in defconfig

---

## 📊 Differences from Standard KernelSU

### KernelSU-Next (Magic) vs Standard KernelSU

| Feature | Standard KernelSU | KernelSU-Next (Magic) |
|---------|-------------------|------------------------|
| **Developer** | @tiann | @backslashxx |
| **Base** | Official KernelSU | Enhanced fork |
| **Features** | Standard | Enhanced + Magic |
| **Updates** | Official releases | Independent |
| **Compatibility** | Wide | Optimized |
| **Manager App** | Official | Compatible |

### Why KernelSU-Next?
- ✅ Enhanced features
- ✅ Better compatibility with susfs
- ✅ Active development
- ✅ Magic enhancements
- ✅ Community support

---

## 📚 Resources

### Official Links

**KernelSU-Next:**
- Repository: https://github.com/backslashxx/KernelSU
- Developer: @backslashxx

**susfs4ksu:**
- Repository: https://gitlab.com/simonpunk/susfs4ksu
- Developer: @simonpunk
- Telegram: @simonpunk

**NonGKI Kernel Build:**
- Repository: https://github.com/hseyinblgc/NonGKI_Kernel_Build_2nd
- Wiki: https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/wiki

**Standard KernelSU:**
- Website: https://kernelsu.org/
- Repository: https://github.com/tiann/KernelSU
- Manager: https://github.com/tiann/KernelSU/releases

### Community

**Telegram:**
- KernelSU: https://t.me/KernelSU
- susfs: @simonpunk

**XDA:**
- Coming soon

---

## ⚠️ Important Notes

### This is a Testing Build
- Debug mode enabled
- Not for production use
- May have bugs
- Performance may vary

### Compatibility
- **Manager App:** Use standard KernelSU Manager
- **Modules:** Most KernelSU modules should work
- **susfs:** Requires susfs-patched kernel

### Differences from Previous Build
- Uses KernelSU-Next instead of standard KernelSU
- Integrated susfs4ksu instead of old SUSFS
- Better hiding capabilities
- More active development

---

## 📝 Changelog

### 2024-01-08 - KernelSU-Next & susfs4ksu Integration
- ✅ Replaced standard KernelSU with KernelSU-Next (Magic)
- ✅ Integrated susfs4ksu (latest version)
- ✅ Created automated setup script
- ✅ Updated build system
- ✅ Added comprehensive documentation
- ✅ All hiding features enabled

### Previous (Standard KernelSU)
- ✅ Standard KernelSU integration
- ✅ Old SUSFS framework
- ✅ Basic hiding features

---

## 🤝 Credits

- **@backslashxx** - KernelSU-Next (Magic version)
- **@simonpunk** - susfs4ksu developer
- **@tiann** - Original KernelSU
- **@hseyinblgc** - NonGKI Kernel Build methodology
- **Samsung Electronics** - Original kernel source
- **Community** - Testing and feedback

---

## 📜 License

- **Kernel:** GPL v2
- **KernelSU-Next:** GPL v3
- **susfs4ksu:** GPL v3
- **Documentation:** CC BY-SA 4.0

---

## 📞 Support

### Getting Help
1. Check documentation
2. Review susfs4ksu README
3. Check KernelSU-Next issues
4. Contact @simonpunk on Telegram

### Reporting Issues
Include:
- Device model
- Kernel version
- Build date
- Error logs
- Steps to reproduce

---

**Repository:** https://github.com/riski0/android_kernel_samsung_a20s  
**Branch:** testing/enable-kernelsu-manager  
**Status:** ✅ Ready for Build with KernelSU-Next & susfs4ksu  
**Last Updated:** 2024-01-08

**Happy Building! 🚀**
