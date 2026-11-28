# ~/.config/shell/init.sh — sourced from ~/.bashrc and ~/.zshrc (added by install.sh)
# Works in bash and zsh. Loads: common aliases -> OS aliases -> host aliases -> local file.

_shell_dir="$HOME/.config/shell"

# user binaries (lazygit, yazi, gping installed by install.sh land here)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

export EDITOR=nvim
export VISUAL=nvim

# zsh: allow "# comments" in the interactive shell (bash does this by default)
[ -n "$ZSH_VERSION" ] && setopt interactive_comments

# 1. common aliases (every machine)
[ -f "$_shell_dir/aliases.sh" ] && . "$_shell_dir/aliases.sh"

# 2. OS-specific (debian.sh, arch.sh) — picked from /etc/os-release
# (looping over $(...) directly: zsh does not word-split plain variables)
for _id in $( (. /etc/os-release 2>/dev/null && echo "$ID $ID_LIKE") ); do
  if [ -f "$_shell_dir/os/$_id.sh" ]; then
    . "$_shell_dir/os/$_id.sh"
    break
  fi
done

# 3. host-specific (host/<hostname>.sh)
_host=$(uname -n)
[ -f "$_shell_dir/host/$_host.sh" ] && . "$_shell_dir/host/$_host.sh"

# 4. private, untracked additions for this machine only (never committed)
[ -f "$_shell_dir/local.sh" ] && . "$_shell_dir/local.sh"

# fzf key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd, **<Tab> completion
# (fzf >= 0.48 prints its own setup script; older versions print nothing here)
if command -v fzf >/dev/null 2>&1; then
  if [ -n "$BASH_VERSION" ]; then
    eval "$(fzf --bash 2>/dev/null)"
  elif [ -n "$ZSH_VERSION" ]; then
    eval "$(fzf --zsh 2>/dev/null)"
  fi
fi

unset _shell_dir _id _host
