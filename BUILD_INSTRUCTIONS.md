# Build Instructions - Samsung Galaxy A20s Kernel with KernelSU & SUSFS

## Prerequisites

### Required Tools
- Linux build environment (Ubuntu 20.04+ recommended)
- Git
- Python 3
- Build essentials

### Install Dependencies

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y \
    build-essential \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    git \
    wget \
    curl \
    zip \
    unzip \
    python3 \
    python3-pip \
    device-tree-compiler

# Install additional tools
sudo apt install -y \
    ccache \
    lz4 \
    liblz4-tool \
    android-sdk-libsparse-utils
```

### Download Toolchains

#### Option 1: Google Prebuilt Toolchains (Recommended)

```bash
# Create toolchain directory
mkdir -p toolchain
cd toolchain

# Download GCC toolchain
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9

# Download Clang toolchain
git clone --depth=1 -b master https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone.git clang

cd ..
```

#### Option 2: Proton Clang (Alternative)

```bash
mkdir -p toolchain
cd toolchain

# Download Proton Clang
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang

# Download GCC toolchain
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc

cd ..
```

## Build Configuration

### 1. Clone Kernel Source

```bash
git clone https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
git checkout testing/enable-kernelsu-manager
```

### 2. Configure Build Environment

Create or update `build_kernel.sh`:

```bash
#!/bin/bash

# Exit on error
set -e

# Configuration
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=q

# Paths
KERNEL_DIR=$(pwd)
OUT_DIR="$KERNEL_DIR/out"
TOOLCHAIN_DIR="$KERNEL_DIR/toolchain"

# Toolchain paths
CLANG_DIR="$TOOLCHAIN_DIR/clang/bin"
GCC_DIR="$TOOLCHAIN_DIR/aarch64-linux-android-4.9/bin"

# Compiler settings
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$GCC_DIR/aarch64-linux-android-
export CC=$CLANG_DIR/clang
export CLANG_PREBUILT_BIN=$CLANG_DIR

# Build settings
DEFCONFIG=a20s_eur_open_defconfig
MAKE_OPTS=(
    -j$(nproc --all)
    O="$OUT_DIR"
    ARCH=$ARCH
    SUBARCH=$SUBARCH
    CC=$CC
    CLANG_TRIPLE=$CLANG_TRIPLE
    CROSS_COMPILE=$CROSS_COMPILE
)

# Create output directory
mkdir -p "$OUT_DIR"

# Clean previous build (optional)
# make "${MAKE_OPTS[@]}" clean
# make "${MAKE_OPTS[@]}" mrproper

# Configure kernel
echo "Configuring kernel with $DEFCONFIG..."
make "${MAKE_OPTS[@]}" $DEFCONFIG

# Build kernel
echo "Building kernel..."
make "${MAKE_OPTS[@]}"

# Check if build succeeded
if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    echo "✓ Kernel build successful!"
    echo "  Image: $OUT_DIR/arch/arm64/boot/Image"
    
    # Copy to boot directory
    cp "$OUT_DIR/arch/arm64/boot/Image" "$KERNEL_DIR/arch/arm64/boot/Image"
    
    # Check for dtb/dtbo
    if [ -f "$OUT_DIR/arch/arm64/boot/dtb.img" ]; then
        echo "  DTB: $OUT_DIR/arch/arm64/boot/dtb.img"
        cp "$OUT_DIR/arch/arm64/boot/dtb.img" "$KERNEL_DIR/arch/arm64/boot/dtb.img"
    fi
    
    if [ -f "$OUT_DIR/arch/arm64/boot/dtbo.img" ]; then
        echo "  DTBO: $OUT_DIR/arch/arm64/boot/dtbo.img"
        cp "$OUT_DIR/arch/arm64/boot/dtbo.img" "$KERNEL_DIR/arch/arm64/boot/dtbo.img"
    fi
else
    echo "✗ Kernel build failed!"
    exit 1
