#!/bin/bash

# Setup KernelSU-Next & susfs4ksu for Samsung Galaxy A20s
# Using NonGKI Kernel Build methodology

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

print_msg "=========================================="
print_msg "KernelSU-Next & susfs4ksu Setup"
print_msg "Samsung Galaxy A20s (Kernel 4.9)"
print_msg "=========================================="

# Check if we're in kernel directory
if [ ! -f "Makefile" ] || [ ! -d "arch/arm64" ]; then
    print_error "Not in kernel source directory!"
    exit 1
fi

print_success "Kernel directory verified"

# Step 1: Setup KernelSU-Next
print_msg "Step 1: Setting up KernelSU-Next..."

if [ ! -d "KernelSU" ]; then
    print_error "KernelSU directory not found!"
    print_msg "Please ensure KernelSU-Next is cloned as 'KernelSU'"
    exit 1
fi

print_success "KernelSU-Next found"

# Step 2: Setup susfs4ksu
print_msg "Step 2: Setting up susfs4ksu..."

if [ ! -d "susfs4ksu" ]; then
    print_error "susfs4ksu directory not found!"
    print_msg "Cloning susfs4ksu..."
    git clone https://gitlab.com/simonpunk/susfs4ksu.git
fi

print_success "susfs4ksu found"

# Step 3: Copy susfs files
print_msg "Step 3: Copying susfs files..."

# Copy susfs source files
cp -f susfs4ksu/kernel_patches/fs/susfs.c fs/
cp -f susfs4ksu/kernel_patches/include/linux/susfs.h include/linux/

print_success "susfs source files copied"

# Step 4: Manual integration for KernelSU-Next
print_msg "Step 4: Integrating susfs with KernelSU-Next..."

# Check if already integrated
if grep -q "CONFIG_KSU_SUSFS" KernelSU/kernel/Kconfig; then
    print_warning "susfs already integrated in Kconfig"
else
    print_msg "Adding susfs to KernelSU Kconfig..."
    
    # Add susfs config to Kconfig
    cat >> KernelSU/kernel/Kconfig << 'EOF'

config KSU_SUSFS
	bool "KernelSU SUSFS support"
	depends on KSU
	default y
	help
	  Enable SUSFS (Super User File System) support for KernelSU.
	  This provides advanced hiding capabilities.

config KSU_SUSFS_SUS_PATH
	bool "SUSFS path hiding"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_SUS_MOUNT
	bool "SUSFS mount hiding"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_SUS_KSTAT
	bool "SUSFS kstat hiding"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_TRY_UMOUNT
	bool "SUSFS try umount"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_SPOOF_UNAME
	bool "SUSFS spoof uname"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_ENABLE_LOG
	bool "SUSFS enable logging"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_OPEN_REDIRECT
	bool "SUSFS open redirect"
	depends on KSU_SUSFS
	default y

config KSU_SUSFS_SUS_SU
	bool "SUSFS hide su binary"
	depends on KSU_SUSFS
	default y
EOF
    
    print_success "susfs config added to Kconfig"
fi

# Step 5: Update Makefile
print_msg "Step 5: Updating Makefile..."

if grep -q "susfs.o" KernelSU/kernel/Makefile; then
    print_warning "susfs already in Makefile"
else
    # Add susfs to Makefile
    echo "obj-\$(CONFIG_KSU_SUSFS) += ../../fs/susfs.o" >> KernelSU/kernel/Makefile
    print_success "susfs added to Makefile"
fi

# Step 6: Apply kernel patch
print_msg "Step 6: Applying kernel patch..."

if [ -f "50_add_susfs_in_kernel-4.9.patch" ]; then
    print_msg "Applying susfs kernel patch..."
    patch -p1 < 50_add_susfs_in_kernel-4.9.patch || {
        print_warning "Some patches failed, may need manual intervention"
        print_msg "Check *.rej files for failed hunks"
    }
else
    print_warning "Kernel patch file not found, copying..."
    cp susfs4ksu/kernel_patches/50_add_susfs_in_kernel-4.9.patch .
    patch -p1 < 50_add_susfs_in_kernel-4.9.patch || {
        print_warning "Some patches failed, may need manual intervention"
    }
fi

# Step 7: Update defconfig
print_msg "Step 7: Updating defconfig..."

DEFCONFIG="arch/arm64/configs/a20s_eur_open_defconfig"

# Add KernelSU-Next configs
if ! grep -q "CONFIG_KSU=y" "$DEFCONFIG"; then
    cat >> "$DEFCONFIG" << 'EOF'

# KernelSU-Next Configuration
CONFIG_KSU=y
CONFIG_KSU_DEBUG=y
EOF
    print_success "KernelSU config added"
fi

# Add susfs configs
if ! grep -q "CONFIG_KSU_SUSFS=y" "$DEFCONFIG"; then
    cat >> "$DEFCONFIG" << 'EOF'

# SUSFS Configuration
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_TRY_UMOUNT=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SUS_SU=y
EOF
    print_success "susfs config added"
fi

# Step 8: Create build info
print_msg "Step 8: Creating build info..."

cat > BUILD_INFO_KERNELSU_NEXT.txt << EOF
Samsung Galaxy A20s - KernelSU-Next & susfs4ksu Build
======================================================

Build Date: $(date)
Kernel Version: 4.9.x
Architecture: ARM64

Components:
-----------
- KernelSU-Next (backslashxx/Magic version)
  Repository: https://github.com/backslashxx/KernelSU
  Version: v3.0.0+
  
- susfs4ksu
  Repository: https://gitlab.com/simonpunk/susfs4ksu
  Version: Latest from master
  
Features:
---------
✓ KernelSU-Next with Magic enhancements
✓ susfs4ksu full integration
✓ Path hiding (SUS_PATH)
✓ Mount hiding (SUS_MOUNT)
✓ Kstat hiding (SUS_KSTAT)
✓ Try umount support
✓ Uname spoofing
✓ Open redirect
✓ SU binary hiding
✓ Debug logging enabled

Build Instructions:
-------------------
1. Run this setup script: ./setup_kernelsu_next_susfs.sh
2. Build kernel: ./build_kernel_improved.sh
3. Create flashable zip: ./create_flashable_zip.sh

Notes:
------
- This is KernelSU-Next (Magic version), not standard KernelSU
- susfs4ksu provides advanced hiding capabilities
- Debug mode is enabled for testing
- Compatible with KernelSU Manager app

Support:
--------
- KernelSU-Next: https://github.com/backslashxx/KernelSU
- susfs4ksu: https://gitlab.com/simonpunk/susfs4ksu
- Telegram: @simonpunk (susfs)

EOF

print_success "Build info created"

# Summary
print_msg "=========================================="
print_msg "Setup Summary"
print_msg "=========================================="
print_success "KernelSU-Next: Configured"
print_success "susfs4ksu: Integrated"
print_success "Defconfig: Updated"
print_success "Build info: Created"

print_msg ""
print_msg "Next steps:"
print_msg "  1. Review any .rej files if patches failed"
print_msg "  2. Run: ./build_kernel_improved.sh"
print_msg "  3. Run: ./create_flashable_zip.sh"
print_msg ""
print_success "Setup complete!"
