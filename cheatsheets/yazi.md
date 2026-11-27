# yazi cheatsheet

Start with `y` (wrapper: when you quit with `q`, your shell stays in the folder you ended in).
Built-in help with **all** keys of your installed version: `~` or `F1` — the source of truth if something below differs.

Three columns: **parent** | **current** | **preview**

## 1. Moving around

| Key | Does |
|---|---|
| `j` / `k` | down / up |
| `h` / `l` | go to parent / enter folder (or open file) |
| `gg` / `G` | top / bottom of list |
| `Ctrl-d` / `Ctrl-u` | half page down / up |
| `J` / `K` | scroll the **preview** down / up |
| `gh` | go to `~` |
| `gc` | go to `~/.config` |
| `g Space` | type a path and jump there |
| `z` / `Z` | jump with zoxide / fzf (fuzzy) |
| `.` | show / hide hidden files |

## 2. Opening files

| Key | Does |
|---|---|
| `Enter` or `l` | open (text files → `$EDITOR` = nvim) |
| `O` | open with… (choose program) |
| `Tab` | file info (size, type, permissions) |

## 3. Selecting

| Key | Does |
|---|---|
| `Space` | select / unselect file, move down |
| `v` | visual mode — move with `j`/`k` to select a range |
| `Ctrl-a` | select all |
| `Ctrl-r` | invert selection |
| `Esc` | cancel selection / mode |

Everything in 4. works on the **selection**, or on the file under the cursor if nothing is selected.

## 4. File operations

| Key | Does |
|---|---|
| `y` | yank (copy) |
| `x` | cut |
| `p` | paste here |
| `P` | paste here, overwrite existing |
| `Y` / `X` | cancel yank / cut |
| `a` | create — `name` = file, `name/` = folder |
| `r` | rename |
| `d` | move to trash |
| `D` | delete **permanently** |
| `-` / `_` | create symlink (absolute / relative) |
| `w` | task manager (running copies etc.) |

## 5. Finding

| Key | Does |
|---|---|
| `f` | filter the current list as you type |
| `/` / `?` | find next / previous by name in current folder |
| `n` / `N` | next / previous match |
| `s` | search file **names** below here (uses `fd`) |
| `S` | search file **contents** below here (uses `rg`) |

## 6. Sorting & display

| Key | Does |
|---|---|
| `,m` / `,M` | sort by modified time / reversed |
| `,s` / `,S` | sort by size / reversed |
| `,n` / `,a` | sort natural / alphabetical |
| `ms` / `mp` / `mm` / `mn` | show size / permissions / mtime / nothing next to names |

## 7. Copy paths to clipboard

| Key | Does |
|---|---|
| `cc` | full path |
| `cd` | folder path |
| `cf` | file name |
| `cn` | file name without extension |

(over SSH the clipboard only reaches your laptop if the terminal supports OSC 52)

## 8. Tabs & shell

| Key | Does |
|---|---|
| `t` | new tab (in current folder) |
| `1`…`9` | switch to tab N |
| `[` / `]` | previous / next tab |
| `Ctrl-c` | close tab |
| `;` | run a shell command (in background) |
| `:` | run a shell command and wait for it |
| `q` | quit (shell follows to current folder) |
| `Q` | quit, shell stays where it was |

---

## 10-minute practice (on the Pi)

```bash
y /srv/data/files
```

1. `a` → `test/` → Enter — creates folder `test`
2. `l` to enter it, `a` → `hello.txt` — creates a file
3. `Enter` — opens it in nvim, write something, `:wq`
4. `a` → `b.txt`, `a` → `c.txt` — two more files
5. `Ctrl-a` (select all) → `y` (copy) → `h` (back to `files`) → `a` → `copy/` → `l` → `p` — pasted copies
6. `Space` on two files → `d` — to trash
7. `r` on the last file → rename it
8. `h` → cursor on `copy` → `D` → confirm — gone for good
9. `s` → type `hello` — finds the file in `test/`
10. `q` — your shell is now in that folder (check with `pwd`)
