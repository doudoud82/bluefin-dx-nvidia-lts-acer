# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export EDITOR="nano"
command -v micro >/dev/null 2>&1 && export EDITOR=micro
if [ -n "$DISPLAY" ]; then
    if command -v code >/dev/null 2>&1; then
        export EDITOR="code_wait"
    fi
fi

export VISUAL="$EDITOR"
export MANPAGER='less -R --use-color -Dd+r -Du+b'
export MANROFFOPT='-P -c'
export PAGER='less'
HISTCONTROL='erasedups:ignorespace'
HISTSIZE=500
HISTFILESIZE=5000
shopt -s autocd 
shopt -s cdspell 
shopt -s cmdhist 
shopt -s dotglob
shopt -s histappend 
shopt -s expand_aliases 
shopt -s checkwinsize
bind 'set completion-ignore-case on'

#ble.sh
[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh" --noattach

#personal bash files
if [ -d ~/.config/bashrc.d ]; then
    for file in ~/.config/bashrc.d/*.bash; do
        [ -r "$file" ] && source "$file"
    done
fi

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"

if  command -v starship >/dev/null 2>&1 && [ "$TERM" != 'linux' ]; then
	eval "$(starship init bash)"
else
    PS1='\[\e[32m\]\u\[\e[0m\] \[\e[96m\]\w\[\e[0m\] '
fi
#attach ble.sh
[[ ! ${BLE_VERSION-} ]] || ble-attach