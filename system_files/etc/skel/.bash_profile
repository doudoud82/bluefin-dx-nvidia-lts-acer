path_prepend() {
    [[ -d "$1" ]] || return
    [[ ":$PATH:" == *":$1:"* ]] || PATH="$1:$PATH"
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/share/JetBrains/Toolbox/scripts"

export PATH
unset -f path_prepend

[[ -r ~/.bashrc ]] && . ~/.bashrc