[group("System")]
[no-exit-message]
install-cli:
    brew tap valkyrie00/bbrew
    brew trust valkyrie00/bbrew
    brew bundle --file=/usr/share/ublue-os/homebrew/cli.Brewfile
    systemctl enable --user ssh-agent.socket 

[group("System")]
[no-exit-message]
install-fonts:
    brew tap colindean/fonts-nonfree
    brew trust colindean/fonts-nonfree
    brew bundle --file=/usr/share/ublue-os/homebrew/fonts.Brewfile

[group("System")]
[no-exit-message]
install-system-applications:
    brew tap amir1376/tap
    brew trust amir1376/tap
    brew bundle --file=/usr/share/ublue-os/homebrew/system-flatpaks.Brewfile

[group("System")]
[no-exit-message]
install-system-dx-applications:
    brew tap ublue-os/tap
    brew trust ublue-os/tap
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
        "System Applications" \
        "System DX Applications" \
        "DX Groups")
    grep -qx "CLI tools" <<<"$choices" && ujust install-cli
    grep -qx "Fonts" <<<"$choices" && ujust install-fonts
    grep -qx "System Applications" <<<"$choices" && ujust install-system-applications
    grep -qx "System DX Applications" <<<"$choices" && ujust install-system-dx-applications
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

    systemctl enable --now ccpd.service >/dev/null

    echo "Canon LBP6020 configured successfully."
