#!/bin/bash
# Samsung Galaxy A20s Kernel Build Script
# KernelSU + SUSFS | Host gcc/ld (safe) + Target clang/lld

set -e
set -o pipefail

# =========================
# Paths
# =========================
KERNEL_DIR=$(pwd)
OUT_DIR=$KERNEL_DIR/out
TC_DIR=$KERNEL_DIR/toolchain

CLANG_PATH=$TC_DIR/clang/bin
GCC_PATH=$TC_DIR/gcc/bin

# =========================
# Sanity check
# =========================
if [ ! -d "$TC_DIR" ]; then
    echo "[✗] Toolchain directory not found: $TC_DIR"
    exit 1
fi

# =========================
# PATH (host first!)
# =========================
export PATH="/usr/bin:/bin:$CLANG_PATH:$GCC_PATH"

# =========================
# Host tools (x86_64)
# =========================
export HOSTCC=/usr/bin/gcc
export HOSTLD=/usr/bin/ld
export HOSTAR=/usr/bin/ar
export HOSTNM=/usr/bin/nm

# =========================
# Target tools (ARM64 kernel)
# =========================
export CC=clang
export LD=ld.lld
export AR=llvm-ar
export NM=llvm-nm
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export STRIP=llvm-strip

# =========================
# Arch & toolchain
# =========================
export ARCH=arm64
export CROSS_COMPILE=aarch64-elf-
export CROSS_COMPILE_ARM32=arm-eabi-
export LLVM=1
export LLVM_IAS=1

# =========================
# Defconfig
# =========================
DEFCONFIG=a20s_eur_open_defconfig

# =========================
# Build steps
# =========================
echo "[*] Cleaning..."
make O=$OUT_DIR mrproper

echo "[*] Defconfig..."
make O=$OUT_DIR $DEFCONFIG

echo "[*] Building kernel..."
make -j$(nproc) O=$OUT_DIR

echo "[✓] Build finished"

