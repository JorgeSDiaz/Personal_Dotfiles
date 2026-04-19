# DotFiles

Personal dotfiles for zsh, tmux, starship, ghostty, neovim, and claude-code — managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configured Tools

| Config | Description |
|--------|-------------|
| `zsh` | Shell with plugins, aliases, fzf, and tool integrations |
| `tmux` | Terminal multiplexer with Catppuccin theme and session persistence |
| `starship` | Cross-shell prompt with Catppuccin Mocha palette |
| `ghostty` | Terminal emulator (Linux/macOS) |
| `nvim` | Neovim with LazyVim (Go, Python, TypeScript, Docker) and Catppuccin theme |
| `claude` | Claude Code CLI settings and custom Nerd Font status line |
| `opencode` | OpenCode config, AGENTS.md, plugins, skills, commands, and MCP servers (context7, basic-memory, aws-docs) |
| `hypr` | Hyprland compositor config (dispatcher + `conf.d/` modular, hyprlock, hypridle, hyprpaper) |

## Installation

### 1. Clone the repo

```bash
git clone git@github.com:JorgeSDiaz/Personal_Dotfiles.git ~/DotFiles
cd ~/DotFiles
```

### 2. Install dependencies

#### Arch Linux

```bash
# Hyprland compositor
sudo pacman -S hyprland hyprpaper hypridle hyprlock hyprpolkitagent \
               swaync network-manager-applet playerctl brightnessctl \
               wl-clipboard rofi grim slurp
yay -S grimblast-git matugen-bin vicinae
```

```bash
# Essentials
sudo pacman -S zsh tmux git stow

# Prompt & shell tools
sudo pacman -S starship fzf zoxide

# CLI tools (aliased in .zshrc)
sudo pacman -S lsd neovim bat lazygit btop

# Zsh plugins
sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting

# Font
sudo pacman -S ttf-jetbrains-mono-nerd

```

AUR packages (use your preferred AUR helper, e.g. `yay`):

```bash
yay -S lazydocker ghostty opencode
```

Install `uv` (required for MCP servers in OpenCode):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### Ubuntu / Debian

```bash
# Essentials
sudo apt install zsh tmux git stow

# Tools via Homebrew (recommended for latest versions)
brew install starship fzf zoxide lsd neovim bat lazygit btop

# Zsh plugins (manual clone)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
```

Install `lazydocker` via the install script:

```bash
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

Install `opencode`:

```bash
curl -fsSL https://opencode.ai/install | sh
```

Install `uv` (required for MCP servers in OpenCode):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### macOS

```bash
# Homebrew required: https://brew.sh
brew install zsh tmux git stow starship fzf zoxide lsd neovim bat lazygit btop lazydocker

# Zsh plugins
brew install zsh-autosuggestions zsh-syntax-highlighting
```

Install `opencode`:

```bash
curl -fsSL https://opencode.ai/install | sh
```

Install `uv` (required for MCP servers in OpenCode):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

> **Note:** On non-Arch systems the zsh plugin paths differ from `/usr/share/zsh/plugins/...`. Update the paths in `.zshrc` to match your install location (e.g. `~/.zsh/` for manual clones, `/opt/homebrew/share/` for Homebrew).

### 3. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 4. Install OpenCode

OpenCode is available via AUR on Arch (already covered above). For other systems, use the official install script:

```bash
curl -fsSL https://opencode.ai/install | sh
```

### 5. Install dev tool version manager (mise)

```bash
# Arch
yay -S mise

# Ubuntu / macOS
curl https://mise.run | sh
```

### 6. Apply dotfiles with Stow

```bash
cd ~/DotFiles
stow zsh tmux starship nvim claude opencode hypr

# Only if using Ghostty as your terminal
stow ghostty
```

### 7. Set zsh as your default shell

```bash
chsh -s $(which zsh)
```

## Post-installation

### Tmux Plugin Manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start tmux and press `prefix + I` (capital i) to install all plugins.

### Catppuccin tmux theme

The config expects Catppuccin at `~/.config/tmux/plugins/catppuccin/tmux`. Clone it manually (TPM does not manage this plugin by default):

```bash
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone https://github.com/catppuccin/tmux ~/.config/tmux/plugins/catppuccin/tmux
```

### JetBrainsMono Nerd Font (Ubuntu / macOS)

Download from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) and install the `JetBrainsMono` family, then set it in your terminal.

## Optional tools

Used by the `extract` shell function to decompress various archive formats:

```bash
# Arch
sudo pacman -S unzip p7zip unrar zstd

# Ubuntu
sudo apt install unzip p7zip-full unrar zstd

# macOS
brew install p7zip unar zstd
```

## Local machine overrides

Machine-specific settings can be placed in `~/.config/ghostty/local.ghostty` — this file is gitignored and loaded automatically by Ghostty if it exists.

## Hyprland notes

### Monitor configuration

`conf.d/monitors.conf` is calibrated for a dual-monitor setup (DP-2 + HDMI-A-1 at 1080p). Adjust for your hardware after stow — run `hyprctl monitors` to discover your actual monitor IDs.

### Matugen-generated files

`conf.d/matugen-colors.conf`, `hyprlock-colors.conf`, and `hyprpaper.conf` are overwritten by `matugen` whenever you change wallpaper (`Super+Shift+W`). The versions in this repo are Catppuccin Mocha placeholders that allow Hyprland to start on a fresh machine. Run the wallpaper picker after stow to apply your actual theme.

### External dependencies not yet versioned

The following components are referenced in this config but not yet part of this repo. On a fresh machine: the status bar won't appear, the wallpaper picker keybinding won't work, and hyprpaper won't restore the last wallpaper on login.

- `~/.config/matugen/` — color generation templates and config
- `~/.config/quickshell/mybar/` — Quickshell status bar
- `~/.local/bin/wallpaper-picker.sh` — rofi-based wallpaper selector
- `~/.local/bin/start-hyprpaper.sh` — hyprpaper launcher with last-wallpaper restore
