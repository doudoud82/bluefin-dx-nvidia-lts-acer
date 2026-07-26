#!/usr/bin/env bash
set -euo pipefail

KVER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)
KPLAIN=$(rpm -q --qf '%{VERSION}' kernel-core)
KDIR="/usr/src/kernels/${KVER}"
WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' EXIT
SRC="${WORKDIR}/linux-${KPLAIN}/drivers/net/wireless/ath"
DEST="/usr/lib/modules/${KVER}/kernel/drivers/net/wireless/ath"
echo "==> Target kernel: KVER=${KVER}  KPLAIN=${KPLAIN}"
dnf5 -y config-manager setopt fedora-source.enabled=1 updates-source.enabled=1
dnf5 download --source "kernel-$(rpm -q --qf '%{VERSION}-%{RELEASE}' kernel-core)" --destdir "${WORKDIR}"
cd "${WORKDIR}"
rpm2cpio kernel-*.src.rpm | cpio -idmv

echo "==> Extracting source tarball"
tar -xf "linux-${KPLAIN}.tar.xz"
cd "linux-${KPLAIN}"
REDHAT_PATCH=$(ls ../patch-*-redhat.patch)
patch -p1 < "${REDHAT_PATCH}"
dnf5 -y config-manager setopt fedora-source.enabled=0 updates-source.enabled=0

# ── write + run the ath_regd patch ───────────────────────────────────────────
echo "==> Applying CONFIG_ATH_USER_REGD patch"
cat > "${WORKDIR}/apply_ath_regd_patch.py" << 'PYEOF'
import sys, re

path_regd = sys.argv[1] + "/drivers/net/wireless/ath/regd.c"
path_kconfig = sys.argv[1] + "/drivers/net/wireless/ath/Kconfig"

with open(path_regd) as f:
    src = f.read()

GUARD_VOID = "\n#ifdef CONFIG_ATH_USER_REGD\n\treturn;\n#endif\n"
GUARD_INT  = "\n#ifdef CONFIG_ATH_USER_REGD\n\treturn 0;\n#endif\n"

if "CONFIG_ATH_USER_REGD" in src:
    print("regd.c already patched")
else:
    targets_void = ["ath_reg_apply_beaconing_flags","ath_reg_apply_ir_flags","ath_reg_apply_radar_flags"]
    target_int = "ath_regd_init_wiphy"

    def insert_after_open_brace(text, func_name, guard):
        idx = 0
        while True:
            pos = text.find(func_name, idx)
            if pos == -1:
                print(f"[warn] function not found: {func_name}")
                return text, False
            after = text[pos:]
            m = re.search(r'\)\s*\n?\s*\{', after)
            if m:
                abs_end = pos + m.end()
                return text[:abs_end] + guard + text[abs_end:], True
            idx = pos + 1

    modified = src
    applied = 0
    for fn in targets_void:
        modified, ok = insert_after_open_brace(modified, fn, GUARD_VOID)
        if ok: applied += 1
    modified, ok = insert_after_open_brace(modified, target_int, GUARD_INT)
    if ok: applied += 1

    if applied == 0:
        sys.exit("ERROR: no functions matched in regd.c")

    with open(path_regd, "w") as f:
        f.write(modified)
    print(f"Guards inserted into {applied}/4 functions.")

with open(path_kconfig) as f:
    src = f.read()

if "ATH_USER_REGD" in src:
    print("Kconfig already patched")
else:
    block = "\nconfig ATH_USER_REGD\n\tbool \"Do not enforce EEPROM regulatory restrictions\"\n\tdefault n\n"
    new, n = re.subn(r'(\nconfig ATH_)', block + r'\1', src, count=1)
    if not n:
        new, n = re.subn(r'(if WLAN_VENDOR_ATH\n)', r'\1' + block, src, count=1)
    if not n:
        new = src + block
        print("[warn] appended at end of Kconfig")
    else:
        print("ATH_USER_REGD added to Kconfig")
    with open(path_kconfig, "w") as f:
        f.write(new)
PYEOF

python3 "${WORKDIR}/apply_ath_regd_patch.py" "${WORKDIR}/linux-${KPLAIN}"

echo "==> Building ath.ko"
make -j"$(nproc)" -C "${KDIR}" \
    M="${SRC}" \
    KCFLAGS="-DCONFIG_ATH_USER_REGD" \
    modules

echo "==> Installing patched module into ${DEST}"
KO="${SRC}/ath.ko"

if [[ -f "${DEST}/ath.ko.zst" ]]; then
    zstd -f -q "${KO}" -o "${DEST}/ath.ko.zst"
elif [[ -f "${DEST}/ath.ko.xz" ]]; then
    xz -f -c "${KO}" > "${DEST}/ath.ko.xz"
else
    cp -f "${KO}" "${DEST}/ath.ko"
fi

depmod -a "${KVER}"

echo "==> Done. Patched ath.ko installed for kernel ${KVER}."