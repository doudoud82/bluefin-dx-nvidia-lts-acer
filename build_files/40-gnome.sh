#!/bin/bash

set -ouex pipefail

curl_retry() {
    curl -fsSL \
        --retry 5 \
        --retry-delay 2 \
        --retry-max-time 90 \
        --connect-timeout 10 \
        --max-time 180 \
        "$@"
}

dnf -y remove gnome-extensions-app 
dnf clean all

EXTENSIONS=(
    "adw-gtk3-colorizer@NiffirgkcaJ.github.com"
    "Bluetooth-Battery-Meter@maniacx.github.com"
    "clipboard-indicator@tudmotu.com"
    "extension-list@tu.berry"
    "foresight@pesader.dev"
    "legacyschemeautoswitcher@joshimukul29.gmail.com"
    "MaximizeWindowIntoNewWorkspace@kyleross.com"
    "printers@linux-man.org"
    "status-area-horizontal-spacing@mathematical.coffee.gmail.com"
    "systemd-manager@hardpixel.eu"
    "Vitals@CoreCoding.com"
    "weatheroclock@CleoMenezesJr.github.io"
)
mkdir -p /usr/share/gnome-shell/extensions
for uuid in "${EXTENSIONS[@]}"; do
    pk=$(
        curl_retry "https://extensions.gnome.org/extension-info/?uuid=${uuid}" |
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

    curl_retry -o "$zip" "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${pk}"

    unzip -oq "$zip" -d "/usr/share/gnome-shell/extensions/${uuid}"
    
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

url=$(
    curl_retry \
        https://api.github.com/repos/hardpixel/systemd-manager/releases/latest |
    jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url'
)

curl_retry -o "$tmp" "$url"

unzip -oq "$tmp" -d /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu

find /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu -type d -exec chmod 755 {} +
find /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu -type f -exec chmod 644 {} +

glib-compile-schemas /usr/share/gnome-shell/extensions/systemd-manager@hardpixel.eu/schemas

rm -f "$tmp"
