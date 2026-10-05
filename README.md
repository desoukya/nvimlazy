# Neovim Config

Personal Neovim configuration (lazy.nvim-based).

## Prerequisites (Homebrew)

Install the external tools this config expects to exist on your system:

```sh
brew install glow ripgrep fd node python hurl tree-sitter-cli
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
6. `hurl` powers the HTTP client (`hurl.nvim`).
7. `tree-sitter-cli` is required by nvim-treesitter (`main` branch) to compile parsers. The DB client (`vim-dadbod-ui`) uses whatever DB CLIs you have installed (`psql`, `sqlite3`, `redis-cli`, …).
8. Python debugging (nvim-dap) uses `debugpy` from a dedicated venv:
   `python3 -m venv ~/.virtualenvs/debugpy && ~/.virtualenvs/debugpy/bin/python -m pip install debugpy`.
9. Jupyter notebooks (`ipynb.nvim`) need `jupyter_client` + `ipykernel` in the
   kernel's Python — a project venv, or a dedicated one:
   `python3 -m venv ~/.virtualenvs/jupyter && ~/.virtualenvs/jupyter/bin/python -m pip install jupyter_client ipykernel`.
   Its treesitter parser is compiled by a `build` step via the `tree-sitter` CLI.
10. `MarkdownPreview` (browser/mermaid) builds a Node app on install (`node`/`npm`).

## Markdown Preview

In a Markdown buffer:

- **`<leader>md`** — quick terminal preview (`:Glow`); `q`/`<Esc>` to close.
- **`<leader>mp`** — live preview in the **browser** (markdown-preview.nvim), which
  renders **mermaid** diagrams. Put the diagram in a ` ```mermaid ` fenced block;
  the preview updates as you edit. Toggle off with `<leader>mp` or `:MarkdownPreviewStop`.

(render-markdown.nvim is intentionally disabled — it backgrounds code blocks via
`ColorColumn`, which showed as a black block over transparent buffers.)

## Mouse Selection (tmux + iTerm2)

Running Neovim inside tmux with `set -g mouse on`, a plain click-drag is
captured by tmux/Neovim, so it can't select text for the system clipboard.

To copy text with the mouse, **hold `⌥ Option` and drag** in iTerm2. This does a
native terminal selection (bypassing tmux and Neovim mouse capture) and, since
iTerm2's "copy on select" is on by default, it lands straight in the macOS
clipboard — no `⌘C` needed. Use `⌥⌘` + drag for a rectangular selection to skip
the line-number gutter.

Keeping tmux `mouse on` preserves scroll and click-to-position inside Neovim.

## HTTP Requests (hurl.nvim)

Write requests in a `.hurl` file and run them; responses open in a split
(`<leader>rt` toggles split/popup).

1. Create a `*.hurl` file (e.g. `GET https://httpbin.org/get`).
2. `<leader>ra` runs the request under the cursor; `<leader>rA` runs all requests
   in the file (this is what chains captures like a login token); select lines +
   `<leader>rr` runs just those.
3. `<leader>rp` opens a Telescope picker of the file's requests (labeled by their
   preceding `# comment`) — pick one to jump to it and run it.
4. `<leader>rl` reopens the last response; `<leader>rz` reports its byte size.

**Reading RTL/Arabic responses:** Neovim (and the terminal) can't reorder
bidirectional text, so Arabic renders reversed in the response buffer. The bytes
are correct — assert on them in the `.hurl` file, or press `<leader>ro` to open
the last response in the browser, which renders bidi correctly.

**Environments:** keep per-env files next to (or above) your `.hurl` files, e.g.
`kawader-stg.env` and `scale-backend-local.env`, each defining the same variable
names (`baseUrl`, `proxy`, credentials, …). Reference them in requests as
`{{baseUrl}}` etc. Switch with `<leader>re` — a Telescope picker of every `*.env`
found from the file's directory up to the git (or filesystem) root.

