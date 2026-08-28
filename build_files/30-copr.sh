#!/bin/bash

set -ouex pipefail

# Install SBCTL
dnf -y copr enable chenxiaolong/sbctl
dnf -y install sbctl
dnf -y copr disable chenxiaolong/sbctl

# Install Bibita cursor
dnf -y copr enable peterwu/rendezvous
dnf -y install bibata-cursor-themes
dnf -y copr disable peterwu/rendezvous
