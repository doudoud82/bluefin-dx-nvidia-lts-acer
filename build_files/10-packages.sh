#!/bin/bash

set -ouex pipefail

# Installing packages,font,icon and gnome extension from Fedora repos
dnf -y install ncompress \
    variety \
    rsms-inter-fonts \
    rsms-inter-vf-fonts \
    papirus-icon-theme \
    gnome-shell-extension-just-perfection \
    gnome-shell-extension-user-theme

# Enable RPM Fusion
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

# Install unrar from RPM Fusion and not from Fedora
dnf -y install unrar --disablerepo=* --enablerepo=rpmfusion-nonfree --enablerepo=rpmfusion-nonfree-updates

# Remove RPM Fusion repos
dnf -y remove rpmfusion-*
