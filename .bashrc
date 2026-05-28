# ~/.ashrc – Enhanced for usability and appearance

# ========== Prompt ==========
# Colorful PS1: user@host:path$
PS1='\[\e[1;32m\]\u@\h:\[\e[1;34m\]\w\[\e[0m\]\$ '

# ========== Aliases ==========

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Listing
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias l='ls -CF'

# System / package updates (Alpine-specific)
alias apkup='sudo apk update && sudo apk upgrade'

# Search
alias grep='grep --color=auto'

# Editing
alias v='vim'
alias e='nano'

# Networking
alias myip='ip a | grep inet'

# Disk usage
alias df='df -h'
alias du='du -h'

# ========== History Settings ==========
export HISTFILE="$HOME/.ash_history"
export HISTSIZE=500
export HISTFILESIZE=1000

# ========== Less Annoying ==========

# Don’t beep on tab-completion
set +o vi
