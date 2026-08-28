[group("System")]
[no-exit-message]
install-cli:
    #!/usr/bin/env bash
    set -euo pipefail
    TMPDIR=$(mktemp -d)
    curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJf - -C "$TMPDIR"
    bash "$TMPDIR/ble-nightly/ble.sh" --install "$HOME/.local/share"
    rm -rf "$TMPDIR"
    brew update
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
    mkdir -p "$HOME/.local/share/applications"
    printf '%s\n' \
    '[Desktop Entry]' \
    'Version=1.0' \
    'Type=Application' \
    'Name=Cursor' \
    'Comment=AI Code Editor' \
    "Exec=$HOME/Applications/Cursor.AppImage %F" \
    'Icon=cursor' \
    'Terminal=false' \
    'Categories=Development;IDE;TextEditor;' \
    'StartupNotify=true' \
    'MimeType=text/plain;' \
    > "$HOME/.local/share/applications/cursor.desktop"

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
    # Ensure Canon CAPT is installed
    rpm -q cndrvcups-capt >/dev/null 2>&1 || {
        echo "Canon CAPT driver is not installed."
        echo "Please run: ujust install-local-rpms"
        exit 1
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

[group("System")]
[no-exit-message]
enable-adguard-home:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! gum confirm "Replace system DNS with AdGuard Home?"; then
        exit 0
    fi

    ###########################################################################
    # Disable systemd-resolved
    ###########################################################################

    echo "==> Disabling systemd-resolved..."

    sudo systemctl disable --now \
        systemd-resolved.service \
        systemd-resolved-monitor.socket \
        systemd-resolved-varlink.socket

    ###########################################################################
    # Configure NetworkManager
    ###########################################################################

    echo "==> Configuring NetworkManager..."

    for UUID in $(nmcli --get-values UUID connection show); do
        sudo nmcli connection modify "$UUID" \
            ipv4.ignore-auto-dns yes \
            ipv4.dns "127.0.0.1 1.1.1.1" \
            ipv6.ignore-auto-dns yes \
            ipv6.dns "::1 2606:4700:4700::1111"
    done

    sudo rm -f /etc/resolv.conf
    sudo systemctl reload NetworkManager

    ###########################################################################
    # Install AdGuard Home
    ###########################################################################

    echo "==> Installing AdGuard Home..."

    sudo mkdir -p /var/lib/adguardhome/{conf,work}
    sudo mkdir -p /etc/containers/systemd

    sudo tee /etc/containers/systemd/adguardhome.container >/dev/null <<'EOF'
    [Unit]
    Description=AdGuard Home

    [Container]
    Image=docker.io/adguard/adguardhome:latest

    PublishPort=53:53/tcp
    PublishPort=53:53/udp
    PublishPort=80:80/tcp
    PublishPort=443:443/tcp
    PublishPort=443:443/udp
    PublishPort=3000:3000/tcp

    Volume=/var/lib/adguardhome/work:/opt/adguardhome/work:Z
    Volume=/var/lib/adguardhome/conf:/opt/adguardhome/conf:Z

    AutoUpdate=registry

    [Service]
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOF

    if [[ -f /usr/share/AdGuardHome/AdGuardHome.yaml ]] &&
    gum confirm "Import existing AdGuard Home configuration?"; then
        echo "==> Importing configuration..."
        sudo cp \
            /usr/share/AdGuardHome/AdGuardHome.yaml \
            /var/lib/adguardhome/conf/
        imported_config=true
    fi

    sudo systemctl daemon-reload
    sudo systemctl start adguardhome.service 

    sudo firewall-cmd --permanent --add-service=dns
    sudo firewall-cmd --reload

    echo
    echo "=================================================================="
    echo " AdGuard Home has been installed."
    echo
    if ! $imported_config; then
        echo " Complete the setup at:"
        echo
        echo "     http://localhost:3000"
        echo
    fi
    echo "=================================================================="

[group("System")]
[no-exit-message]
reset-adguard-home:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! gum confirm "Reset AdGuard Home configuration?"; then
        exit 0
    fi

    echo "==> Resetting AdGuard Home..."

    sudo systemctl stop adguardhome.service

    sudo rm -rf \
        /var/lib/adguardhome/conf/* \
        /var/lib/adguardhome/work/*

    sudo systemctl start adguardhome.service

    echo
    echo "=================================================================="
    echo " AdGuard Home has been reset."
    echo
    echo " Open:"
    echo
    echo "     http://localhost:3000"
    echo
    echo "=================================================================="

[group("System")]
[no-exit-message]
fix-flatpak:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "==> Configuring Flatpak GTK integration..."

    sudo flatpak override \
        --filesystem=xdg-config/gtk-3.0:ro \
        --filesystem=xdg-config/gtk-4.0:ro

    mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

    cat > ~/.config/gtk-3.0/settings.ini <<'EOF'
    [Settings]
    gtk-theme-name=adw-gtk3-dark
    gtk-application-prefer-dark-theme=true
    EOF

    cat > ~/.config/gtk-4.0/settings.ini <<'EOF'
    [Settings]
    gtk-application-prefer-dark-theme=true
    EOF

# Initialize Secure Boot (if needed) and enroll module signing keys
# Enter password "doudou" in the MOK manager after reboot.
secure-boot-key:
    #!/usr/bin/env bash
    set -euo pipefail
    SBCTL_STATUS="$(sbctl status --json)"
    ENROLLMENT_PASSWORD="doudou"

    if jq -e '.setup_mode' <<<"${SBCTL_STATUS}" >/dev/null; then
        echo "Firmware is in Setup Mode."
        echo "==> Creating Secure Boot keys..."
        sudo sbctl create-keys
        echo "==> Enrolling Secure Boot keys..."
        sudo sbctl enroll-keys -m
    fi

    echo "==> Importing MOK certificates..."

    sudo bash <<EOF
    mokutil --timeout -1
    echo -e "${ENROLLMENT_PASSWORD}\n${ENROLLMENT_PASSWORD}" | mokutil --import "/etc/pki/akmods/certs/akmods-ublue.der"
    echo -e "${ENROLLMENT_PASSWORD}\n${ENROLLMENT_PASSWORD}" | mokutil --import "/etc/pki/doudoud82/doudou.der"
    EOF

    echo
    echo "Reboot to complete enrollment."
    echo
    echo "In the MOK Manager:"
    echo "  • Select 'Enroll MOK'"
    echo "  • Enter the password: doudou"
    echo
    echo "If Secure Boot keys were enrolled with sbctl, you may also need to"
    echo "complete the firmware's Secure Boot key enrollment process."
