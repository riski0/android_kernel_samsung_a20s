# Download Links - Samsung Galaxy A20s KernelSU Kernel

## 📦 Pre-built Images

### ⚠️ Important Notice

Pre-built kernel images are **not available** in this repository due to:
1. Build environment requires specific Android toolchains
2. Large file size restrictions on Git repositories
3. Device-specific boot image requirements

**You must build from source** using the provided instructions.

## 🔧 Build from Source

### Quick Links

| Resource | Link |
|----------|------|
| **Source Code** | [GitHub Repository](https://github.com/riski0/android_kernel_samsung_a20s) |
| **Testing Branch** | `testing/enable-kernelsu-manager` |
| **Build Instructions** | [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) |
| **Release Notes** | [RELEASE_NOTES.md](RELEASE_NOTES.md) |

### Clone Repository

```bash
# Clone with specific branch
git clone -b testing/enable-kernelsu-manager https://github.com/riski0/android_kernel_samsung_a20s.git

# Or clone and checkout
git clone https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
git checkout testing/enable-kernelsu-manager
```

## 🛠️ Required Tools & Dependencies

### Toolchains

#### Option 1: Proton Clang (Recommended)
```bash
# Clang
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git toolchain/clang

# GCC
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git toolchain/gcc
```

**Download Size:** ~500MB  
**Clang Version:** 14.0+  
**GCC Version:** 4.9

#### Option 2: Google Prebuilts
```bash
# Clang
git clone --depth=1 -b master https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone.git toolchain/clang

# GCC
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 toolchain/gcc
```

**Download Size:** ~600MB  
**Clang Version:** Latest AOSP  
**GCC Version:** 4.9

### Build Dependencies

```bash
# Ubuntu/Debian
sudo apt install -y \
    build-essential bc bison flex libssl-dev libelf-dev \
    git wget curl zip unzip python3 device-tree-compiler \
    ccache lz4 liblz4-tool
```

**Required Disk Space:** ~10GB (source + toolchains + build output)

## 📱 KernelSU Manager App

### Official KernelSU Manager

| Version | Download Link | Size |
|---------|---------------|------|
| **Latest** | [GitHub Releases](https://github.com/tiann/KernelSU/releases/latest) | ~10MB |
| **Stable** | [v0.7.0+](https://github.com/tiann/KernelSU/releases) | ~10MB |

**Installation:**
1. Download APK from GitHub releases
2. Install on device
3. Grant necessary permissions
4. Verify kernel compatibility

### Alternative Sources

- **F-Droid:** Coming soon
- **Direct APK:** Available on GitHub releases only

## 🔨 Build Scripts

### Enhanced Build Script

Located in repository: `build_kernel_improved.sh`

**Features:**
- Automatic toolchain detection
- Colored output
- Build time tracking
- Configuration verification
- Error handling

**Usage:**
```bash
# Standard build
./build_kernel_improved.sh

# Clean build
./build_kernel_improved.sh clean
```

### Original Build Script

Located in repository: `build_kernel.sh`

**Note:** Requires manual toolchain path configuration.

## 📚 Documentation Files

All documentation is included in the repository:

| Document | Description | Location |
|----------|-------------|----------|
| **BUILD_INSTRUCTIONS.md** | Complete build guide | Root directory |
| **RELEASE_NOTES.md** | Release information & features | Root directory |
| **TESTING_KERNELSU.md** | Testing configuration details | Root directory |
| **DOWNLOAD_LINKS.md** | This file | Root directory |

## 🌐 External Resources

### KernelSU Resources

| Resource | Link |
|----------|------|
| **Official Website** | https://kernelsu.org/ |
| **GitHub Repository** | https://github.com/tiann/KernelSU |
| **Documentation** | https://kernelsu.org/guide/what-is-kernelsu.html |
| **Telegram Group** | https://t.me/KernelSU |

### SUSFS Information

SUSFS is integrated into this kernel build. No separate download required.

**Features:**
- Kernel-level hiding framework
- Root detection bypass
- Mount point hiding
- Binary hiding capabilities

### AnyKernel3 (For Flashable Zip)

| Resource | Link |
|----------|------|
| **GitHub** | https://github.com/osm0sis/AnyKernel3 |
| **Template** | Clone and customize for A20s |

**Usage:**
```bash
git clone https://github.com/osm0sis/AnyKernel3.git
cd AnyKernel3
# Copy kernel Image
cp ../out/arch/arm64/boot/Image ./
# Create zip
zip -r9 KernelSU-A20s.zip * -x .git README.md
```

## 📊 Build Output

After successful build, you'll have:

```
out/arch/arm64/boot/
├── Image              # Main kernel image (~20-30MB)
├── Image.gz           # Compressed (if enabled)
├── dtb.img            # Device tree blob
└── dtbo.img           # Device tree overlay

out/
├── vmlinux            # Kernel with symbols (~100MB)
├── System.map         # Symbol table
└── .config            # Build configuration
```

## 🔐 Checksums & Verification

After building, generate checksums:

```bash
# MD5
md5sum out/arch/arm64/boot/Image > Image.md5

# SHA256
sha256sum out/arch/arm64/boot/Image > Image.sha256
```

**Verify before flashing:**
```bash
md5sum -c Image.md5
sha256sum -c Image.sha256
```

## 💾 Storage Requirements

| Component | Size | Purpose |
|-----------|------|---------|
| **Source Code** | ~1.5GB | Kernel source |
| **Toolchains** | ~500MB | Clang + GCC |
| **Build Output** | ~2GB | Compiled objects |
| **Final Image** | ~30MB | Flashable kernel |
| **Total** | ~4GB | Complete build |

## 🚀 Quick Start Guide

### 1. Prepare Environment
```bash
# Install dependencies
sudo apt update && sudo apt install -y build-essential bc bison flex \
    libssl-dev libelf-dev git device-tree-compiler

# Clone repository
git clone -b testing/enable-kernelsu-manager \
    https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
```

### 2. Download Toolchains
```bash
mkdir -p toolchain && cd toolchain
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc
cd ..
```

### 3. Build Kernel
```bash
chmod +x build_kernel_improved.sh
./build_kernel_improved.sh
```

### 4. Create Flashable Zip
```bash
git clone https://github.com/osm0sis/AnyKernel3.git
cd AnyKernel3
cp ../out/arch/arm64/boot/Image ./
zip -r9 ../KernelSU-A20s-$(date +%Y%m%d).zip * -x .git README.md
```

### 5. Flash & Install
```bash
# Copy to device
adb push KernelSU-A20s-*.zip /sdcard/

# Boot to recovery and flash
# Or use fastboot:
fastboot flash boot boot.img
```

## ❓ FAQ

### Q: Where can I download pre-built images?
**A:** Pre-built images are not provided. You must build from source.

### Q: How long does building take?
**A:** 15-30 minutes on modern hardware (depends on CPU cores).

### Q: Can I use different toolchains?
**A:** Yes, but Proton Clang or Google prebuilts are recommended.

### Q: Do I need a specific Linux distribution?
**A:** Ubuntu 20.04+ or Debian 11+ recommended. Other distros may work.

### Q: What if build fails?
**A:** Check BUILD_INSTRUCTIONS.md troubleshooting section.

## 📞 Support

### Getting Help

1. **Check Documentation:** Read all .md files in repository
2. **Search Issues:** Look for similar problems on GitHub
3. **Kernel Logs:** Collect logs with `adb shell dmesg`
4. **Create Issue:** Provide detailed information

### Useful Commands

```bash
# Check kernel version
adb shell uname -a

# KernelSU logs
adb shell su -c "dmesg | grep ksu"

# SUSFS logs
adb shell su -c "dmesg | grep susfs"

# Full kernel log
adb shell dmesg > kernel.log
```

## ⚖️ License

- **Kernel Source:** GPL v2 (Samsung)
- **KernelSU:** GPL v3
- **Documentation:** CC BY-SA 4.0

## 🔄 Updates

Check repository for updates:
```bash
cd android_kernel_samsung_a20s
git fetch origin
git checkout testing/enable-kernelsu-manager
git pull
```

---

**Last Updated:** 2024-01-08  
**Branch:** testing/enable-kernelsu-manager  
**Kernel Version:** 4.9.x with KernelSU & SUSFS
