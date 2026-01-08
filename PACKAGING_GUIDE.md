# Packaging Guide - Creating Flashable Images

## Overview

This guide explains how to create flashable images from the built kernel for Samsung Galaxy A20s with KernelSU and SUSFS support.

## Prerequisites

- Successfully built kernel (see BUILD_INSTRUCTIONS.md)
- Git installed
- Zip utility installed
- Internet connection (for first-time setup)

## Quick Start

### Automated Packaging

Use the provided script for automatic packaging:

```bash
# After building kernel
./create_flashable_zip.sh
```

This will:
1. Clone AnyKernel3 (if needed)
2. Copy kernel Image and dtb/dtbo
3. Create custom configuration
4. Generate flashable zip
5. Create checksums

### Output

```
KernelSU-A20s-YYYYMMDD-HHMM.zip       # Flashable zip (~25MB)
KernelSU-A20s-YYYYMMDD-HHMM.zip.md5   # MD5 checksum
KernelSU-A20s-YYYYMMDD-HHMM.zip.sha256 # SHA256 checksum
```

## Manual Packaging

### Method 1: AnyKernel3 (Recommended)

#### Step 1: Clone AnyKernel3

```bash
git clone https://github.com/osm0sis/AnyKernel3.git
cd AnyKernel3
```

#### Step 2: Configure for A20s

Edit `anykernel.sh`:

```bash
# Device properties
device.name1=a20s
device.name2=a207f
device.name3=SM-A207F
supported.versions=10

# Boot partition
block=/dev/block/by-name/boot;
is_slot_device=0;
```

#### Step 3: Copy Kernel Files

```bash
# Copy kernel image
cp ../out/arch/arm64/boot/Image ./

# Copy dtb/dtbo if available
cp ../out/arch/arm64/boot/dtb.img ./ 2>/dev/null || true
cp ../out/arch/arm64/boot/dtbo.img ./ 2>/dev/null || true
```

#### Step 4: Create Flashable Zip

```bash
# Create zip
zip -r9 ../KernelSU-A20s-$(date +%Y%m%d).zip * -x .git README.md .gitignore *placeholder

# Generate checksums
cd ..
md5sum KernelSU-A20s-*.zip > KernelSU-A20s-*.zip.md5
sha256sum KernelSU-A20s-*.zip > KernelSU-A20s-*.zip.sha256
```

### Method 2: Boot Image Creation

#### Prerequisites

```bash
# Install mkbootimg
pip3 install mkbootimg

# Or use Android Image Kitchen
git clone https://github.com/osm0sis/Android-Image-Kitchen.git
```

#### Step 1: Extract Original Boot Image

```bash
# From device
adb pull /dev/block/by-name/boot stock_boot.img

# Or from firmware
# Extract boot.img from firmware package
```

#### Step 2: Unpack Boot Image

Using mkbootimg:
```bash
mkdir boot_unpack
cd boot_unpack
python3 -m mkbootimg --unpack ../stock_boot.img
```

Using Android Image Kitchen:
```bash
cd Android-Image-Kitchen
./unpackimg.sh ../stock_boot.img
```

#### Step 3: Replace Kernel

```bash
# Copy new kernel
cp ../out/arch/arm64/boot/Image ./kernel

# Copy dtb if separate
cp ../out/arch/arm64/boot/dtb.img ./dtb 2>/dev/null || true
```

#### Step 4: Repack Boot Image

Using mkbootimg:
```bash
python3 -m mkbootimg \
    --kernel kernel \
    --ramdisk ramdisk \
    --dtb dtb \
    --cmdline "$(cat cmdline)" \
    --base $(cat base) \
    --pagesize $(cat pagesize) \
    --kernel_offset $(cat kernel_offset) \
    --ramdisk_offset $(cat ramdisk_offset) \
    --tags_offset $(cat tags_offset) \
    --os_version $(cat os_version) \
    --os_patch_level $(cat os_patch_level) \
    --header_version $(cat header_version) \
    -o ../boot-kernelsu.img
```

