# Download Flashable ZIP - Samsung Galaxy A20s KernelSU Kernel

## 📦 Cara Mendapatkan File Flashable ZIP

Karena file kernel image berukuran besar (~30MB) dan tidak bisa di-commit ke Git, ada beberapa cara untuk mendapatkan flashable zip:

---

## 🔨 Opsi 1: Build Sendiri (Recommended)

### Keuntungan:
- ✅ Paling aman dan terpercaya
- ✅ Bisa customize sesuai kebutuhan
- ✅ Selalu versi terbaru
- ✅ Belajar proses build kernel

### Langkah-langkah:

#### 1. Clone Repository
```bash
git clone -b testing/enable-kernelsu-manager \
    https://github.com/riski0/android_kernel_samsung_a20s.git
cd android_kernel_samsung_a20s
```

#### 2. Install Dependencies
```bash
sudo apt update
sudo apt install -y build-essential bc bison flex libssl-dev \
    libelf-dev git device-tree-compiler ccache
```

#### 3. Download Toolchains
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

#### 4. Build Kernel
```bash
chmod +x build_kernel_improved.sh create_flashable_zip.sh
./build_kernel_improved.sh
```

**Waktu build:** 30-60 menit (tergantung CPU)

#### 5. Create Flashable ZIP
```bash
./create_flashable_zip.sh
```

**Output:**
```
KernelSU-A20s-YYYYMMDD-HHMM.zip (~30MB)
KernelSU-A20s-YYYYMMDD-HHMM.zip.md5
KernelSU-A20s-YYYYMMDD-HHMM.zip.sha256
```

---

## 📥 Opsi 2: Download dari GitHub Releases

### Status: ⏳ Belum Tersedia

Pre-built images akan tersedia setelah testing selesai.

**Cara check:**
1. Kunjungi: https://github.com/riski0/android_kernel_samsung_a20s/releases
2. Cari release dengan tag `testing-*` atau `v1.0-*`
3. Download file `KernelSU-A20s-*.zip`

**Verifikasi checksum:**
```bash
# MD5
md5sum -c KernelSU-A20s-*.zip.md5

# SHA256
sha256sum -c KernelSU-A20s-*.zip.sha256
```

---

## 🌐 Opsi 3: Download dari File Hosting

### Status: ⏳ Belum Tersedia

Setelah testing selesai, file akan di-upload ke:

### Hosting Options:

#### A. SourceForge
- **Link:** TBD
- **Kecepatan:** Fast
- **Limit:** Unlimited

#### B. AndroidFileHost
- **Link:** TBD
- **Kecepatan:** Fast
- **Limit:** Unlimited

#### C. Google Drive
- **Link:** TBD
- **Kecepatan:** Fast
- **Limit:** Unlimited

#### D. MEGA
- **Link:** TBD
- **Kecepatan:** Fast
- **Limit:** 5GB/day (free)

---

## 🔍 Cara Verifikasi File ZIP

### 1. Check File Size
```bash
ls -lh KernelSU-A20s-*.zip
# Expected: ~25-35MB
```

### 2. Verify Checksums
```bash
# Generate checksums
md5sum KernelSU-A20s-*.zip
sha256sum KernelSU-A20s-*.zip

# Compare with provided checksums
md5sum -c KernelSU-A20s-*.zip.md5
sha256sum -c KernelSU-A20s-*.zip.sha256
```

### 3. Check ZIP Contents
```bash
unzip -l KernelSU-A20s-*.zip
```

**Expected contents:**
```
Archive:  KernelSU-A20s-20240108.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
 25000000  2024-01-08 16:00   Image
     1234  2024-01-08 16:00   anykernel.sh
     5678  2024-01-08 16:00   README.md
     ...
```

### 4. Test ZIP Integrity
```bash
unzip -t KernelSU-A20s-*.zip
# Should show: "No errors detected"
```

---

## 📋 Informasi File ZIP

### Struktur File:
```
KernelSU-A20s-YYYYMMDD-HHMM.zip
├── Image                    # Kernel image (~25MB)
├── dtb.img                  # Device tree blob (optional)
├── dtbo.img                 # Device tree overlay (optional)
├── anykernel.sh             # Installation script
├── tools/
│   ├── ak3-core.sh          # AnyKernel3 core
│   └── busybox              # Busybox binary
├── README.md                # Installation guide
└── CHANGELOG.md             # Version changelog
```

### Metadata:
- **Format:** ZIP (AnyKernel3)
- **Size:** ~25-35MB
- **Compression:** Maximum (level 9)
- **Compatible:** TWRP, OrangeFox, other custom recoveries

---

## 🚀 Cara Flash ZIP

### Method 1: TWRP Recovery (Recommended)

1. **Copy ZIP to device:**
```bash
adb push KernelSU-A20s-*.zip /sdcard/
```

2. **Boot to TWRP:**
- Power off device
- Hold Volume Up + Power
- Select "Install"

3. **Flash ZIP:**
- Navigate to `/sdcard/`
- Select `KernelSU-A20s-*.zip`
- Swipe to confirm flash
- Reboot system

### Method 2: Fastboot (Advanced)

