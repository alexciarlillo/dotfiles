# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a personal dotfiles repository using GNU Stow for symlink management. The architecture is organized into platform-specific and universal configurations:

- `universal/` - Cross-platform configuration files (shell, git, editors, terminal)
- `osx/` - macOS-specific configurations (AeroSpace, Hammerspoon, Sublime Text)  
- `linux/` - Linux-specific configurations (i3, polybar, compton, X11)
- `extra/` - Additional resources (Homebrew packages, iTerm themes)

## Setup Commands

Install dotfiles on macOS:
```bash
make osx
```

Install dotfiles on Linux:
```bash
make linux
```

Install Homebrew packages:
```bash
make homebrew
```

The Makefile uses GNU Stow with the following pattern:
- `DOTFILES` environment variable points to `${HOME}/.dotfiles`
- Stow restows files ignoring `.DS_Store` files
- Universal dotfiles are installed for both platforms

## Key Configuration Structure

### Terminal & Shell Setup
- **WezTerm**: `universal/.wezterm.lua` - Modern terminal with custom keybindings
- **Zsh**: `universal/.zshrc` with aliases in `universal/.aliases`
- **Tmux**: `universal/.tmux.conf` and `universal/.tmux.conf.user`

### Editor Configuration  
- **Neovim**: Complete LazyVim setup in `universal/.config/nvim/`
  - Main config: `init.lua`
  - Plugin configs: `lua/plugins/` directory
  - Custom keymaps, options, and autocommands in `lua/config/`
- **Vim**: Basic configuration in `universal/.vimrc`

### macOS Window Management
- **AeroSpace**: `osx/.aerospace.toml` - Tiling window manager with extensive workspace keybindings
- **Hammerspoon**: `osx/.hammerspoon/init.lua` - Window manipulation and automation

### Development Tools
- **Git**: `universal/.gitconfig` and `universal/.gitignore_global`
- **Ripgrep**: `universal/.ripgreprc` for search configuration

## Stow Management

Each platform directory contains a `.stow-local-ignore` file defining which files Stow should ignore during symlinking. This allows for selective file management within the same directory structure.

## Key Tool Integrations

The setup integrates several modern CLI and GUI tools:
- **ripgrep** for fast file search
- **fd** for fast file finding  
- **lsd** for enhanced directory listings
- **tmux** for terminal multiplexing
- **stow** for dotfile management
- **AeroSpace** for macOS window tiling
- **WezTerm** as primary terminal emulator

## Neovim Plugin Architecture

The Neovim setup uses LazyVim as a base with custom plugin configurations:
- Language servers configured in `lua/plugins/lsp.lua`
- GitHub integration via `lua/plugins/github.lua`
- Custom completion setup in `lua/plugins/completion.lua`
- UI enhancements and colorscheme management
- Copilot integration for AI assistance

## Platform-Specific Notes

**macOS**: Focuses on GUI integration with Hammerspoon automation, AeroSpace window management, and Sublime Text configuration.

**Linux**: Traditional Linux desktop setup with i3 window manager, polybar status bar, and X11 configurations.