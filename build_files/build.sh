#!/bin/bash

set -ouex pipefail
cp -avf "/ctx/system_files"/. /

dnf -y copr enable chenxiaolong/sbctl
dnf -y install sbctl
dnf -y copr disable chenxiaolong/sbctl