1. **Extract boot.img from ZIP:**
```bash
unzip KernelSU-A20s-*.zip Image
# Create boot.img using mkbootimg (see PACKAGING_GUIDE.md)
```

2. **Flash via fastboot:**
```bash
adb reboot bootloader
fastboot flash boot boot.img
fastboot reboot
```

### Method 3: KernelSU Manager (If already rooted)

1. Copy ZIP to device
2. Open KernelSU Manager
3. Select "Install from ZIP"
4. Choose the ZIP file
5. Reboot

---

## ✅ Post-Installation

### 1. Verify Kernel
```bash
# Check kernel version
adb shell uname -a
# Should show: Linux version 4.9.x with KernelSU
```

### 2. Install KernelSU Manager
- Download: https://github.com/tiann/KernelSU/releases/latest
- Install APK
- Open app
- Grant root access

### 3. Check Logs
```bash
# KernelSU logs
adb shell su -c "dmesg | grep ksu"

# SUSFS logs
adb shell su -c "dmesg | grep susfs"
```

### 4. Test Root
```bash
# Test root access
adb shell su -c "id"
# Should show: uid=0(root) gid=0(root)
```

---

## 🔗 Alternative Download Methods

### Build Server (Coming Soon)

Automated build server akan menyediakan:
- ✅ Nightly builds
- ✅ Automatic checksums
- ✅ Multiple mirrors
- ✅ Build logs

**Status:** Planning phase

### CI/CD Pipeline (Future)

GitHub Actions akan build otomatis:
- ✅ On every commit
- ✅ Automatic releases
- ✅ Multiple variants
- ✅ Test reports

**Status:** To be implemented

---

## 📊 Build Information

### Build Requirements:
- **CPU:** 2+ cores (4+ recommended)
- **RAM:** 8GB minimum (16GB recommended)
- **Disk:** 10GB free space
- **OS:** Linux (Ubuntu 20.04+ recommended)
- **Time:** 30-60 minutes

### Build Output:
```
out/arch/arm64/boot/
├── Image              # Main kernel (~25MB)
├── dtb.img            # Device tree
└── dtbo.img           # Device tree overlay

Final ZIP:
KernelSU-A20s-YYYYMMDD-HHMM.zip (~30MB)
```

---

## 🆘 Troubleshooting

### "File not found" Error
**Solution:** Build kernel first using `./build_kernel_improved.sh`

### "Checksum mismatch" Error
**Solution:** Re-download file, may be corrupted

### "ZIP is corrupted" Error
**Solution:** 
```bash
# Test ZIP
unzip -t KernelSU-A20s-*.zip

# If corrupted, re-download or rebuild
```

### "Device won't boot" Error
**Solution:**
1. Boot to recovery
2. Flash stock boot.img
3. Reboot
4. Try again with verified ZIP

---

## 📞 Support

### Need Help?

1. **Check Documentation:**
   - [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)
   - [PACKAGING_GUIDE.md](PACKAGING_GUIDE.md)
   - [RELEASE_NOTES.md](RELEASE_NOTES.md)

2. **GitHub Issues:**
   - https://github.com/riski0/android_kernel_samsung_a20s/issues

3. **Community:**
   - Telegram: https://t.me/KernelSU
   - XDA: Coming soon

### Report Issues:
Include:
- Device model
- Current ROM
- Build date
- Error logs
- Steps to reproduce

---

## 📝 Changelog

### Current Build (2024-01-08)
- ✅ KernelSU with debug mode
- ✅ SUSFS v1.5.5 fully enabled
- ✅ Magic mount support
- ✅ SU binary hiding
- ✅ All spoofing features

### Future Updates:
- [ ] Pre-built images
- [ ] Multiple variants
- [ ] Automated builds
- [ ] Performance optimizations

---

## ⚠️ Important Notes

### This is a Testing Build:
- Debug mode enabled
- Not for production use
- May have bugs
- Performance may vary

### Before Flashing:
- ✅ Backup current boot.img
- ✅ Backup important data
- ✅ Charge battery >50%
- ✅ Verify ZIP integrity

### After Flashing:
- ✅ Test basic functionality
- ✅ Check for errors
- ✅ Report issues
- ✅ Provide feedback

---

## 📜 License

- **Kernel:** GPL v2
- **KernelSU:** GPL v3
- **Documentation:** CC BY-SA 4.0

---

## 🔄 Updates

Check for updates:
```bash
cd android_kernel_samsung_a20s
git pull origin testing/enable-kernelsu-manager
```

Or visit: https://github.com/riski0/android_kernel_samsung_a20s/commits/testing/enable-kernelsu-manager

---

**Repository:** https://github.com/riski0/android_kernel_samsung_a20s  
**Branch:** testing/enable-kernelsu-manager  
**Status:** Build from source required  
**Last Updated:** 2024-01-08

---

## 🎯 Quick Links

- **Source Code:** https://github.com/riski0/android_kernel_samsung_a20s
- **Build Guide:** [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)
- **KernelSU Manager:** https://github.com/tiann/KernelSU/releases
- **Support:** https://t.me/KernelSU

---

**Note:** Pre-built ZIP files akan tersedia setelah testing selesai. Untuk saat ini, silakan build dari source menggunakan panduan di atas.

**Happy Building! 🚀**
