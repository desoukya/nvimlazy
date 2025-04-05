### Make build issue

- It maybe necessary to remove a package directory and rebuild it using make. To remove:

```
~/.local/share/nvim/lazy/{name_of_package}
```

- For example:

```
~/.local/share/nvim/lazy/telescope-fzf-native.nvim
```

#### Avante

- Install rust to avoid missing templates error: https://github.com/yetone/avante.nvim/issues/544
- arch -arm64 brew install rust