fi
```

### 3. Make Script Executable

```bash
chmod +x build_kernel.sh
```

## Building the Kernel

### Standard Build

```bash
./build_kernel.sh
```

### Build with Verbose Output

```bash
./build_kernel.sh V=1
```

### Clean Build

```bash
make O=out clean
make O=out mrproper
./build_kernel.sh
```

## Creating Flashable Images

### Using AnyKernel3

```bash
# Clone AnyKernel3
git clone https://github.com/osm0sis/AnyKernel3.git
cd AnyKernel3

# Copy kernel image
cp ../out/arch/arm64/boot/Image ./

# Copy dtb/dtbo if available
cp ../out/arch/arm64/boot/dtb.img ./ 2>/dev/null || true
cp ../out/arch/arm64/boot/dtbo.img ./ 2>/dev/null || true

# Edit anykernel.sh for your device
# Set device.name1=a20s

# Create flashable zip
zip -r9 KernelSU-A20s-$(date +%Y%m%d).zip * -x .git README.md *placeholder
```

### Manual Boot Image Creation

```bash
# Install mkbootimg
pip3 install mkbootimg

# Extract boot.img from your device first
# adb pull /dev/block/by-name/boot boot.img

# Unpack original boot.img
mkdir boot_unpack
cd boot_unpack
python3 -m mkbootimg --unpack ../boot.img

# Replace kernel
cp ../out/arch/arm64/boot/Image ./kernel

# Repack boot.img
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

## Verification

### Check Kernel Version

```bash
strings out/arch/arm64/boot/Image | grep "Linux version"
```

### Check KernelSU Integration

```bash
# Check for KernelSU symbols
grep -a "kernelsu\|ksu_" out/vmlinux | head -10

# Check SUSFS integration
grep -a "susfs" out/vmlinux | head -10
```

### Verify Configuration

```bash
# Check enabled configs
grep "CONFIG_KSU" out/.config
grep "CONFIG_KSU_SUSFS" out/.config
```

## Expected Output

After successful build, you should have:

```
out/
├── arch/arm64/boot/
│   ├── Image              # Main kernel image
│   ├── Image.gz           # Compressed kernel (if enabled)
│   ├── dtb.img            # Device tree blob (if available)
│   └── dtbo.img           # Device tree overlay (if available)
├── vmlinux                # Uncompressed kernel with symbols
└── System.map             # Kernel symbol table
```

## Troubleshooting

### Build Errors

**Error: "No rule to make target"**
```bash
make O=out clean
make O=out mrproper
./build_kernel.sh
```

**Error: "clang: command not found"**
- Check toolchain paths in build_kernel.sh
- Ensure clang is in PATH or CLANG_DIR is correct

**Error: "scripts/dtc/dtc: not found"**
```bash
make O=out scripts
```

### Runtime Issues

**Device won't boot**
- Verify boot.img was created correctly
- Check if SELinux is permissive
- Review kernel logs: `adb shell dmesg | grep -i error`

**KernelSU not working**
- Verify CONFIG_KSU=y in .config
- Check kernel version matches KernelSU requirements
- Install KernelSU manager app

## Testing Checklist

After flashing:

- [ ] Device boots successfully
- [ ] No bootloop or kernel panic
- [ ] KernelSU manager app installs
- [ ] Root access can be granted
- [ ] SUSFS features work (check logs)
- [ ] System stability (no random reboots)
- [ ] Performance is acceptable

## Additional Resources

- [KernelSU Documentation](https://kernelsu.org/)
- [AnyKernel3 Documentation](https://github.com/osm0sis/AnyKernel3)
- [Android Kernel Build Guide](https://source.android.com/docs/setup/build/building-kernels)

## Support

For issues specific to this kernel:
- Check kernel logs: `adb shell dmesg`
- Check KernelSU logs: `adb shell su -c "dmesg | grep ksu"`
- Check SUSFS logs: `adb shell su -c "dmesg | grep susfs"`
