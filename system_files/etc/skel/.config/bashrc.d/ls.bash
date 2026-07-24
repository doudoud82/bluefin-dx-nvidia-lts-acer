if [ "$(command -v eza)" ]; then
    alias ls='eza'
    alias ll='eza -lah --icons=auto --group-directories-first'
    alias l.='eza -d .*'
else
    alias ls='ls --color=auto'
    alias ll='ls -alFh'
    alias l.='ls -A | grep -E "^\."'
fi