#!/bin/bash

set -ouex pipefail
rm -rf /etc/skel
# This is an nvidia image so gotta do some clean up
dnf -y remove rocm-hip rocm-opencl rocm-smi rocminfo
