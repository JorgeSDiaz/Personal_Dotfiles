# CLAUDE.md — nvim/

Stows into `~/.config/nvim/`. Neovim running on **LazyVim**.

## Architecture

`init.lua` just `require`s `config.lazy`. Everything else lives under `lua/` (`config/` for options/keymaps/autocmds/lazy bootstrap, `plugins/` for per-plugin override specs auto-imported by lazy.nvim).

LazyVim extras come from **two sources**:

- `lua/config/lazy.lua` declares: `lang.go`, `lang.python`, `lang.typescript`, `lang.docker`.
- `lazyvim.json` adds: `lang.astro`, `lang.json`, `lang.markdown`, `coding.yanky`, `editor.inc-rename`, `util.dot`, `util.mini-hipatterns`.

LazyVim's health check compares both lists — keep them consistent when adding a language stack.

## Adding/modifying plugins

- Add a new file under `lua/plugins/` returning a spec.
- To change a LazyVim default plugin, override it by name in `lua/plugins/` (see `colorscheme.lua` overriding `LazyVim/LazyVim`'s `colorscheme`).
- To add a language stack, update **both** `lua/config/lazy.lua` and `lazyvim.json`'s `extras` list (see note above).

## Theme

Catppuccin Mocha is set up in `lua/plugins/colorscheme.lua` with LazyVim integrations enabled. Not matugen-driven — this is the one place in the dotfiles tree that intentionally stays on static Catppuccin, matching tmux and starship.

## Version management

`.neoconf.json` exists; `stylua.toml` configures the Lua formatter. `mise` (installed globally) is expected for toolchain versions.

## Startup cost

`defaults.lazy = false` in `config/lazy.lua` means *user* plugins in `lua/plugins/` load eagerly at startup — LazyVim's own plugins still lazy-load. Keep new overrides small or they will slow startup.
