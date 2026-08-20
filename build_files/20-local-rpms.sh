#!/bin/bash

set -ouex pipefail

echo "=== 99-config_manager.repo contents ==="
cat -A /etc/dnf/repos.override.d/99-config_manager.repo || echo "file missing"
echo "=== end ==="

mkdir -p /var/usrlocal/bin
dnf install -y --no-gpgchecks --setopt=tsflags=nocrypto /ctx/local_rpms/*.rpm
dnf clean all