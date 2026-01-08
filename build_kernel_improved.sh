#!/bin/bash

# Samsung Galaxy A20s Kernel Build Script
# With KernelSU & SUSFS Support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Configuration
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=q

# Paths
KERNEL_DIR=$(pwd)
OUT_DIR="$KERNEL_DIR/out"
TOOLCHAIN_DIR="$KERNEL_DIR/toolchain"
BUILD_DATE=$(date +%Y%m%d-%H%M)

# Defconfig
DEFCONFIG=a20s_eur_open_defconfig

# Check if toolchain exists
if [ ! -d "$TOOLCHAIN_DIR" ]; then
    print_error "Toolchain directory not found!"
    print_msg "Please download toolchains first. See BUILD_INSTRUCTIONS.md"
    print_msg ""
    print_msg "Quick setup:"
    print_msg "  mkdir -p toolchain && cd toolchain"
    print_msg "  git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang"
    print_msg "  git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc"
    exit 1
fi

# Detect toolchain structure
if [ -d "$TOOLCHAIN_DIR/clang/bin" ]; then
    CLANG_DIR="$TOOLCHAIN_DIR/clang/bin"
elif [ -d "$TOOLCHAIN_DIR/llvm-arm-toolchain-ship/10.0/bin" ]; then
    CLANG_DIR="$TOOLCHAIN_DIR/llvm-arm-toolchain-ship/10.0/bin"
else
    print_error "Clang not found in toolchain directory!"
    exit 1
fi

if [ -d "$TOOLCHAIN_DIR/gcc/bin" ]; then
    GCC_DIR="$TOOLCHAIN_DIR/gcc/bin"
elif [ -d "$TOOLCHAIN_DIR/aarch64-linux-android-4.9/bin" ]; then
    GCC_DIR="$TOOLCHAIN_DIR/aarch64-linux-android-4.9/bin"
elif [ -d "$TOOLCHAIN_DIR/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin" ]; then
    GCC_DIR="$TOOLCHAIN_DIR/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
else
    print_error "GCC not found in toolchain directory!"
    exit 1
fi

# Compiler settings
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$GCC_DIR/aarch64-linux-android-
export CC=$CLANG_DIR/clang
export CLANG_PREBUILT_BIN=$CLANG_DIR

# Build settings
MAKE_OPTS=(
    -j$(nproc --all)
    O="$OUT_DIR"
    ARCH=$ARCH
    SUBARCH=$SUBARCH
    CC=$CC
    CLANG_TRIPLE=$CLANG_TRIPLE
    CROSS_COMPILE=$CROSS_COMPILE
)

# Print build info
print_msg "=========================================="
print_msg "Samsung Galaxy A20s Kernel Build"
print_msg "KernelSU + SUSFS Enabled"
print_msg "=========================================="
print_msg "Build date: $BUILD_DATE"
print_msg "Defconfig: $DEFCONFIG"
print_msg "Clang: $CLANG_DIR"
print_msg "GCC: $GCC_DIR"
print_msg "Threads: $(nproc --all)"
print_msg "=========================================="

# Create output directory
mkdir -p "$OUT_DIR"

# Clean if requested
if [ "$1" == "clean" ]; then
    print_msg "Cleaning previous build..."
    make "${MAKE_OPTS[@]}" clean
    make "${MAKE_OPTS[@]}" mrproper
    print_success "Clean complete"
fi

# Configure kernel
print_msg "Configuring kernel with $DEFCONFIG..."
make "${MAKE_OPTS[@]}" $DEFCONFIG

# Verify KernelSU config
print_msg "Verifying KernelSU configuration..."
if grep -q "CONFIG_KSU=y" "$OUT_DIR/.config"; then
    print_success "KernelSU enabled"
else
    print_error "KernelSU not enabled!"
    exit 1
fi

if grep -q "CONFIG_KSU_SUSFS=y" "$OUT_DIR/.config"; then
    print_success "SUSFS enabled"
else
    print_warning "SUSFS not enabled"
fi

if grep -q "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" "$OUT_DIR/.config"; then
    print_success "Magic mount enabled"
else
    print_warning "Magic mount not enabled"
fi

# Build kernel
print_msg "Building kernel..."
START_TIME=$(date +%s)

if make "${MAKE_OPTS[@]}"; then
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    
    print_success "Kernel build successful! (${BUILD_TIME}s)"
    
    # Check output files
    if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
        IMAGE_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/Image" | cut -f1)
        print_success "Kernel Image: $IMAGE_SIZE"
        
        # Copy to boot directory
        cp "$OUT_DIR/arch/arm64/boot/Image" "$KERNEL_DIR/arch/arm64/boot/Image"
        
        # Check for dtb/dtbo
        if [ -f "$OUT_DIR/arch/arm64/boot/dtb.img" ]; then
            DTB_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/dtb.img" | cut -f1)
            print_success "DTB Image: $DTB_SIZE"
            cp "$OUT_DIR/arch/arm64/boot/dtb.img" "$KERNEL_DIR/arch/arm64/boot/dtb.img"
        fi
        
        if [ -f "$OUT_DIR/arch/arm64/boot/dtbo.img" ]; then
            DTBO_SIZE=$(du -h "$OUT_DIR/arch/arm64/boot/dtbo.img" | cut -f1)
            print_success "DTBO Image: $DTBO_SIZE"
            cp "$OUT_DIR/arch/arm64/boot/dtbo.img" "$KERNEL_DIR/arch/arm64/boot/dtbo.img"
        fi
        
        # Create build info
        BUILD_INFO="$OUT_DIR/build_info.txt"
        cat > "$BUILD_INFO" << EOF
Samsung Galaxy A20s Kernel Build Information
============================================

Build Date: $BUILD_DATE
Kernel Version: $(strings "$OUT_DIR/arch/arm64/boot/Image" | grep "Linux version" | head -1)
Defconfig: $DEFCONFIG
Build Time: ${BUILD_TIME}s

Features:
- KernelSU: Enabled
- SUSFS: Enabled
- Magic Mount: Enabled
- SU Binary Hiding: Enabled
- Debug Mode: Enabled

Output Files:
- Kernel Image: $OUT_DIR/arch/arm64/boot/Image ($IMAGE_SIZE)
- vmlinux: $OUT_DIR/vmlinux
- System.map: $OUT_DIR/System.map

Configuration:
$(grep "CONFIG_KSU" "$OUT_DIR/.config")
EOF
        
        print_success "Build info saved to: $BUILD_INFO"
        
        print_msg "=========================================="
        print_msg "Build artifacts location:"
        print_msg "  $OUT_DIR/arch/arm64/boot/Image"
        print_msg "=========================================="
        
    else
        print_error "Kernel Image not found!"
        exit 1
    fi
else
    print_error "Kernel build failed!"
    exit 1
fi
