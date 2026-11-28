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


# --- cheatsheets (~/dotfiles/cheatsheets/*.md) ---
#   cheat            pick one with fzf (preview on the right)
#   cheat dock       open docker.md read-only — a unique prefix is enough
#   cheat -e name    edit (creates a new sheet if it doesn't exist)
#   cheat -g text    search all sheets with rg
#   cheat -l         list names
CHEAT_DIR="$HOME/dotfiles/cheatsheets"

# names without .md, one per line (used by cheat and its tab completion)
_cheat_list() {
  command ls "$CHEAT_DIR" 2>/dev/null | sed -n 's/\.md$//p'
}

cheat() {
  local mode=view name f matches n preview
  case "$1" in
    -h|--help)
      echo "usage: cheat [name] | -e name | -g text | -l"
      return 0 ;;
    -l|--list)
      _cheat_list
      return 0 ;;
    -g|--grep)
      shift
      [ -n "$1" ] || { echo "usage: cheat -g text" >&2; return 1; }
      if command -v rg >/dev/null 2>&1; then
        command rg --smart-case --heading --line-number -- "$*" "$CHEAT_DIR"
      else
        grep -rin -- "$*" "$CHEAT_DIR"
      fi
      return ;;
    -e|--edit)
      mode=edit
      shift ;;
  esac
  name=$1

  # no name: choose with fzf (Debian calls bat "batcat")
  if [ -z "$name" ]; then
    if ! command -v fzf >/dev/null 2>&1; then
      _cheat_list
      return 0
    fi
    if command -v batcat >/dev/null 2>&1; then
      preview="batcat --color=always --style=plain --language=md"
    elif command -v bat >/dev/null 2>&1; then
      preview="bat --color=always --style=plain --language=md"
    else
      preview="cat"
    fi
    name=$(_cheat_list | fzf --prompt='cheat> ' --height=80% --reverse \
      --preview "$preview $CHEAT_DIR/{}.md" --preview-window=right,70%) || return 1
  fi

  f="$CHEAT_DIR/$name.md"
  # not an exact name: accept a unique prefix ("dock" -> docker)
  if [ ! -f "$f" ]; then
    matches=$(_cheat_list | grep -- "^$name")
    n=$(printf '%s\n' "$matches" | grep -c .)
    if [ "$n" -eq 1 ]; then
      f="$CHEAT_DIR/$matches.md"
    elif [ "$mode" = edit ] && [ "$n" -eq 0 ]; then
      printf '# %s cheatsheet\n\n' "$name" > "$f"   # new sheet
    elif [ "$n" -gt 1 ]; then
      echo "ambiguous: $(echo $matches)" >&2
      return 1
    else
      echo "no cheatsheet '$name' — have: $(echo $(_cheat_list))" >&2
      return 1
    fi
  fi

  if [ "$mode" = edit ]; then
    nvim "$f"
    echo "remember: cd ~/dotfiles && git add -A && git commit && git push"
  else
    nvim -R "$f"
  fi
}

# tab completion: "cheat d<Tab>" -> docker
if [ -n "$BASH_VERSION" ]; then
  _cheat_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$(_cheat_list) -e -g -l" -- "$cur") )
  }
  complete -F _cheat_complete cheat
elif [ -n "$ZSH_VERSION" ]; then
  _cheat_zsh() { compadd -- $(_cheat_list); }
  # compdef only exists after compinit (most zsh setups run it before this file)
  (( $+functions[compdef] )) && compdef _cheat_zsh cheat
fi
