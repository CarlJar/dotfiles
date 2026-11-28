# vim cheatsheet — the language

Works in any vim / nvim / `vi`, without plugins. For your own config, LSP and plugin keys see `cheat nvim`.
Built-in help: `:help <thing>`, e.g. `:help ciw`, `:help text-objects`. `:help` itself starts with a tutorial; `vimtutor` in the shell is 30 minutes well spent.

## 1. The grammar: operator + count + motion

`[count] operator [count] motion` — learn a few of each and they combine:

| Operator | | Motion / text object | |
|---|---|---|---|
| `d` | delete (cut) | `w` `b` `e` | word forward / back / end |
| `c` | change (delete + insert) | `$` `0` `^` | line end / start / first char |
| `y` | yank (copy) | `}` `{` | next / previous paragraph |
| `>` `<` | indent / outdent | `f x` `t x` | to / until char `x` |
| `=` | auto-indent | `/foo` | up to the next `foo` |
| `gu` `gU` `g~` | lower / upper / toggle case | `G` `gg` | to end / start of file |
| `gq` | wrap lines to width | `iw` `aw` … | text objects (section 2) |

Doubling an operator = whole line: `dd`, `cc`, `yy`, `>>`, `guu`.
Examples: `d3w` delete 3 words · `c$` (= `C`) change to line end · `y}` copy paragraph · `gUiw` uppercase word · `dt,` delete up to the comma · `=G` re-indent to end of file.

`.` repeats the last change — design edits so `.` can redo them (e.g. `ciw` + text, then `n` `.` `n` `.`).

## 2. Text objects — `i` = inside, `a` = around (incl. spaces / brackets)

| Object | Means |
|---|---|
| `iw` / `aw` | word |
| `iW` / `aW` | WORD (anything without spaces, e.g. a path) |
| `is` / `ip` | sentence / paragraph |
| `i"` `i'` `` i` `` | inside quotes |
| `i(` `i[` `i{` `i<` | inside brackets (`ib` = `i(`, `iB` = `i{`) |
| `it` / `at` | inside / around an HTML/XML tag |

Work from anywhere inside the object: cursor somewhere in `"hello world"` → `ci"` replaces the whole string.

## 3. Moving faster

| Key | Does |
|---|---|
| `H` `M` `L` | top / middle / bottom of the screen |
| `zz` `zt` `zb` | scroll so the cursor line is centre / top / bottom |
| `Ctrl-e` / `Ctrl-y` | scroll one line, cursor stays |
| `W` `B` `E` | like `w b e` but by WORD (skips punctuation) |
| `;` / `,` | repeat last `f`/`t` forward / backward |
| `Ctrl-o` / `Ctrl-i` | jump back / forward (after `G`, `/`, `gd`, …) |
| `` `. `` | to the last change |
| `gi` | back to where you last inserted, in insert mode |
| `gv` | reselect the last visual selection |

## 4. Insert mode tricks

| Key | Does |
|---|---|
| `Ctrl-w` | delete word before cursor |
| `Ctrl-u` | delete to line start |
| `Ctrl-r "` | paste the yank register (any register: `Ctrl-r a`) |
| `Ctrl-o cmd` | run one normal-mode command, stay in insert (`Ctrl-o zz`) |
| `Ctrl-n` / `Ctrl-p` | complete word from the buffer (without plugins) |

## 5. Registers — named clipboards

| Key | Does |
|---|---|
| `"ayy` | yank line into register `a` |
| `"ap` | paste from register `a` |
| `"Ayy` | **append** to register `a` (capital letter) |
| `"0p` | paste the last **yank** — even after `dd` overwrote the default register |
| `"_d` | delete into the black hole — default register stays untouched |
| `"+y` / `"+p` | system clipboard (your config already uses it by default) |
| `:reg` | show all registers |

## 6. Macros — record once, replay

| Key | Does |
|---|---|
| `qa` | start recording into register `a` |
| `q` | stop |
| `@a` | play `a` |
| `@@` | play the last macro again |
| `10@a` | play 10 times (stops early at an error, e.g. end of file) |
| `:'<,'>norm @a` | play on every selected line |

Tip: start the macro with `0` or `^` and end it with `j` — then it works line after line.

## 7. Marks

| Key | Does |
|---|---|
| `ma` | set mark `a` here (lowercase = this file) |
| `` `a `` / `'a` | jump to mark `a` exact position / its line |
| `mA` | uppercase = global, jumps across files |
| `''` | back to the line before the last jump |
| `:marks` | list |

## 8. Visual block (`Ctrl-v`) — column editing

| Keys | Does |
|---|---|
| `Ctrl-v` `j j j` `I` text `Esc` | insert `text` at the start of every selected line |
| `Ctrl-v` `j j j` `$A` text `Esc` | append `text` at the end of every line |
| `Ctrl-v` select `c` text `Esc` | replace the block on every line |
| `Ctrl-v` select `d` | delete a column |
| `o` (in visual) | jump to the other end of the selection |

## 9. Ex commands (`:`) — ranges

Range before the command: `%` whole file · `.` current line · `10,20` lines 10–20 · `.,+5` this + 5 below · `'<,'>` selection (typed for you after `:` in visual mode).

| Command | Does |
|---|---|
| `:%s/old/new/g` | replace all (`gc` = ask each time, `i` ignore case) |
| `:s/\s\+$//` | remove trailing spaces (line; `%s` for file) |
| `:%s/\<word\>/new/g` | whole word only |
| `:%s//new/g` | empty pattern = reuse the last search (`*` then this) |
| `:g/pattern/d` | delete all lines matching |
| `:v/pattern/d` | delete all lines **not** matching |
| `:g/TODO/norm A !` | run normal-mode keys on matching lines |
| `:'<,'>norm .` | repeat last change on every selected line |
| `:10,20m 0` / `:t.` | move lines 10–20 to the top / duplicate current line |
| `:sort` / `:sort u` | sort lines / and remove duplicates |
| `:%!jq .` | filter the file through a shell command (here: pretty JSON) |
| `:r !date` | insert command output below the cursor |
| `:!cmd` | run a shell command, e.g. `:!ls` (`%` = current file: `:!wc -l %`) |

## 10. Search

| Key | Does |
|---|---|
| `/foo` `?foo` | search down / up, `n` `N` next / previous |
| `*` / `#` | word under cursor down / up |
| `/foo\c` | case-insensitive this once |
| `/\vpattern` | "very magic": regex like in other tools, fewer backslashes |
| `:noh` | clear highlight |

## 11. Files, buffers, misc

| Command | Does |
|---|---|
| `:e!` | reload file, drop unsaved changes |
| `:w newname` / `:sav newname` | write a copy / save as and continue in it |
| `:x` or `ZZ` | save (if changed) and quit · `ZQ` quit without saving |
| `:ls` / `:b name` / `:bd` | list buffers / switch (Tab-completes) / close |
| `gf` | open the file path under the cursor |
| `u` / `Ctrl-r` / `U` | undo / redo / undo all on line |
| `:earlier 10m` / `:later 5m` | undo by time |
| `J` / `gJ` | join line below (with / without space) |
| `~` | toggle case of char |
| `Ctrl-a` / `Ctrl-x` | increment / decrement the number under the cursor (`5 Ctrl-a`) |
| `g Ctrl-a` (visual) | number a list: 1, 2, 3 … |
| `zf` `zo` `zc` `za` | fold create / open / close / toggle |
