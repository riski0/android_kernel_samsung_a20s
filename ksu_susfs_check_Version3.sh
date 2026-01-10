#!/system/bin/sh

echo "=== KernelSU + SUSFS Deep Validation v3 ==="
echo

echo "[*] Kernel:"
uname -a
echo

echo "[*] KernelSU:"
if [ -e /proc/kernelsu ]; then
    cat /proc/kernelsu
else
    echo "KernelSU NOT detected"
fi
echo

echo "[*] SUSFS filesystem:"
grep susfs /proc/filesystems || echo "susfs fs NOT detected"
echo

echo "[*] Mount hooks:"
mount | grep susfs || echo "no susfs mount found"
echo

echo "[*] Cred hooks:"
grep -R "kernelsu" /proc/kallsyms 2>/dev/null | head -n 5 || echo "no ksu symbols"
echo

echo "[*] SELinux hooks:"
getenforce 2>/dev/null || echo "selinux userspace not accessible"
echo

echo "[*] Done."

