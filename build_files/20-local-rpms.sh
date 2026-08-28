#!/bin/bash

set -ouex pipefail

mkdir -p /tmp/rpm

wget https://windscribe.com/install/desktop/linux_rpm_x64 -O /tmp/rpm/windscribe.rpm
wget https://www.hamrick.com/files/vuex6498.rpm -O /tmp/rpm/vuescan.rpm
mkdir -p /var/opt
# Windscribe
mkdir -p /usr/lib/windscribe
ln -s /usr/lib/windscribe /opt/windscribe

# Capt
mkdir -p /var/usrlocal
mkdir -p /usr/lib/local-overlay/bin
mkdir -p /usr/lib/local-overlay/lib64
mkdir -p /usr/lib/local-overlay/share/locale
ln -s /usr/lib/local-overlay/bin /usr/local/bin
ln -s /usr/lib/local-overlay/lib64 /usr/local/lib64
mkdir -p /usr/local/share
ln -s /usr/lib/local-overlay/share/locale /usr/local/share/locale

dnf install -y --no-gpgchecks --setopt=tsflags=nocrypto /ctx/local_rpms/*.rpm /tmp/rpm/*.rpm
