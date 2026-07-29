#!/bin/bash

set -ouex pipefail



# Installing packages,font,icon and gnome extension from Fedora repos
dnf -y install ncompress \
    variety \
    util-linux \
    rsms-inter-fonts \
    rsms-inter-vf-fonts \
    papirus-icon-theme \
    gnome-shell-extension-just-perfection \
    gnome-shell-extension-user-theme
dnf clean all

# Enable RPM Fusion
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf config-manager setopt rpmfusion-free.enabled=1 rpmfusion-free-updates.enabled=1
dnf config-manager setopt rpmfusion-nonfree.enabled=1 rpmfusion-nonfree-updates.enabled=1

# Install unrar from RPM Fusion and not from Fedora
dnf -y install unrar  --disablerepo=* --enablerepo=rpmfusion-nonfree --enablerepo=rpmfusion-nonfree-updates
# Disable RPM Fusion
dnf config-manager setopt rpmfusion-free.enabled=0 rpmfusion-free-updates.enabled=0
dnf config-manager setopt rpmfusion-nonfree.enabled=0 rpmfusion-nonfree-updates.enabled=0
rm -f /etc/yum.repos.d/rpmfusion-free* /etc/yum.repos.d/rpmfusion-nonfree*
dnf clean all
