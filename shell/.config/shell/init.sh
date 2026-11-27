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

# 1. common aliases (every machine)
[ -f "$_shell_dir/aliases.sh" ] && . "$_shell_dir/aliases.sh"

# 2. OS-specific (debian.sh, arch.sh) — picked from /etc/os-release
_os_ids=$( (. /etc/os-release 2>/dev/null && echo "$ID $ID_LIKE") )
for _id in $_os_ids; do
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

unset _shell_dir _os_ids _id _host
