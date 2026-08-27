#!/bin/bash

set -ouex pipefail

mkdir -p /var/usrlocal/bin
mkdir -p /var/opt
dnf install -y --no-gpgchecks --setopt=tsflags=nocrypto /ctx/local_rpms/*.rpm
dnf clean all