# My Dotfiles

This repository contains configuration files for various development tools and utilities.

## Included Tools & Configurations

### Terminal & Shell
- `zsh` with `oh-my-zsh` framework
- `powerlevel10k` : zsh shell theme
- `wezterm` : terminal emulator
- `atuin` : terminal history management

### Command Line Utilities
- `bat` : better `cat` with syntax highlighting
- `eza` : better `ls` with colors and icons
- `fd` : better `find`
- `fzf` : fuzzy finder
- `fzf-git.sh` : git integration for fzf
- `thefuck` : auto-corrected commands
- `zoxide` : smarter `cd` command
- `tlrc` : community-driven man pages

### Development Tools
- `git` with `git-delta` : enhanced git diff viewer
- `node` : JavaScript runtime
- `hugo` : static site generator
- `uv` : Python package manager
- `sdkman` : SDK management

### System Utilities
- `stow` : dotfiles management via symlinks
- `raycast` : enhanced spotlight search
- `keepingyouawake` : prevent system sleep

### Fonts
- `JetBrains Mono` : coding font
- `JetBrains Mono Nerd Font` : coding font with icons

## Installation

### 1. Initial Setup
```bash
# Clone this repository to your home directory
git clone https://github.com/ydeng11/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Setup git configuration
sh setup_git.sh

# Install all tools and dependencies
sh setup_mac.sh
```

### 2. Create Symlinks with Stow

`stow` creates symbolic links from this dotfiles repository to your home directory, allowing you to keep your configurations in version control while having them accessible in their expected locations.

#### For a fresh OS installation
- Simply run `stow <package>` for each package you want to set up
- Example: `stow zsh` to create symlinks for `.zshrc`, `.zprofile` and `.p10k.zsh`
- If your dotfiles are not in your home directory, use the `-t` flag to specify the target directory:
  - Example: `stow -t ~ zsh` to create symlinks in your home directory

#### When you've already used stow before
- If you want to update all symlinks, first unstow everything: `stow -D *`
- Then restow the packages you want: `stow <package>`
- Or use `stow -R <package>` to restow a specific package (this will first unstow and then stow)
- With target directory: `stow -t ~ -R <package>`

#### When there are existing configs
- First, backup your existing configs if needed
- Remove the existing config files that would conflict with stow
- Then run `stow <package>` to create the symlinks
- If you want to force stow to overwrite existing files (not recommended), use `stow -f <package>`
- With target directory: `stow -t ~ -f <package>`

### 3. Post-Installation
After running the setup scripts and stowing your configurations:

1. Restart your terminal or run `source ~/.zshrc`
2. Configure any remaining tool-specific settings
3. Enjoy your enhanced development environment!

