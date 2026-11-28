# lazygit cheatsheet

Start with `lg` inside a git repo. Built-in help for the **current panel**: `?` — the source of truth if something below differs.
Keys depend on which panel is active, same key = different action in different panels.

Left side, top to bottom: **1** status · **2** files · **3** branches · **4** commits · **5** stash. Right side: preview / diff.

## 1. Getting around

| Key | Does |
|---|---|
| `1` … `5` | jump to panel |
| `h` / `l` (or `←` `→`) | previous / next panel |
| `j` / `k` | move in the list |
| `[` / `]` | switch tab inside a panel (e.g. Local branches / Remotes / Tags) |
| `Enter` | open / drill into the item (file → hunks, commit → its files) |
| `Esc` | back out |
| `/` | filter / search the list |
| `+` / `_` | bigger / smaller layout (diff fullscreen) |
| `?` | keys for this panel |
| `q` | quit |

## 2. Files panel — the everyday loop

| Key | Does |
|---|---|
| `Space` | stage / unstage file |
| `a` | stage / unstage **all** |
| `Enter` | stage single **lines / hunks** (see below) |
| `c` | commit — type message, `Enter` |
| `C` | commit in nvim (for longer messages with body) |
| `A` | amend: add staged changes to the last commit |
| `d` | discard changes of file ⚠ (asks) |
| `s` | stash all changes |
| `e` | edit file in nvim |
| `f` | fetch |
| `p` | pull |
| `P` | push |

**Staging parts of a file** (after `Enter` on a file): `j`/`k` move, `Space` stage line, `v` select a range then `Space`,
`a` toggle line/hunk mode, `Tab` switch between unstaged/staged side, `Esc` back.

## 3. Branches panel

| Key | Does |
|---|---|
| `Space` | checkout branch |
| `n` | new branch from the current one |
| `M` | merge selected branch **into** the current one |
| `r` | rebase current branch **onto** selected |
| `R` | rename |
| `d` | delete (asks) |
| `u` | set upstream |

## 4. Commits panel

| Key | Does |
|---|---|
| `Enter` | show files changed in the commit |
| `r` | reword message (in place; `R` in nvim) |
| `s` | squash into the commit below |
| `f` | fixup: like squash, but drop this message |
| `d` | drop commit (asks) |
| `e` | edit: stop rebase here so you can change it |
| `Ctrl-j` / `Ctrl-k` | move commit down / up |
| `g` | reset to this commit (menu: soft / mixed / hard) |
| `C` / `V` | copy commit (cherry-pick) / paste it on the current branch |
| `t` | revert (new commit undoing this one) |

⚠ Rewriting commits (reword, squash, drop, move) changes history. Fine for commits you **haven't pushed**;
after pushing you'd need a force push — avoid that on shared branches.

## 5. Stash panel

| Key | Does |
|---|---|
| `Space` | apply (stash stays) |
| `g` | pop (apply + remove) |
| `d` | drop |

## 6. Rescue

| Key | Does |
|---|---|
| `z` | **undo** last action (uses the reflog) |
| `Ctrl-z` | redo |
| `@` | command log — the real git commands lazygit ran (good for learning git) |
| `x` | menu of everything possible right here |

## 5-minute practice

```bash
mkdir /tmp/lgtest && cd /tmp/lgtest && git init && echo a > a.txt && git add . && git commit -m init
echo b >> a.txt && echo new > b.txt
lg
```

1. Files panel: `Space` on `b.txt` → staged. `c` → `add b` → `Enter`
2. `Enter` on `a.txt`, `Space` on the `+b` line, `Esc`, `c` → `change a`
3. `4` → commits panel → on `add b` press `r`, change the message
4. on `change a` press `s` → squashed into `add b`
5. `z` → undone. `@` → see what git commands that was
6. `q`, then `rm -rf /tmp/lgtest`
