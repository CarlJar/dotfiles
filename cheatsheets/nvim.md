# nvim cheatsheet (config: CarlJar/nvim_cj)

Leader = **Space**. Press `Space` and wait → **which-key** shows every leader mapping.
Notation: `<C-x>` = Ctrl-x, `<S-Tab>` = Shift-Tab, `n` = normal mode, `i` = insert mode, `v` = visual mode.

## 1. Modes & files

| Key | Does |
|---|---|
| `i` / `a` | insert before / after cursor |
| `I` / `A` | insert at line start / end |
| `o` / `O` | new line below / above + insert |
| `v` / `V` / `<C-v>` | visual: chars / lines / block |
| `Esc` | back to normal mode (also clears search highlight) |
| `:w` / `:q` / `:wq` / `:q!` | save / quit / both / quit without saving |

## 2. Moving

| Key | Does |
|---|---|
| `h j k l` | left, down, up, right |
| `w` / `b` / `e` | next word / previous word / word end |
| `0` / `^` / `$` | line start / first char / line end |
| `gg` / `G` / `42G` | top / bottom / line 42 |
| `<C-d>` / `<C-u>` | half page down / up |
| `%` | jump to matching bracket |
| `f x` / `t x` | to / before next `x` in line, `;` repeats |
| `*` | search word under cursor |
| `/text` / `n` / `N` | search / next / previous |

Relative line numbers are on: `5j` jumps to the line labelled 5 below.

## 3. Editing

| Key | Does |
|---|---|
| `x` | delete char |
| `dd` / `yy` / `p` / `P` | delete line / copy line / paste after / before |
| `dw` / `cw` / `ciw` | delete word / change word / change whole word under cursor |
| `ci"` / `ci(` | change inside quotes / brackets |
| `u` / `<C-r>` | undo / redo |
| `.` | repeat last change |
| `>>` / `<<` | indent / outdent (4 spaces) |
| `gcc` / `gc` (v) | comment line / selection (built-in) |
| `:%s/old/new/g` | replace in whole file |

Clipboard is shared with the system (`unnamedplus`): `y` copies, `p` pastes from other apps.

## 4. Completion — nvim-cmp (insert mode)

| Key | Does |
|---|---|
| (just type) | menu opens automatically from LSP, snippets, buffer words, paths |
| `<C-Space>` | open menu manually |
| `<Tab>` / `<S-Tab>` | next / previous entry |
| `<CR>` | accept |
| `<C-e>` | close menu |

## 5. Code — LSP (pyright) & formatting (conform + ruff)

| Key | Does |
|---|---|
| `K` | docs / signature of thing under cursor |
| `grn` | rename symbol everywhere |
| `gra` | code actions (quick fixes) |
| `grr` | find references |
| `gri` | go to implementation |
| `<C-]>` | go to definition, `<C-o>` jumps back |
| `gO` | outline: symbols of the file |
| `[d` / `]d` | previous / next diagnostic |
| `<C-w>d` | show diagnostic under cursor |
| `<C-s>` (i) | signature help while typing arguments |
| `<leader>f` | format file (also happens automatically on save) |

## 6. Writing — spell check, Markdown, tables

Spell check (de + en_us) is **on automatically** in markdown, text, tex and git commits.

| Key | Does |
|---|---|
| `<leader>us` | toggle spell check |
| `]s` / `[s` | next / previous spelling error |
| `z=` | suggestions for word under cursor |
| `zg` | add word to dictionary |
| `zw` | mark word as wrong |
| `:Markview toggle` | rendered Markdown on / off (markview) |
| `<leader>tm` | toggle table mode |

**Table mode:** start a line with `|`, type cells separated by `|` — columns align themselves.
On the line below the header type `||` → separator line `|---|---|` is created.

## 7. Git — gitsigns

Changed lines are marked in the sign column (left). No extra keymaps, use commands:

| Command | Does |
|---|---|
| `:Gitsigns preview_hunk` | show the change at the cursor |
| `:Gitsigns reset_hunk` | undo that change |
| `:Gitsigns blame_line` | who changed this line |
| `:Gitsigns toggle_current_line_blame` | blame always shown |

## 8. Windows & buffers

| Key | Does |
|---|---|
| `:vs file` / `:sp file` | split right / below (config opens splits right / below) |
| `<C-w>h/j/k/l` | move between splits |
| `<C-w>q` | close split |
| `:e file` | open file |
| `[b` / `]b` | previous / next buffer |

## 9. Maintenance

| Command | Does |
|---|---|
| `:Lazy` | plugin manager (`U` update, `S` sync, `q` close) |
| `:Mason` | installed LSP servers / formatters |
| `:ConformInfo` | which formatter runs for this file |
| `:checkhealth` | diagnose problems |
| `:checkhealth vim.lsp` | is pyright attached? |
