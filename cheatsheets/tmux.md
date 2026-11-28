# tmux cheatsheet

tmux keeps terminals alive on the machine it runs on. SSH to the Pi, start tmux, run something long,
**detach**, close the laptop → it keeps running. Later SSH back in and **attach**.

Structure: **session** (a workspace) → **windows** (like tabs) → **panes** (splits inside a window).

Prefix = **`Ctrl-b`**: press it, let go, then press the key. Below `C-b x` means: `Ctrl-b`, then `x`.
List of all keys: `C-b ?` (`q` to close). No `~/.tmux.conf` yet → these are the defaults.

## 1. Sessions (from the normal shell)

| Command | Does |
|---|---|
| `tmux` | new session (named `0`, `1`, …) |
| `tmux new -s work` | new session named `work` |
| `tmux ls` | list sessions |
| `tmux a` | attach to the last session |
| `tmux a -t work` | attach to `work` |
| `tmux new -A -s main` | attach to `main`, create it if it doesn't exist — the one to remember |
| `tmux kill-session -t work` | end a session |

## 2. Sessions (inside tmux)

| Key | Does |
|---|---|
| `C-b d` | **detach** — leave, everything keeps running |
| `C-b s` | pick a session from a list (tree view, `Enter` to switch) |
| `C-b $` | rename session |
| `C-b (` / `C-b )` | previous / next session |

## 3. Windows (tabs)

| Key | Does |
|---|---|
| `C-b c` | new window |
| `C-b ,` | rename window (shown in the status bar) |
| `C-b n` / `C-b p` | next / previous window |
| `C-b 0` … `C-b 9` | go to window N |
| `C-b w` | list all windows of all sessions |
| `C-b &` | close window (asks) |
| `exit` or `Ctrl-d` | close the shell → closes the pane / window |

## 4. Panes (splits)

| Key | Does |
|---|---|
| `C-b %` | split side by side (left + right) |
| `C-b "` | split stacked (top + bottom) |
| `C-b ←↑↓→` | move to pane in that direction |
| `C-b o` | next pane |
| `C-b z` | **zoom**: pane fullscreen and back |
| `C-b x` | close pane (asks) |
| `C-b C-←↑↓→` | resize (hold `Ctrl`, tap arrows) |
| `C-b Space` | cycle through layouts |
| `C-b {` / `C-b }` | swap pane with previous / next |
| `C-b !` | move pane into its own window |
| `C-b q` | show pane numbers (press a number to jump) |

## 5. Scrolling & copying (copy mode)

Your `$EDITOR` is nvim → tmux uses **vi keys** in copy mode.

| Key | Does |
|---|---|
| `C-b [` | enter copy mode (also: `C-b PgUp`) |
| `k` `j` / `Ctrl-u` `Ctrl-d` | scroll line / half page |
| `/` / `?` then `n` | search down / up, next match |
| `Space` … move … `Enter` | start selection, copy it, leave |
| `C-b ]` | paste what you copied (tmux buffer) |
| `q` | leave copy mode |

## 6. Other

| Key | Does |
|---|---|
| `C-b :` | tmux command prompt, e.g. `:set -g mouse on` (mouse: click panes, scroll, resize) |
| `C-b t` | big clock |
| `tmux source ~/.tmux.conf` | reload config (once you have one) |

## Typical use on the Pi

```bash
pi-home                   # ssh from the laptop
tmux new -A -s main       # attach or create
sudo btrfs scrub start -B /srv/data    # something long
# C-b d  → detach, close the laptop
# later: pi-home, tmux a  → still there
```

**Nested tmux** (tmux on the laptop and on the Pi): `C-b` goes to the outer one, `C-b C-b x` sends `x` to the inner one.
