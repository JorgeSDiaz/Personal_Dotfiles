# DotFiles

Personal dotfiles for zsh, tmux, starship, ghostty, and neovim — managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configured Tools

| Config | Description |
|--------|-------------|
| `zsh` | Shell with plugins, aliases, fzf, and tool integrations |
| `tmux` | Terminal multiplexer with Catppuccin theme and session persistence |
| `starship` | Cross-shell prompt with Catppuccin Mocha palette |
| `ghostty` | Terminal emulator (Linux/macOS) |
| `nvim` | Neovim with LazyVim (Go, Python, TypeScript, Docker) and Catppuccin theme |

## Installation

### 1. Clone the repo

```bash
git clone git@github.com:JorgeSDiaz/Personal_Dotfiles.git ~/DotFiles
cd ~/DotFiles
```

### 2. Install dependencies

#### Arch Linux

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

# Optional: clipboard support (Wayland)
sudo pacman -S wl-clipboard
```

AUR packages (use your preferred AUR helper, e.g. `yay`):

```bash
yay -S lazydocker ghostty
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

#### macOS

```bash
# Homebrew required: https://brew.sh
brew install zsh tmux git stow starship fzf zoxide lsd neovim bat lazygit btop lazydocker

# Zsh plugins
brew install zsh-autosuggestions zsh-syntax-highlighting
```

> **Note:** On non-Arch systems the zsh plugin paths differ from `/usr/share/zsh/plugins/...`. Update the paths in `.zshrc` to match your install location (e.g. `~/.zsh/` for manual clones, `/opt/homebrew/share/` for Homebrew).

### 3. Install dev tool version manager (mise)

```bash
# Arch
yay -S mise

# Ubuntu / macOS
curl https://mise.run | sh
```

### 4. Apply dotfiles with Stow

```bash
cd ~/DotFiles
stow zsh tmux starship nvim

# Only if using Ghostty as your terminal
stow ghostty
```

### 5. Set zsh as your default shell

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
