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
alias ports='sudo ss -tulpn'

# --- yazi quick tool ---

y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}


# --- chearsheet yazi ---
# cheatsheets: "cheat yazi" opens ~/dotfiles/cheatsheets/yazi.md read-only in nvim
cheat() {
  local f="$HOME/dotfiles/cheatsheets/$1.md"
  [ -f "$f" ] || { ls "$HOME/dotfiles/cheatsheets"; return 1; }
  nvim -R "$f"
}