**Captured variables** (e.g. a token from `[Captures]`) are saved as globals for
the session; view/edit them with `<leader>rv`, or set one with `<leader>rs`.

## Database (vim-dadbod-ui)

A lightweight, buffer-based DB client.

1. `<leader>db` toggles the DB UI drawer.
2. First time, `:DBUIAddConnection` and paste a connection URL — it **must** have
   a scheme, e.g. `postgres://user:pass@localhost:5432/mydb` or
   `sqlite:///abs/path.db`. It's saved for next time.
3. Open a table or a `New query` buffer, write SQL, then:
   - `<leader>S` runs the whole buffer; `<leader>rq` runs only the query under the
     cursor (its current blank-line-delimited paragraph); `:w` also runs the buffer.

SQL autocomplete flows through nvim-cmp. Note each run is a fresh session, so a
`SET`/`current_setting` pair must be sent together (run the whole buffer, or keep
the `SET` in the same paragraph as the query).

**Saved queries** live per-connection under `~/.local/share/db_ui/<connection-name>/`:

- Save the current query buffer with `<Leader>W` — it prompts for a name and then
  appears under that connection's **Saved queries** (and persists across sessions).
- Or drop an existing `.sql` file into that folder (`mkdir -p` it if needed; the
  subfolder name must match the connection's name), then press `R` in the drawer
  to refresh.
- Open one from **Saved queries** with `<CR>`, then run it with `<leader>S` / `<leader>rq`.

## Debugging (nvim-dap)

nvim-dap + dap-ui + dap-virtual-text (values shown inline) + dap-python. See the
`debugpy` venv note in Prerequisites.

1. Put the cursor on a line and press `<F9>` (or `<leader>B`) to set a breakpoint.
2. `<F5>` starts/continues — pick a config (e.g. "Launch file"). The UI opens
   automatically; step with `<F10>`/`<F11>`/`<F12>`, inspect with `<leader>E`.
3. **Debug a running server** (e.g. FastAPI): start it under debugpy, then `<F5>`
   → pick the **attach** config to connect. Breakpoints fire when you hit the
   endpoint. A ready-made "Attach to Kawader AI (:5678)" config lives in `dap.lua`.
4. **Debug a test:** cursor in a test, `<leader>T` (method) / `<leader>C` (class).

## JWT

`:JwtDecode` (or `<leader>jd`) decodes the JWT under the cursor — header, payload,
and `iat`/`nbf`/`exp` as readable local time with an `(EXPIRED)` flag. Works on a
bare token or one embedded in `key=…`, quotes, or a `Bearer …` header;
`:JwtDecode <token>` decodes a pasted one.

## Jupyter Notebooks (ipynb.nvim)

Open a `.ipynb` file and it renders as a notebook — bordered cell blocks, `[N]`
execution counts, and markdown/code/raw cells, with outputs inline.

1. `<leader>ks` (or `:NotebookKernelStart`) starts a kernel. It auto-detects a
   project venv (`.venv`/`venv` walking up), else system Python — or pass one:
   `:NotebookKernelStart ~/.virtualenvs/jupyter/bin/python`. That Python needs
   `jupyter_client` + `ipykernel`.
2. Run a cell with `<leader>kx` (execute & move to next) or `<leader>kX` (execute,
   stay); text output shows inline, `<leader>ko` opens full output in a float.

Notes:
- **Alpha** plugin — expect rough edges.
- **Inline plots/images** need a Kitty-protocol terminal (kitty/Ghostty) +
  `snacks.nvim` (commented in `ipynb.lua`). On iTerm2 they show
  `[Image failed to load]`; cell blocks and text outputs work fine.
- Its `ipynb` treesitter parser is compiled by a lazy `build` step (the plugin's
  own auto-install targets the old nvim-treesitter API, which `main` dropped).

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
| n | `zf` | Close all folds (file) |
| n | `zF` | Open all folds (file) |
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
| n | `<leader>fc` | Live grep word under cursor (seeded, refinable) |
| x | `<leader>fc` | Live grep the visual selection |
| n | `<leader>ft` | TODOs (Telescope) |
| n | `<leader>gc` | Git commits |
| n | `<leader>gfc` | Git commits (current file) |
| n | `<leader>gbr` | Git branches |
| n | `<leader>gd` | Changed files (git status) with diff preview |
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
| n | `<leader>ht` | Toggle line highlight (red/green diff) |
| n | `<leader>hw` | Toggle word diff (intra-line) |
| n | `<leader>hx` | Toggle deleted lines (inline) |
| n | `<leader>hv` | Toggle review view (line + word diff + deleted) |
| n | `<leader>hb` | Blame line (full) |
| n | `<leader>hB` | Toggle line blame |
| n | `<leader>hd` | Diff this — split before/after vs index (`:q` to close, `]c`/`[c` to jump) |
| n | `<leader>hD` | Diff this vs previous revision (`HEAD~`) |
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
| n | `<leader>md` | Markdown preview (Glow, terminal) |
| n | `<leader>mp` | Markdown preview (browser, mermaid) |

### HTTP Requests (hurl.nvim, in `.hurl` files)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>ra` | Run request at cursor |
| n | `<leader>rA` | Run all requests in file |
| v | `<leader>rr` | Run selected requests |
| n | `<leader>rp` | Pick & run a request (Telescope) |
| n | `<leader>re` | Select env file (Telescope) |
| n | `<leader>rl` | Show last response |
| n | `<leader>ro` | Open last response in browser (bidi/Arabic) |
| n | `<leader>rz` | Show last response size |
| n | `<leader>rt` | Toggle split/popup view |
| n | `<leader>rv` | Manage variables (view/edit/delete) |
| n | `<leader>rs` | Set a variable (type: `name value`) |

### Database (vim-dadbod-ui)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>db` | Toggle DB UI drawer |
| n/v | `<leader>S` | Execute query (whole buffer / selection) |
| n | `<leader>rq` | Run query under cursor (in a DB query buffer) |
| n | `<leader>W` | Save current query (→ Saved queries) |

### Debugging (nvim-dap)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<F5>` | Start / continue |
| n | `<F9>` / `<leader>B` | Toggle breakpoint |
| n | `<F10>` / `<F11>` / `<F12>` | Step over / into / out |
| n | `<F6>` | Toggle DAP UI |
| n/v | `<leader>E` | Evaluate expression |
| n | `<leader>T` | Debug nearest test (Python) |
| n | `<leader>C` | Debug test class (Python) |
| n | `<leader>Q` | Terminate session |

### Jupyter Notebooks (ipynb.nvim, in `.ipynb` files)

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>ks` | Start kernel (`<leader>ki` interrupt · `<leader>k0` restart · `<leader>kS` shutdown · `<leader>kn` info) |
| n | `<leader>kx` | Execute cell & move to next |
| n | `<leader>kX` | Execute cell (stay) |
| n | `<leader>ko` | Open output in float |
| n | `<leader>kc` / `<leader>kC` | Clear cell / all outputs |
| n | `<leader>kj` | Jump to cell (picker) |
| n | `<leader>ka` / `<leader>kb` | Add cell above / below |
| n | `<leader>ky` / `<leader>km` / `<leader>kr` | Make cell code / markdown / raw |
| n | `<leader>kf` | Toggle cell fold |
| n | `<leader>kh` / `<leader>kv` | Inspect variable at cursor / all cell variables |

### Misc

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>l` | Open Lazy plugin manager |
| v | `<leader>sl` | Sort selected lines |
| n | `<leader>si` | Typescript organize imports |
| n | `<leader>jd` | Decode JWT under cursor (`:JwtDecode`) |
| n | `<leader>rw` | Replace all of word under cursor, file-wide (prompts for new word) |
