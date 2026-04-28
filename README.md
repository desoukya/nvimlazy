# Neovim Config

Personal Neovim configuration (lazy.nvim-based).

## Prerequisites (Homebrew)

Install the external tools this config expects to exist on your system:

```sh
brew install glow ripgrep fd node python
```

Optional (only if you use C# / OmniSharp):

```sh
brew install dotnet
```

Notes:

1. `ripgrep` is used by Telescope live grep.
2. `fd` improves Telescope file finding.
3. `node` is used by multiple LSP/format/lint tools (via Mason), and by some JS/TS language servers.
4. `python` is used by Python formatters/linters (via Mason).
5. `glow` powers Markdown preview.

## Markdown Preview

In a Markdown buffer:

1. Press `<leader>md` to open preview (`:Glow`).
2. Press `q` or `<Esc>` to close the preview.

## Key Mappings

Leader key is `,`.

### Core

| Mode | Key | Action |
| --- | --- | --- |
| i | `jk` | Exit insert mode |
| n | `<leader>nh` | Clear search highlight |
| n | `<leader>s` | Save file |
| n | `<leader>wq` | Save and quit |
| n | `<leader>q` | Quit (force) |
| n | `<leader>qa` | Quit all (force) |
| n | `<leader>wa` | Save and quit all (force) |
| n | `<leader>e` | Reload current file |
| n | `<leader>nb` | New scratch buffer (no file) |
| n | `<leader>fe` | Enable folding |
| n | `<leader>fd` | Disable folding |
| n | `<leader>+` | Increment number |
| n | `<leader>-` | Decrement number |
| n | `<leader>sv` | Split window vertical |
| n | `<leader>sh` | Split window horizontal |
| n | `<leader>se` | Equalize splits |
| n | `<leader>sx` | Close split |
| n | `<leader>to` | New tab |
| n | `<leader>tx` | Close tab |
| n | `<leader>tn` | Next tab |
| n | `<leader>tp` | Previous tab |

### Clipboard / Registers

These are intentional so deletes don’t overwrite what you yanked (especially with `clipboard=unnamedplus`).

| Mode | Key | Action |
| --- | --- | --- |
| n | `x` | Delete char to black-hole register |
| n | `X` | Delete char backward to black-hole register |
| n/x | `d` | Delete to black-hole register |
| n/x | `c` | Change to black-hole register |
| x | `p` | Paste over selection without clobbering yank |
| x | `P` | Same as `p` |

### File Tree (nvim-tree)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>b` | Toggle file tree |
| n | `<leader>ef` | Toggle tree on current file |
| n | `<leader>ec` | Collapse tree |
| n | `<leader>er` | Refresh tree |

### Telescope

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>ff` | Find files |
| n | `<leader>fr` | Recent files |
| n | `<leader>fs` | Live grep |
| n | `<leader>fc` | Grep string under cursor |
| n | `<leader>ft` | TODOs (Telescope) |
| n | `<leader>gc` | Git commits |
| n | `<leader>gfc` | Git commits (current file) |
| n | `<leader>gbr` | Git branches |
| n | `<leader>hm` | Harpoon marks (Telescope) |

### Git

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>gs` | Open LazyGit |
| n | `<leader>gb` | Toggle git blame |
| n | `]h` | Next hunk |
| n | `[h` | Prev hunk |
| n | `<leader>hs` | Stage hunk |
| v | `<leader>hs` | Stage selected hunk |
| n | `<leader>hr` | Reset hunk |
| v | `<leader>hr` | Reset selected hunk |
| n | `<leader>hS` | Stage buffer |
| n | `<leader>hR` | Reset buffer |
| n | `<leader>hu` | Undo stage hunk |
| n | `<leader>hp` | Preview hunk |
| n | `<leader>hb` | Blame line (full) |
| n | `<leader>hB` | Toggle line blame |
| n | `<leader>hd` | Diff this |
| n | `<leader>hD` | Diff this `~` |
| o/x | `ih` | Select hunk text object |

### LSP (buffer-local on attach)

| Mode | Key | Action |
| --- | --- | --- |
| n | `K` | Hover docs |
| n | `gf` | LSP finder (def/refs) fallback to Vim `gf` |
| n | `ge` | Go to declaration |
| n | `gd` | Go to definition |
| n | `gc` | Incoming calls |
| n | `gj` | Previous diagnostic |
| n | `gk` | Next diagnostic |
| n | `<leader>ga` | Code actions |
| n | `<leader>rn` | Rename symbol |
| n | `<leader>D` | Buffer diagnostics (Telescope) |
| n | `<leader>d` | Line diagnostics float |
| n | `<leader>rs` | Restart LSP |

### Formatting / Linting

| Mode | Key | Action |
| --- | --- | --- |
| n/v | `<leader>fp` | Format (conform.nvim) |
| n | `<leader>fl` | Lint current file (nvim-lint) |

### Trouble

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>xx` | Toggle trouble list |
| n | `<leader>xw` | Workspace diagnostics |
| n | `<leader>xd` | Document diagnostics |
| n | `<leader>xq` | Quickfix list |
| n | `<leader>xl` | Location list |
| n | `<leader>xt` | TODOs (Trouble) |

### Substitute (gbprod/substitute.nvim)

| Mode | Key | Action |
| --- | --- | --- |
| n | `s` | Substitute with motion |
| n | `ss` | Substitute line |
| n | `S` | Substitute to end of line |
| x | `s` | Substitute selection |

### TODO Comments

| Mode | Key | Action |
| --- | --- | --- |
| n | `]t` | Next todo comment |
| n | `[t` | Previous todo comment |

### Sessions (auto-session)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>ws` | Save session |
| n | `<leader>wr` | Restore session |

### Markdown

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>md` | Markdown preview (Glow) |

### Misc

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>l` | Open Lazy plugin manager |
| v | `<leader>sl` | Sort selected lines |
| n | `<leader>si` | Typescript organize imports |
