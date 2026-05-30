# ~/.profile – User login shell initialization

# ========== PATH Configuration ==========

# Add custom user bin directories if they exist
[ -d "$HOME/bin" ]       && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Export PATH
export PATH

# ========== Editor Settings ==========
export EDITOR=nano     # or "vim" or "micro"
export VISUAL=$EDITOR

# ========== Locale (Uncomment and adjust if needed) ==========
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"

# ========== History Control ==========
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000
export HISTFILESIZE=2000

# ========== Source .bashrc ==========
# Make sure interactive settings apply even in login shells
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