Using Android Image Kitchen:
```bash
./repackimg.sh
cp image-new.img ../boot-kernelsu.img
```

## Package Contents

### Flashable Zip Structure

```
KernelSU-A20s-YYYYMMDD.zip
├── Image                    # Kernel image
├── dtb.img                  # Device tree blob (optional)
├── dtbo.img                 # Device tree overlay (optional)
├── anykernel.sh             # Installation script
├── tools/
│   ├── ak3-core.sh          # AnyKernel3 core functions
│   └── busybox              # Busybox binary
├── README.md                # Installation instructions
└── CHANGELOG.md             # Version changelog
```

### Boot Image Structure

```
boot-kernelsu.img
├── Kernel                   # Compressed kernel
├── Ramdisk                  # Initial ramdisk
├── DTB                      # Device tree blob
└── Header                   # Boot image header
```

## Verification

### Before Distribution

1. **Check File Integrity**
```bash
# Verify zip is not corrupted
unzip -t KernelSU-A20s-*.zip

# Check kernel image
file out/arch/arm64/boot/Image
# Should show: Linux kernel ARM64 boot executable Image
```

2. **Verify Checksums**
```bash
# Generate checksums
md5sum KernelSU-A20s-*.zip > checksums.txt
sha256sum KernelSU-A20s-*.zip >> checksums.txt

# Verify
md5sum -c KernelSU-A20s-*.zip.md5
sha256sum -c KernelSU-A20s-*.zip.sha256
```

3. **Test Flash**
- Flash on test device first
- Verify boot
- Check KernelSU functionality
- Test SUSFS features

### After Flashing

```bash
# Check kernel version
adb shell uname -a

# Verify KernelSU
adb shell su -c "id"

# Check logs
adb shell dmesg | grep -E "ksu|susfs"
```

## Distribution

### File Naming Convention

```
KernelSU-A20s-[DATE]-[VERSION].zip
```

Examples:
- `KernelSU-A20s-20240108-v1.0.zip`
- `KernelSU-A20s-20240108-testing.zip`

### Required Files for Release

1. **Flashable Zip**
   - Main installation file
   - Size: ~25-30MB

2. **Checksums**
   - MD5 checksum file
   - SHA256 checksum file

3. **Documentation**
   - Installation instructions
   - Changelog
   - Known issues

4. **Source Code**
   - Link to GitHub repository
   - Specific commit/tag

### Release Package Structure

```
Release/
├── KernelSU-A20s-20240108.zip
├── KernelSU-A20s-20240108.zip.md5
├── KernelSU-A20s-20240108.zip.sha256
├── INSTALLATION.txt
├── CHANGELOG.txt
└── README.txt
```

## Upload Locations

### GitHub Releases

1. Create release tag
2. Upload flashable zip
3. Upload checksums
4. Add release notes

```bash
# Create tag
git tag -a v1.0-testing -m "Testing build with KernelSU & SUSFS"
git push origin v1.0-testing

# Use GitHub web interface to create release
```

### Alternative Hosting

- **SourceForge:** For large files
- **AndroidFileHost:** Android-specific hosting
- **Google Drive:** Easy sharing
- **MEGA:** Encrypted storage

## Installation Instructions Template

Create `INSTALLATION.txt`:

