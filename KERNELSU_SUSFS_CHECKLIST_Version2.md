# Checklist Validasi KernelSU-Next + susfs (Untuk perangkat uji)

Catatan awal:
- Lakukan semua pengujian pada perangkat uji (bukan produksi).
- Siapkan recovery/backup (TWRP / nandroid / stock recovery).
- Kumpulkan log untuk setiap temuan (dmesg, logcat, /proc/*).

1) Persiapan
- [ ✓] Verifikasi opsi DI-build
  - Perintah host: `grep -E "CONFIG_KSU|CONFIG_SUSFS" .config`
  - Hasil: opsi KSU/SUSFS sesuai yang diharapkan (y/m).
- [ ✓] Build & flash image ke perangkat uji
  - Catat metode flashing dan checksum artifact.
- [✓ ] Pastikan adb terhubung
  - `adb devices`
  - Hasil: perangkat terdaftar.

2) Verifikasi pasca-boot
- [ ✓] Perangkat boot sampai homescreen/adb
  - `adb shell uptime` atau cek `adb shell getprop sys.boot_completed`
- [ ✓] Periksa kernel & log awal
  - `adb shell uname -a`
  - `adb shell dmesg | head -n 200`
  - Hasil: tidak ada panic/oops berkaitan susfs/ksu.

3) Verifikasi konfigurasi kernel runtime
- [ ✓] Cek konfigurasi kernel (jika tersedia)
  - `adb shell 'zcat /proc/config.gz 2>/dev/null | grep -E "KSU|SUSFS"'`
  - Alternatif: periksa .config saat build
  - Hasil: CONFIG_KSU_* dan CONFIG_KSU_SUSFS_* aktif seperti yang diinginkan.
- [ ✓] Periksa filesystems terdaftar
  - `adb shell cat /proc/filesystems | grep -i susfs`
  - Hasil: susfs terdaftar (jika built-in).

4) Verifikasi modul / file binary
- [ ✓] Cek modul / file susfs/KernelSU-Next
  - `adb shell lsmod | grep -i susfs` / cek /proc/modules
  - `adb shell ls -l /system/bin/su /sbin/su` (tergantung lokasi)
  - Hasil: modul/binary ada sesuai packaging.

5) Fungsi dasar KernelSU-Next (manajer & su)
- [✓ ] Install & jalankan KernelSU manager app (jika tersedia)
  - Verifikasi app mendeteksi KernelSU-Next.
- [ ✓] Tes su dasar
  - `adb shell su -c id` atau `adb shell 'which su; su -c id'`
  - Hasil: sesuai ekspektasi (uid=0 atau perilaku KSU-Next).
- [✓ ] Cek log aktivasi/handshake
  - `adb logcat -d | grep -i -E "ksu|kernelsu|susfs|kernelsu-next"`
  - `adb shell dmesg | grep -i ksu`

6) Pengujian susfs — fitur inti
- [ ✓] Magic mount muncul saat manager melakukan operasi
  - `adb shell cat /proc/mounts | grep susfs`
  - Hasil: susfs ter-mount pada path yang diharapkan.
- [ ✓] SU binary hiding (SUS_SU)
  - Cek `ls` biasa dan `find` pada lokasi yang biasanya berisi su.
  - Hasil: binary tersembunyi dari listing normal jika fitur aktif.
- [✓ ] Path hiding & mount hiding
  - Periksa apakah path/mount yang seharusnya disembunyikan tidak muncul pada `ls`/`mount`.
- [✓ ] Uname spoofing (jika tersedia)
  - `adb shell uname -a` dan catat perubahan saat spoof aktif.
- [ ✓] Periksa open-redirect / try-umount behavior
  - Lakukan `umount` terhadap mount yang diproteksi dan periksa hasil/dmesg.

7) Deteksi & kompatibilitas
- [✓ ] Tes aplikasi deteksi root (contoh: SafetyNet checker / root detection apps)
  - Catat apakah su/ksu terdeteksi atau tersembunyi sesuai tujuan.
- [ ✓] SELinux
  - `adb shell getenforce`
  - Jika Enforcing, periksa AVC denials di `dmesg`/logcat terkait ksu/susfs.
  - Hasil: tidak ada AVC yang mengganggu fungsi utama (atau catat AVC dan policy yang diperlukan).
- [ ✓] Build/toolchain compatibility
  - Pastikan perubahan build (clang fixes) tidak menimbulkan runtime errors.

8) Robustness / stress
- [✓ ] Reboot berkala (3–5x) dan verifikasi inisialisasi susfs/ksu stabil.
- [ ✓] Jalankan banyak panggilan su/operasi mount/unmount berulang untuk mendeteksi leak/oops.
- [ ✓] Periksa penggunaan memory/kebocoran di dmesg setelah stress.

9) Logging & artifact
- [ ✓] Kumpulkan artefak:
  - `dmesg` (full), `logcat` (relevant), `/proc/modules`, `/proc/filesystems`, `/proc/mounts`, hasil `su -c id`, `uname -a`.
- [✓ ] Simpan timestamp & langkah reproduksi untuk setiap temuan.

10) Cleanup & rollback
- [ ✓] Pastikan cara rollback/flash stock kernel berfungsi.
- [ ✓] Hapus/disable pengujian jika diperlukan.
- [ ✓] Dokumentasikan semua temuan & buat issue/PR terpisah untuk bug yang ditemukan.

Hasil ringkas yang diharapkan:
- Kernel boot stabil.
- KernelSU-Next bisa diinteraksikan oleh manager; `su` berfungsi sesuai desain.
- susfs menyediakan fitur hiding/spoofing tanpa OOPS/AVC yang kritis.
- Tidak ada memory leak/bootloop; semua temuan dicatat.
