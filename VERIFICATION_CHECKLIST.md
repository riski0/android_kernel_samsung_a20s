# KernelSU & SUSFS Integration Verification Checklist

## Pre-Build Verification

### ✅ Repository Structure
- [x] `KernelSU/` directory exists at repository root
- [x] `KernelSU/kernel/Kconfig` contains SUSFS options
- [x] `KernelSU/kernel/Makefile` references susfs.o
- [x] `fs/susfs.c` exists
- [x] `include/linux/susfs.h` exists
- [x] `include/linux/susfs_def.h` exists

### ✅ Build System Configuration
- [x] `drivers/Kconfig` sources `KernelSU/kernel/Kconfig`
- [x] `drivers/Makefile` includes `../KernelSU/kernel/`
- [x] `fs/Makefile` includes `susfs.o` (obj-$(CONFIG_KSU_SUSFS))

### ✅ Defconfig
- [x] `arch/arm64/configs/a20s_eur_open_defconfig` contains:
  - `CONFIG_KSU=y`
  - `CONFIG_KSU_DEBUG=y`
  - `CONFIG_KSU_SUSFS=y`
  - SUSFS feature flags (SUS_PATH, SUS_MOUNT, etc.)

### ✅ CI Workflow
- [x] `.github/workflows/build-kernel.yml` is valid YAML
- [x] Workflow verifies KernelSU and SUSFS files exist
- [x] Config fragment includes all SUSFS options

## Build Verification

### Configuration Phase
```bash
make ARCH=arm64 a20s_eur_open_defconfig
```

**Expected Results:**
- [ ] No errors during defconfig generation
- [ ] `.config` file created successfully
- [ ] `CONFIG_KSU=y` in `.config`
- [ ] `CONFIG_KSU_SUSFS=y` in `.config`
- [ ] All SUSFS options enabled in `.config`

**Verification Commands:**
```bash
grep "^CONFIG_KSU" .config
grep "CONFIG_OVERLAY_FS" .config  # Required dependency
```

### Build Phase
```bash
# With proper toolchain setup
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
  CC=clang CLANG_TRIPLE=aarch64-linux-gnu- Image.gz-dtb
```

**Expected Results:**
- [ ] No compilation errors in KernelSU files
- [ ] No compilation errors in SUSFS files
- [ ] `out/arch/arm64/boot/Image` or `Image.gz-dtb` created
- [ ] Kernel modules built successfully

### Post-Build Verification
```bash
# Check for KernelSU symbols
strings out/vmlinux | grep -i "kernelsu\|ksu_" | head -10

# Check for SUSFS symbols
strings out/vmlinux | grep -i "susfs" | head -10

# Verify config was applied
grep "CONFIG_KSU" out/.config
```

**Expected Results:**
- [ ] KernelSU symbols present in vmlinux
- [ ] SUSFS symbols present in vmlinux
- [ ] Config options match defconfig

## CI Build Verification

### GitHub Actions
When CI runs, verify:

1. **Setup Phase**
   - [ ] Dependencies installed successfully
   - [ ] Toolchains downloaded/setup correctly

2. **Verification Phase**
   - [ ] "✓ KernelSU-Next found at repository root"
   - [ ] "✓ SUSFS files found"

3. **Configuration Phase**
   - [ ] Defconfig applied without errors
   - [ ] Config fragment merged successfully
   - [ ] `olddefconfig` completed

4. **Build Phase**
   - [ ] Kernel image built successfully
   - [ ] Modules built successfully
   - [ ] No KernelSU-related errors
   - [ ] No SUSFS-related errors

5. **Artifacts**
   - [ ] `kernel-a20s-kernelsu-susfs.zip` created
   - [ ] ZIP contains kernel image
   - [ ] ZIP contains modules (if applicable)

## Post-Installation Verification (On Device)

### Flash & Boot
- [ ] Kernel flashes without errors (TWRP/Fastboot)
- [ ] Device boots successfully
- [ ] No bootloop
- [ ] No kernel panic in logs

### KernelSU Verification
```bash
# Check kernel version
adb shell uname -a
# Should show Linux 4.9.227

# Check if su works
adb shell su -c "id"
# Should return uid=0(root) if KernelSU is working

# Check KernelSU logs
adb shell dmesg | grep ksu
# Should show KernelSU initialization messages
```

**Expected Results:**
- [ ] Root access works via KernelSU
- [ ] KernelSU Manager app can be installed
- [ ] Can grant/deny root permissions through manager

### SUSFS Verification
```bash
# Check SUSFS logs
adb shell dmesg | grep susfs
# Should show SUSFS initialization messages

# Test SUSFS tools (if installed)
adb shell su -c "ksu_susfs --help"
```

**Expected Results:**
- [ ] SUSFS initialized properly
- [ ] No SUSFS-related errors in logs
- [ ] SUSFS features working (path hiding, mount hiding, etc.)

## Common Issues & Solutions

### Issue: Config options not recognized
**Solution**: Ensure `drivers/Kconfig` sources `KernelSU/kernel/Kconfig`, not `drivers/kernelsu/Kconfig`

### Issue: SUSFS not building
**Solution**: Verify:
- `fs/Makefile` has `obj-$(CONFIG_KSU_SUSFS) += susfs.o`
- `KernelSU/kernel/Makefile` has reference to `../../fs/susfs.o`
- `CONFIG_KSU_SUSFS=y` in `.config`

### Issue: Build fails with "unknown warning option"
**Solution**: This is a compiler compatibility issue, not related to KernelSU/SUSFS integration

### Issue: Device won't boot
**Possible Causes:**
- Kernel built with wrong toolchain
- Incompatible kernel configuration
- SELinux issues

**Solution**: Flash stock boot.img to recover, check kernel logs

## Success Criteria

### Minimal Success
- [x] Repository structure is correct
- [x] Build system configuration is correct
- [x] Configuration generates without errors
- [x] All KernelSU and SUSFS configs recognized

### Full Success (Requires Build)
- [ ] Kernel builds without errors
- [ ] KernelSU symbols present in binary
- [ ] SUSFS symbols present in binary
- [ ] Device boots with new kernel
- [ ] Root access works
- [ ] SUSFS features work

## Current Status

✅ **Pre-Build Verification: COMPLETE**
- All source files in place
- Build system correctly configured
- CI workflow fixed and updated
- Configuration verified

⏳ **Build Verification: PENDING**
- Requires cross-compilation toolchain
- Will be verified in CI

⏳ **Post-Installation Verification: PENDING**
- Requires successful build
- Requires device for testing

## Notes

1. The integration uses **KernelSU-Next** (Magic version), not standard KernelSU
2. Some old config options (`CONFIG_KSU_SUSFS_AUTO_ADD_*`) were removed as they don't exist in current version
3. This is for Linux kernel 4.9.227 - features may differ from newer kernels
4. A proper ARM64 toolchain is required for full build

## References

- Integration details: `INTEGRATION_SUMMARY.md`
- Build guide: `KERNELSU_NEXT_SUSFS_GUIDE.md`
- Official docs: https://kernelsu.org/
