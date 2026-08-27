#!/bin/bash

set -ouex pipefail

mkdir -p /var/usrlocal/bin
mkdir -p /var/opt
wget https://windscribe.com/install/desktop/linux_rpm_x64 -O /tmp/windscribe.rpm
dnf install -y --no-gpgchecks --setopt=tsflags=nocrypto /tmp/windscribe.rpm /ctx/local_rpms/*.rpm
dnf clean all