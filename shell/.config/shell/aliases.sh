# Common aliases — loaded on every machine (bash + zsh)

# --- safety / readable output ---
alias cp='cp -i'
alias df='df -h'
alias free='free -m'
alias du1='du -h --max-depth=1'

# --- navigation ---
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'
alias la='ls -A'

# --- editor ---
alias v='nvim'

# --- git ---
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gitu='git add . && git commit && git push'
alias lg='lazygit'

# --- tools ---
alias rg='rg --smart-case'
alias gp='gping'
alias nh='sudo nethogs'
alias y='yazi'
alias ports='sudo ss -tulpn'
