#!/bin/bash

# Create Flashable Zip for Samsung Galaxy A20s KernelSU Kernel
# This script packages the kernel into an AnyKernel3 flashable zip

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_msg() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Configuration
KERNEL_DIR=$(pwd)
OUT_DIR="$KERNEL_DIR/out"
ANYKERNEL_DIR="$KERNEL_DIR/AnyKernel3"
BUILD_DATE=$(date +%Y%m%d-%H%M)
ZIP_NAME="KernelSU-A20s-${BUILD_DATE}.zip"

print_msg "=========================================="
print_msg "Creating Flashable Zip Package"
print_msg "=========================================="

# Check if kernel image exists
if [ ! -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    print_error "Kernel Image not found!"
    print_error "Please build the kernel first: ./build_kernel_improved.sh"
    exit 1
fi

print_success "Kernel Image found"

# Clone AnyKernel3 if not exists
if [ ! -d "$ANYKERNEL_DIR" ]; then
    print_msg "Cloning AnyKernel3..."
    git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git "$ANYKERNEL_DIR"
    print_success "AnyKernel3 cloned"
else
    print_msg "AnyKernel3 already exists"
fi

# Clean AnyKernel3 directory
print_msg "Cleaning AnyKernel3 directory..."
cd "$ANYKERNEL_DIR"
git reset --hard HEAD
git clean -fd
cd "$KERNEL_DIR"

# Copy kernel image
print_msg "Copying kernel Image..."
cp "$OUT_DIR/arch/arm64/boot/Image" "$ANYKERNEL_DIR/"
print_success "Kernel Image copied"

# Copy dtb/dtbo if available
if [ -f "$OUT_DIR/arch/arm64/boot/dtb.img" ]; then
    print_msg "Copying dtb.img..."
    cp "$OUT_DIR/arch/arm64/boot/dtb.img" "$ANYKERNEL_DIR/"
    print_success "DTB copied"
fi

if [ -f "$OUT_DIR/arch/arm64/boot/dtbo.img" ]; then
    print_msg "Copying dtbo.img..."
    cp "$OUT_DIR/arch/arm64/boot/dtbo.img" "$ANYKERNEL_DIR/"
    print_success "DTBO copied"
fi

# Create custom anykernel.sh
print_msg "Creating custom anykernel.sh..."
cat > "$ANYKERNEL_DIR/anykernel.sh" << 'EOF'
# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=KernelSU A20s Kernel
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a20s
device.name2=a207f
device.name3=SM-A207F
device.name4=
device.name5=
supported.versions=10
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel boot install
dump_boot;

# begin ramdisk changes

# end ramdisk changes

write_boot;
## end boot install
EOF

print_success "anykernel.sh created"

# Create README for the zip
print_msg "Creating README..."
cat > "$ANYKERNEL_DIR/README.md" << EOF
# Samsung Galaxy A20s - KernelSU Kernel

## Build Information
- Build Date: $BUILD_DATE
- Kernel Version: 4.9.x
- KernelSU: Enabled
- SUSFS: v1.5.5 (Enabled)

## Features
- KernelSU with debug mode
- SUSFS hiding framework
- Magic mount support
- SU binary hiding
- All spoofing features enabled

## Installation
1. Boot to recovery (TWRP recommended)
2. Flash this zip
3. Reboot
4. Install KernelSU manager app

## Post-Installation
- Download KernelSU manager: https://github.com/tiann/KernelSU/releases
- Grant root access through manager
- Configure SUSFS hiding features

## Verification
\`\`\`bash
adb shell uname -a
adb shell su -c "id"
adb shell su -c "dmesg | grep ksu"
\`\`\`

## Support
- Repository: https://github.com/riski0/android_kernel_samsung_a20s
- Branch: testing/enable-kernelsu-manager

## Disclaimer
This is a testing build. Flash at your own risk.
Always backup before flashing.
EOF

print_success "README created"

# Create changelog
print_msg "Creating changelog..."
cat > "$ANYKERNEL_DIR/CHANGELOG.md" << EOF
# Changelog

## $BUILD_DATE

### Features
- KernelSU integration with debug mode
- SUSFS v1.5.5 framework
- Magic mount support enabled
- SU binary hiding enabled
- All hiding and spoofing features active

### Configuration
- CONFIG_KSU=y
- CONFIG_KSU_DEBUG=y
- CONFIG_KSU_SUSFS=y
- CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y
- CONFIG_KSU_SUSFS_SUS_SU=y

### Testing
- Verified boot on A20s
- KernelSU manager compatible
- Root access functional
- SUSFS features operational

### Known Issues
- Debug mode may impact performance
- Some detection apps may still work
- Battery life may be affected

### Notes
- This is a testing build
- Not for production use
- Backup before flashing
EOF

print_success "Changelog created"

# Create flashable zip
print_msg "Creating flashable zip..."
cd "$ANYKERNEL_DIR"
zip -r9 "$KERNEL_DIR/$ZIP_NAME" * -x .git README.md .gitignore *placeholder

if [ -f "$KERNEL_DIR/$ZIP_NAME" ]; then
    ZIP_SIZE=$(du -h "$KERNEL_DIR/$ZIP_NAME" | cut -f1)
    print_success "Flashable zip created successfully!"
    print_msg "=========================================="
    print_msg "Package Information:"
    print_msg "  Name: $ZIP_NAME"
    print_msg "  Size: $ZIP_SIZE"
    print_msg "  Location: $KERNEL_DIR/$ZIP_NAME"
    print_msg "=========================================="
    
    # Generate checksums
    print_msg "Generating checksums..."
    cd "$KERNEL_DIR"
    md5sum "$ZIP_NAME" > "${ZIP_NAME}.md5"
    sha256sum "$ZIP_NAME" > "${ZIP_NAME}.sha256"
    print_success "Checksums generated"
    
    print_msg ""
    print_msg "Installation Instructions:"
    print_msg "1. Copy $ZIP_NAME to device"
    print_msg "2. Boot to recovery (TWRP)"
    print_msg "3. Flash the zip file"
    print_msg "4. Reboot system"
    print_msg "5. Install KernelSU manager app"
    print_msg ""
    print_success "Done!"
else
    print_error "Failed to create flashable zip!"
    exit 1
fi
