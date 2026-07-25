# Append user bin directories to PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin:$PATH"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH
# SSH agent socket gotta enable user ssh-agent.socket
if [[ -z $SSH_AUTH_SOCK ]]; then
    if [[ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    elif [[ -S "$XDG_RUNTIME_DIR/openssh_agent" ]]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"
    fi
fi

# Load opam configuration
if [[ -r "$HOME/.opam/opam-init/init.sh" ]]; then
    . "$HOME/.opam/opam-init/init.sh" >/dev/null 2>&1
fi

# Load rustup bins from linuxbrew
if [[ -d "/home/linuxbrew/.linuxbrew/opt/rustup/bin" ]]; then
    PATH="/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH"
fi

# source bashrc for login shell
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi