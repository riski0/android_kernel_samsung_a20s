#!/bin/bash

# Build Verification Script
# Verifies kernel build artifacts and configuration

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

KERNEL_DIR=$(pwd)
OUT_DIR="$KERNEL_DIR/out"
ERRORS=0
WARNINGS=0

print_msg "=========================================="
print_msg "Kernel Build Verification"
print_msg "=========================================="

# Check output directory
if [ ! -d "$OUT_DIR" ]; then
    print_error "Output directory not found: $OUT_DIR"
    print_error "Please build the kernel first"
    exit 1
fi

print_success "Output directory exists"

# Check kernel Image
print_msg "Checking kernel Image..."
if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    IMAGE_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/Image" | cut -f1)
    IMAGE_BYTES=$(stat -f%z "$OUT_DIR/arch/arm64/boot/Image" 2>/dev/null || stat -c%s "$OUT_DIR/arch/arm64/boot/Image")
    print_success "Kernel Image found ($IMAGE_SIZE)"
    
    # Check if size is reasonable (should be 20-40MB)
    if [ $IMAGE_BYTES -lt 10000000 ]; then
        print_warning "Image size seems too small"
        ((WARNINGS++))
    elif [ $IMAGE_BYTES -gt 50000000 ]; then
        print_warning "Image size seems too large"
        ((WARNINGS++))
    fi
else
    print_error "Kernel Image not found"
    ((ERRORS++))
fi

# Check vmlinux
print_msg "Checking vmlinux..."
if [ -f "$OUT_DIR/vmlinux" ]; then
    VMLINUX_SIZE=$(du -h "$OUT_DIR/vmlinux" | cut -f1)
    print_success "vmlinux found ($VMLINUX_SIZE)"
else
    print_warning "vmlinux not found"
    ((WARNINGS++))
fi

# Check System.map
print_msg "Checking System.map..."
if [ -f "$OUT_DIR/System.map" ]; then
    print_success "System.map found"
else
    print_warning "System.map not found"
    ((WARNINGS++))
fi

# Check .config
print_msg "Checking kernel configuration..."
if [ -f "$OUT_DIR/.config" ]; then
    print_success "Kernel .config found"
    
    # Verify KernelSU configuration
    print_msg "Verifying KernelSU configuration..."
    
    if grep -q "CONFIG_KSU=y" "$OUT_DIR/.config"; then
        print_success "CONFIG_KSU=y"
    else
        print_error "CONFIG_KSU not enabled"
        ((ERRORS++))
    fi
    
    if grep -q "CONFIG_KSU_DEBUG=y" "$OUT_DIR/.config"; then
        print_success "CONFIG_KSU_DEBUG=y"
    else
        print_warning "CONFIG_KSU_DEBUG not enabled"
        ((WARNINGS++))
    fi
    
    if grep -q "CONFIG_KSU_SUSFS=y" "$OUT_DIR/.config"; then
        print_success "CONFIG_KSU_SUSFS=y"
    else
        print_error "CONFIG_KSU_SUSFS not enabled"
        ((ERRORS++))
    fi
    
    if grep -q "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" "$OUT_DIR/.config"; then
        print_success "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
    else
        print_error "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT not enabled"
        ((ERRORS++))
    fi
    
    if grep -q "CONFIG_KSU_SUSFS_SUS_SU=y" "$OUT_DIR/.config"; then
        print_success "CONFIG_KSU_SUSFS_SUS_SU=y"
    else
        print_error "CONFIG_KSU_SUSFS_SUS_SU not enabled"
        ((ERRORS++))
    fi
else
    print_error "Kernel .config not found"
    ((ERRORS++))
fi

# Check DTB/DTBO
print_msg "Checking device tree files..."
if [ -f "$OUT_DIR/arch/arm64/boot/dtb.img" ]; then
    DTB_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/dtb.img" | cut -f1)
    print_success "dtb.img found ($DTB_SIZE)"
