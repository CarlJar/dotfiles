# search cheatsheet — fzf · rg · fd · bat

| Tool | Finds | Debian name |
|---|---|---|
| `fd` | file **names** | `fdfind` (alias `fd` in `os/debian.sh`) |
| `rg` (ripgrep) | file **contents** | `rg` (alias adds `--smart-case`) |
| `fzf` | fuzzy-pick from **any list** | `fzf` |
| `bat` | `cat` with colours + line numbers | `batcat` (alias `bat`) |

`fd` and `rg` skip hidden files and everything in `.gitignore` by default — that's why they're fast. Turn it off when you need it (`-H`, `-u`).

## 1. fzf shell keys (enabled in `init.sh`)

| Key | Does |
|---|---|
| `Ctrl-r` | search **command history**, `Enter` puts it on the prompt |
| `Ctrl-t` | pick file(s), pastes the path at the cursor (e.g. `nvim ` then `Ctrl-t`) |
| `Alt-c` | pick a folder and `cd` into it |
| `**` + `Tab` | fuzzy completion: `nvim **<Tab>`, `cd **<Tab>`, `ssh **<Tab>`, `kill -9 **<Tab>` |

Inside fzf: `Ctrl-j`/`Ctrl-k` (or arrows) move · `Tab` mark several (where allowed) · `Enter` accept · `Esc` cancel.

**Query syntax** (space = AND):

| Type | Matches |
|---|---|
| `conf` | fuzzy: c…o…n…f |
| `'conf` | exact substring |
| `^src` / `.md$` | starts / ends with |
| `!test` | does **not** contain |
| `py$ !test` | Python files, no tests |

## 2. fd — find files by name

| Command | Does |
|---|---|
| `fd compose` | names containing `compose`, below here |
| `fd compose /srv/data` | below a given folder |
| `fd -e md` | by extension |
| `fd -t d appdata` | only directories (`-t f` files, `-t l` symlinks) |
| `fd -H bashrc ~` | include hidden files |
| `fd -u name` | include hidden **and** ignored files (everything) |
| `fd -d 2 yaml` | max depth 2 |
| `fd --changed-within 1d` | changed in the last day |
| `fd -e log -x rm {}` | run a command on every result (`{}` = path) ⚠ check without `-x` first |

The pattern is a regex: `fd '^compose\.ya?ml$'`. Use `-g` for shell globs: `fd -g '*.yaml'`.

## 3. rg — search inside files

| Command | Does |
|---|---|
| `rg port` | lines containing `port`, below here (case-insensitive unless you type capitals) |
| `rg port /srv/data/appdata` | in a folder |
| `rg -w port` | whole word only |
| `rg -F 'a.b(c)'` | literal text, no regex |
| `rg -l port` | only file names |
| `rg -C 3 error` | 3 lines of context around matches (`-A` after, `-B` before) |
| `rg -t py import` | only Python files (`rg --type-list` for all types) |
| `rg -g '*.yaml' image` | only files matching a glob (`-g '!*.lock'` excludes) |
| `rg --hidden port` | include dotfiles (`-uu` = hidden + ignored) |
| `rg -c TODO` | count per file |
| `rg 'def \w+\('` | regex |

Replace across files (preview with `rg`, then do it with sed):
```bash
rg -l old_name                         # which files
rg -l old_name | xargs sed -i 's/old_name/new_name/g'
```

## 4. bat

| Command | Does |
|---|---|
| `bat file` | view with syntax colours, line numbers, git changes in the margin |
| `bat -p file` | plain: no line numbers / header (good for copying) |
| `bat -r 20:40 file` | only lines 20–40 |
| `bat -l yaml` | force a language — needed when piping, e.g. after `docker compose config` |
| `bat -A file` | show tabs, spaces, line endings |

## 5. Combining them

```bash
nvim "$(fzf)"                                          # pick a file, open it
fzf --preview 'bat --color=always {}'                  # with preview (Debian: batcat)
fd -e md | fzf -m | xargs bat                          # pick several Markdown files, view them
rg -l TODO | fzf --preview 'rg --color=always TODO {}' # files with TODOs, preview the hits
ps aux | fzf                                           # find a process
git branch --format='%(refname:short)' | fzf | xargs git switch   # pick a branch
```