```
Samsung Galaxy A20s - KernelSU Kernel Installation

PREREQUISITES:
- Unlocked bootloader
- Custom recovery (TWRP recommended)
- Backup of current boot partition

INSTALLATION STEPS:
1. Download KernelSU-A20s-YYYYMMDD.zip
2. Verify checksum (optional but recommended)
3. Copy zip to device storage
4. Boot to recovery mode
5. Flash the zip file
6. Wipe cache/dalvik (optional)
7. Reboot system

POST-INSTALLATION:
1. Download KernelSU manager from:
   https://github.com/tiann/KernelSU/releases
2. Install the APK
3. Open app and grant root access
4. Configure SUSFS features as needed

VERIFICATION:
- Check kernel version in Settings > About Phone
- Open KernelSU manager to verify installation
- Test root access with root checker app

TROUBLESHOOTING:
- If device won't boot: Flash stock boot.img
- If KernelSU not working: Reinstall manager app
- For logs: adb shell dmesg | grep ksu

SUPPORT:
- GitHub: https://github.com/riski0/android_kernel_samsung_a20s
- Issues: Report on GitHub Issues page

DISCLAIMER:
Flash at your own risk. Author not responsible for
bricked devices or data loss. Always backup first.
```

## Checksums Generation

### Automated Script

```bash
#!/bin/bash
# generate_checksums.sh

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

echo "Generating checksums for: $FILE"

# MD5
md5sum "$FILE" > "${FILE}.md5"
echo "MD5: $(cat ${FILE}.md5)"

# SHA256
sha256sum "$FILE" > "${FILE}.sha256"
echo "SHA256: $(cat ${FILE}.sha256)"

# SHA1 (optional)
sha1sum "$FILE" > "${FILE}.sha1"
echo "SHA1: $(cat ${FILE}.sha1)"

echo "Checksums saved to:"
echo "  ${FILE}.md5"
echo "  ${FILE}.sha256"
echo "  ${FILE}.sha1"
```

Usage:
```bash
chmod +x generate_checksums.sh
./generate_checksums.sh KernelSU-A20s-20240108.zip
```

## Quality Checklist

Before releasing:

- [ ] Kernel builds without errors
- [ ] Flashable zip created successfully
- [ ] Checksums generated
- [ ] Tested on actual device
- [ ] Device boots successfully
- [ ] KernelSU manager works
- [ ] Root access functional
- [ ] SUSFS features operational
- [ ] No kernel panics in logs
- [ ] Documentation complete
- [ ] Source code committed
- [ ] Release notes written

## Troubleshooting

### Zip Creation Fails

```bash
# Check zip utility
which zip

# Install if missing
sudo apt install zip

# Try manual creation
cd AnyKernel3
zip -r9 ../test.zip *
```

### Boot Image Creation Fails

```bash
# Check mkbootimg
pip3 show mkbootimg

# Reinstall if needed
pip3 install --upgrade mkbootimg

# Check Python version
python3 --version  # Should be 3.6+
```

### Large File Size

```bash
# Check kernel image size
ls -lh out/arch/arm64/boot/Image

# If too large, check config
grep CONFIG_DEBUG out/.config

# Disable debug symbols for smaller size
# (Not recommended for testing builds)
```

## Advanced Options

### Custom Ramdisk Modifications

Edit `anykernel.sh` to add custom ramdisk changes:

```bash
# begin ramdisk changes

# Add custom init script
insert_line init.rc "import /init.kernelsu.rc" after "import /init.environ.rc" "import /init.kernelsu.rc";

# Modify properties
replace_string fstab.qcom "ro.debuggable=0" "ro.debuggable=1" "ro.debuggable=1";

# end ramdisk changes
```

### Multiple Variants

Create different builds:

```bash
# Standard build
./build_kernel_improved.sh
./create_flashable_zip.sh
mv KernelSU-A20s-*.zip KernelSU-A20s-standard-*.zip

# Performance build
# Modify defconfig for performance
./build_kernel_improved.sh
./create_flashable_zip.sh
mv KernelSU-A20s-*.zip KernelSU-A20s-performance-*.zip
```

## References

- [AnyKernel3 Documentation](https://github.com/osm0sis/AnyKernel3)
- [Android Boot Image Format](https://source.android.com/docs/core/architecture/bootloader/boot-image-header)
- [mkbootimg Documentation](https://android.googlesource.com/platform/system/tools/mkbootimg/)

---

**Last Updated:** 2024-01-08  
**Version:** 1.0