else
    print_warning "dtb.img not found (may be normal)"
fi

if [ -f "$OUT_DIR/arch/arm64/boot/dtbo.img" ]; then
    DTBO_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/dtbo.img" | cut -f1)
    print_success "dtbo.img found ($DTBO_SIZE)"
else
    print_warning "dtbo.img not found (may be normal)"
fi

# Check kernel version
print_msg "Checking kernel version..."
if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    KERNEL_VERSION=$(strings "$OUT_DIR/arch/arm64/boot/Image" | grep "Linux version" | head -1)
    if [ -n "$KERNEL_VERSION" ]; then
        print_success "Kernel version: $KERNEL_VERSION"
    else
        print_warning "Could not extract kernel version"
        ((WARNINGS++))
    fi
fi

# Check for KernelSU symbols
print_msg "Checking for KernelSU symbols..."
if [ -f "$OUT_DIR/vmlinux" ]; then
    if strings "$OUT_DIR/vmlinux" | grep -q "kernelsu\|ksu_"; then
        print_success "KernelSU symbols found"
    else
        print_error "KernelSU symbols not found"
        ((ERRORS++))
    fi
    
    if strings "$OUT_DIR/vmlinux" | grep -q "susfs"; then
        print_success "SUSFS symbols found"
    else
        print_error "SUSFS symbols not found"
        ((ERRORS++))
    fi
fi

# Generate build info
print_msg "Generating build information..."
BUILD_INFO="$OUT_DIR/BUILD_INFO.txt"
cat > "$BUILD_INFO" << EOF
Samsung Galaxy A20s Kernel Build Information
============================================

Build Date: $(date)
Build Host: $(hostname)
Build User: $(whoami)

Kernel Information:
-------------------
Version: $(strings "$OUT_DIR/arch/arm64/boot/Image" 2>/dev/null | grep "Linux version" | head -1 || echo "Unknown")
Architecture: ARM64
Defconfig: a20s_eur_open_defconfig

Build Artifacts:
----------------
Kernel Image: $([ -f "$OUT_DIR/arch/arm64/boot/Image" ] && echo "✓ ($IMAGE_SIZE)" || echo "✗ Missing")
vmlinux: $([ -f "$OUT_DIR/vmlinux" ] && echo "✓ ($VMLINUX_SIZE)" || echo "✗ Missing")
System.map: $([ -f "$OUT_DIR/System.map" ] && echo "✓" || echo "✗ Missing")
dtb.img: $([ -f "$OUT_DIR/arch/arm64/boot/dtb.img" ] && echo "✓" || echo "✗ Missing")
dtbo.img: $([ -f "$OUT_DIR/arch/arm64/boot/dtbo.img" ] && echo "✓" || echo "✗ Missing")

KernelSU Configuration:
-----------------------
$(grep "CONFIG_KSU" "$OUT_DIR/.config" 2>/dev/null || echo "Configuration not found")

Verification Results:
---------------------
Errors: $ERRORS
Warnings: $WARNINGS
Status: $([ $ERRORS -eq 0 ] && echo "PASS" || echo "FAIL")

Build Output Location:
----------------------
$OUT_DIR

Next Steps:
-----------
1. Create flashable zip: ./create_flashable_zip.sh
2. Test on device
3. Report any issues

EOF

print_success "Build info saved to: $BUILD_INFO"

# Summary
print_msg "=========================================="
print_msg "Verification Summary"
print_msg "=========================================="
print_msg "Errors: $ERRORS"
print_msg "Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    print_success "Build verification PASSED"
    print_msg ""
    print_msg "Next steps:"
    print_msg "  1. Create flashable zip: ./create_flashable_zip.sh"
    print_msg "  2. Flash on device"
    print_msg "  3. Install KernelSU manager"
    print_msg "  4. Test functionality"
    exit 0
else
    print_error "Build verification FAILED"
    print_msg ""
    print_msg "Please fix the errors and rebuild"
    exit 1
fi
