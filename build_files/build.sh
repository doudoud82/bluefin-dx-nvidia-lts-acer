#!/bin/bash

set -ouex pipefail
rm -rf /etc/skel/.config
rm -rf /etc/skel/.local
cp -avf "/ctx/system_files"/. /

# Installing packages from Fedora repos
dnf -y install ncompress
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

# Install local rpms
mkdir -p /var/usrlocal/bin
dnf install -y --no-gpgchecks --setopt=tsflags=nocrypto /ctx/localrpms/*.rpm
dnf clean all


# Install SBCTL
dnf -y copr enable chenxiaolong/sbctl
dnf -y install sbctl
dnf -y copr disable chenxiaolong/sbctl

# Install Bibita cursor
dnf -y copr enable peterwu/rendezvous
dnf -y install bibata-cursor-themes
dnf -y copr disable peterwu/rendezvous

# Installing font,icon and gnome extension
dnf -y install rsms-inter-fonts rsms-inter-vf-fonts papirus-icon-theme gnome-shell-extension-just-perfection gnome-shell-extension-user-theme
dnf -y remove gnome-extensions-app 
dnf clean all

EXTENSIONS=(
    "adw-gtk3-colorizer@NiffirgkcaJ.github.com"
    "Bluetooth-Battery-Meter@maniacx.github.com"
    "clipboard-indicator@tudmotu.com"
    "extension-list@tu.berry"
    "foresight@pesader.dev"
    "legacyschemeautoswitcher@joshimukul29.gmail.com"
    "MaximizeToEmptyWorkspace-extension@kovari.cc"
    "MaximizeWindowIntoNewWorkspace@kyleross.com"
    "printers@linux-man.org"
    "status-area-horizontal-spacing@mathematical.coffee.gmail.com"
    "systemd-manager@hardpixel.eu"
    "Vitals@CoreCoding.com"
    "weatheroclock@CleoMenezesJr.github.io"
    "window-title-is-back@fthx"
)
mkdir -p /usr/share/gnome-shell/extensions
for uuid in "${EXTENSIONS[@]}"; do
    pk=$(
        curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}" |
        jq -r '
            .shell_version_map
            | to_entries
            | max_by(.key | split(".") | map(tonumber))
            | .value.pk
        '
    )

    [ "$pk" != "null" ] || {
    echo "Failed to find a downloadable version for $uuid"
    continue
}
    zip=$(mktemp)

    curl -fsSL -o "$zip" "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${pk}"

    unzip -q "$zip" -d "/usr/share/gnome-shell/extensions/${uuid}"
    
    # Compile GSettings schemas if present
    if [ -d "/usr/share/gnome-shell/extensions/${uuid}/schemas" ]; then
        glib-compile-schemas "/usr/share/gnome-shell/extensions/${uuid}/schemas"
    fi

    # Fix permissions
    find "/usr/share/gnome-shell/extensions/${uuid}" -type d -exec chmod 755 {} +
    find "/usr/share/gnome-shell/extensions/${uuid}" -type f -exec chmod 644 {} +

    rm -f "$zip"
done

tmp=$(mktemp)

curl -fsSL "$(
    curl -fsSL https://api.github.com/repos/hardpixel/systemd-manager/releases/latest |
    jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url'
)" -o "$tmp"

unzip -q "$tmp" -d /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu

find /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu -type d -exec chmod 755 {} +
find /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu -type f -exec chmod 644 {} +

glib-compile-schemas /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu/schemas

rm -f "$tmp"
#Cursor Icon
wget "https://uxwing.com/wp-admin/admin-ajax.php?action=resize_image&size=128x128&file=cursor-ai-code-icon.png&category_slug=brands-and-social-media" -O "/usr/share/icons/cursor.png"

dconf update
