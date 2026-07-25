#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

#Cursor Icon
wget "https://uxwing.com/wp-admin/admin-ajax.php?action=resize_image&size=128x128&file=cursor-ai-code-icon.png&category_slug=brands-and-social-media" -O "/usr/share/icons/cursor.png"

if [[ "${ATH_PATCH:-false}" == "true" ]]; then
    /ctx/50-ath-patch.sh
fi

dconf update