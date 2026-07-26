#!/usr/bin/env bash
set -euo pipefail

# ── 1. Determine whether the base image's kernel matches what akmods built against ──
CURRENT_KVER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)

TARGET_KERNEL_CORE_RPM=$(ls /ctx/kernel-rpms/kernel-core-*.rpm | head -n1)
TARGET_KVER=$(rpm -qp --qf '%{VERSION}-%{RELEASE}.%{ARCH}' "${TARGET_KERNEL_CORE_RPM}")

echo "==> Current kernel:  ${CURRENT_KVER}"
echo "==> akmods kernel:   ${TARGET_KVER}"

if [[ "${CURRENT_KVER}" != "${TARGET_KVER}" ]]; then
    echo "==> Kernel mismatch, switching to the akmods kernel"
    dnf -y remove --no-autoremove kernel kernel-devel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
    dnf -y install \
        /ctx/kernel-rpms/kernel-[0-9]*.rpm \
        /ctx/kernel-rpms/kernel-core-*.rpm \
        /ctx/kernel-rpms/kernel-devel-*.rpm \
        /ctx/kernel-rpms/kernel-modules-*.rpm

    # Reinstall stuff that gets pulled out with the kernel swap
    dnf -y install guestfs-tools virt-v2v virtualbox-guest-additions usbip

    # v4l2loopback shipped in bluefin-dx-nvidia-open is built against it's own kernel.
    # If we just swapped kernels, we need the akmods-built kmod that matches the
    # *new* kernel instead — pull it from the newer akmods:main-44 image.
    echo "==> Reinstalling v4l2loopback matched to the new kernel"
    dnf -y install \
        /ctx/akmods-common/ublue-os/ublue-os-akmods*.rpm \
        /ctx/akmods-common/kmods/kmod-v4l2loopback*.rpm \
        /ctx/akmods-common/common/v4l2loopback*.rpm
else
    echo "==> Kernel already matches akmods target, skipping kernel switch and v4l2loopback reinstall"
fi

# ── 2. Downgrade Nvidia: base ships nvidia open driver, 
# we want 580 proprietary from akmods-nvidia-lts.
echo "==> Removing base's nvidia driver to allow 580 downgrade"
dnf -y remove --no-autoremove \
        nvidia-driver-common \
        nvidia-libXNVCtrl \
        nvidia-modprobe \
        ublue-os-nvidia-addons \
        || echo "==> Some packages already absent, continuing"

echo "==> Installing Nvidia 580 (LTS) via akmods-nvidia-lts"
source /ctx/akmods-nvidia-lts/kmods/nvidia-vars
INSTALLED_KVER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)
if [[ "${INSTALLED_KVER}" != "${KERNEL_VERSION}" ]]; then
    echo "ERROR: installed kernel (${INSTALLED_KVER}) does not match nvidia-vars KERNEL_VERSION (${KERNEL_VERSION})"
    echo "This likely means the kernel-switch step above didn't run when it needed to."
    exit 1
fi

AKMODNV_PATH=/ctx/akmods-nvidia-lts IMAGE_NAME="" /ctx/akmods-nvidia-lts/ublue-os/nvidia-install.sh

# ── 3. ATH patching, now that the final kernel + its -devel/source are in place ──
if [[ "${ATH_PATCH:-false}" == "true" ]]; then
    /ctx/60-ath-patch.sh
fi