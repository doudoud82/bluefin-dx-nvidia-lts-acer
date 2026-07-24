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

# fzf and fzf-tab-completion
if command -v fzf >/dev/null && command -v git >/dev/null && ! [ -d "$HOME/.local/share/fzf-tab-completion" ]; then
    git clone https://github.com/lincheney/fzf-tab-completion.git $HOME/.local/share/fzf-tab-completion
fi

if [[ -f "$HOME/.local/share/fzf-tab-completion/bash/fzf-bash-completion.sh" ]]; then
    eval "$(fzf --bash)"
    source "$HOME/.local/share/fzf-tab-completion/bash/fzf-bash-completion.sh"
    bind -x '"\t": fzf_bash_completion'
fi
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

# Default prompt configuration
setPrompt(){
	PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
	PS1='\[\e[32m\]\u\[\e[0m\] \[\e[96m\]\w\[\e[0m\] \[\e[91m\]${PS1_CMD1}\[\e[0m\] '
}
if  command -v starship >/dev/null 2>&1 && [ "$TERM" != 'linux' ]; then
	eval "$(starship init bash)"
else
    setPrompt
fi