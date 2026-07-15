[group("System")]
[no-exit-message]
install-cli:
    brew trust valkyrie00/bbrew
    brew bundle --file=/usr/share/ublue-os/homebrew/cli.Brewfile

[group("System")]
[no-exit-message]
install-fonts:
    brew trust colindean/fonts-nonfree
    brew bundle --file=/usr/share/ublue-os/homebrew/fonts.Brewfile

[group("System")]
[no-exit-message]
install-flatpaks:
    brew trust amir1376/tap
    brew bundle --file=/usr/share/ublue-os/homebrew/system-flatpaks.Brewfile

[group("System")]
[no-exit-message]
install-dx-flatpaks:
    brew trust ublue-os/tap
    # Cursor Icons
    wget "https://uxwing.com/wp-admin/admin-ajax.php?action=resize_image&size=128x128&file=cursor-ai-code-icon.png&category_slug=brands-and-social-media" -O "~/.local/share/icons/cursor.png"
    brew bundle --file=/usr/share/ublue-os/homebrew/system-dx-flatpaks.Brewfile

[group("System")]
[no-exit-message]
post-install:
    #!/usr/bin/env bash
    choices=$(gum choose \
        --no-limit \
        --header "Select what to install" \
        "CLI tools" \
        "Fonts" \
        "System Flatpaks" \
        "DX Flatpaks" \
        "DX Groups")
    grep -qx "CLI tools" <<<"$choices" && ujust install-cli
    grep -qx "Fonts" <<<"$choices" && ujust install-fonts
    grep -qx "System Flatpaks" <<<"$choices" && ujust install-flatpaks
    grep -qx "DX Flatpaks" <<<"$choices" && ujust install-dx-flatpaks
    grep -qx "DX Groups" <<<"$choices" && ujust dx-group

[group("System")]
[no-exit-message]
install-lbp6020:
    #!/usr/bin/pkexec bash
    set -euo pipefail

    gum confirm "Configure the Canon LBP6020 printer?" || exit 0

    [ -e /dev/usb/LBP6020 ] || {
        echo "Canon LBP6020 is not connected."
        exit 0
    }

    # Remove existing configuration if present
    lpadmin -x LBP6020 2>/dev/null || true
    ccpdadmin -x LBP6020 2>/dev/null || true

    # Recreate printer
    lpadmin \
        -p LBP6020 \
        -m CNCUPSLBP6020CAPTK.ppd \
        -v ccp://localhost:59687 \
        -E

    ccpdadmin \
        -p LBP6020 \
        -o /dev/usb/LBP6020

    systemctl enable --now ccpd.service

    echo "Canon LBP6020 configured successfully."
