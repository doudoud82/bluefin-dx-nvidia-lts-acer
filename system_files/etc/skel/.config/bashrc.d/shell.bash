alias tobash='sudo chsh $USER -s /usr/bin/bash'
alias tozsh='sudo chsh $USER -s /usr/bin/zsh'
alias tofish='sudo chsh $USER -s /usr/bin/fish'

# Bash preexec
[ -f "/etc/profile.d/bash-preexec.sh" ] && . "/etc/profile.d/bash-preexec.sh"
[ -f "/usr/share/bash-prexec" ] && . "/usr/share/bash-prexec"
[ -f "/usr/share/bash-prexec.sh" ] && . "/usr/share/bash-prexec.sh"
[ -f "${HOMEBREW_PREFIX}/etc/profile.d/bash-preexec.sh" ] && . "${HOMEBREW_PREFIX}/etc/profile.d/bash-preexec.sh"