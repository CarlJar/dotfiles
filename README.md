# dotfiles

My shell aliases, tool list and installer — for the Raspberry Pi (`carl-pi`), my laptop and future homelab machines.
Neovim config lives in its own repo: [CarlJar/nvim_cj](https://github.com/CarlJar/nvim_cj) (cloned by the installer).

## Quick start (new machine)

```bash
git clone https://github.com/CarlJar/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh          # packages + tools + aliases + nvim config
exec $SHELL           # reload the shell
```

Partial runs:

| Command | Does |
|---|---|
| `./install.sh packages` | system packages + extra tools |
| `./install.sh link` | link configs with stow, hook into `~/.bashrc` / `~/.zshrc` |
| `./install.sh nvim` | clone the nvim config and install its plugins |

Everything can be re-run safely; installed things are skipped.

## What gets installed

| | Debian / Raspberry Pi OS | Arch / Manjaro |
|---|---|---|
| Base tools | `packages/apt.txt` | `packages/pacman.txt` |
| Neovim | official release → `/opt/nvim-linux-<arch>` (apt version too old, config needs ≥ 0.11) | pacman |
| lazygit, gping, yazi | apt if available, else latest GitHub release → `~/.local/bin` | pacman |

To add a tool: put it in **both** package lists (names can differ, e.g. `fd-find` vs `fd`).

## Aliases

Loaded by `~/.config/shell/init.sh` in this order — later files win:

```
shell/.config/shell/
├── init.sh            # entry point, sourced from .bashrc/.zshrc
├── aliases.sh         # 1. every machine
├── os/debian.sh       # 2. per OS   (from /etc/os-release ID / ID_LIKE)
├── os/arch.sh
├── host/carl-pi.sh    # 3. per host (file name = `uname -n`)
└── local.sh           # 4. private, untracked, this machine only
```

- New alias for everywhere → `aliases.sh`
- Only on one machine → `host/<hostname>.sh`
- Secret or private (tokens, work paths) → `~/.config/shell/local.sh` (git-ignored)

## How linking works

`stow --no-folding` creates symlinks from `$HOME` into this repo, e.g.
`~/.config/shell/aliases.sh → ~/dotfiles/shell/.config/shell/aliases.sh`.
Edit either path — it's the same file. Then `git commit && git push`, and `git pull` on the other machines.

## Cheatsheets

Markdown files in `cheatsheets/`, opened read-only in nvim by the `cheat` function (`aliases.sh`):

| Command | Does |
|---|---|
| `cheat` | pick a sheet with fzf, preview on the right |
| `cheat docker` / `cheat dock` | open a sheet — a unique prefix is enough, `Tab` completes |
| `cheat -g scrub` | search all sheets |
| `cheat -e name` | edit a sheet, or create a new one |
| `cheat -l` | list sheets |

Sheets: `btrfs` · `docker` · `git` · `lazygit` · `nvim` · `search` (fzf, rg, fd, bat) · `tmux` · `vim` · `yazi`
