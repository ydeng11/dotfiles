---
title: Robust Setup Script Design
date: 2026-03-20
---

# Setup Script Improvements

## Goals

1. **Idempotent** - Safe to run repeatedly without side effects
2. **Testable** - Dry-run mode with summary of actions

Non-goals:
- Intel Mac support (Apple Silicon only is fine)
- Error recovery/rollback (fail-fast is acceptable)
- Verbose logging mode (simple output is sufficient)

## Constants

```bash
BAT_THEME_DIR="$(bat --config-dir)/themes"
BAT_CONFIG_FILE="$(bat --config-dir)/config"
BREW_ZPROFILE_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
```

## Changes

### 1. Script Header and Flags

- Add `set -e` for fail-fast on errors
- Add `--dry-run` flag that prints summary and exits without making changes
- Exit code: 0 for success (including dry-run), non-zero for failure

### 2. Homebrew Installation

- Detect brew path using `command -v brew` first, then fallback to checking `/opt/homebrew/bin/brew`
- Idempotent zprofile modification:
  - Grep pattern: `brew shellenv`
  - Only append if not found
  - Create `~/.zprofile` if it doesn't exist
- `brew update` runs every time when brew is already installed (intentional - keeps brew updated)

Dry-run output:
```
[WOULD INSTALL] Homebrew
[WOULD ADD] Homebrew to ~/.zprofile
```
or
```
[ALREADY INSTALLED] Homebrew
[WOULD UPDATE] Homebrew
```

### 3. Package Installation

- Define packages in arrays at top of file for easy modification
- `brew install` is already idempotent (skips installed packages), so no additional checks needed
- Dry-run prints human-readable list:
  ```
  [WOULD INSTALL] Casks:
    - wezterm
    - keepingyouawake
    ...
  [WOULD INSTALL] Packages:
    - fzf
    - fd
    ...
  ```
- Use loops instead of individual install lines

### 4. Bat Theme

- Replace the external `get_bat_theme.sh` script with an inline function
- Check if `$BAT_THEME_DIR/tokyonight_night.tmTheme` exists before downloading
- Run `bat cache --build` after downloading theme
- Config modification:
  - File: `$BAT_CONFIG_FILE`
  - Content to append: `--theme="tokyonight_night"`
  - Grep pattern: `tokyonight_night`
  - Create config file if it doesn't exist

Dry-run output:
```
[WOULD INSTALL] Bat theme (tokyonight_night)
```
or
```
[ALREADY INSTALLED] Bat theme (tokyonight_night)
```

### 5. Repository Cloning

Generic `clone_repo` function with signature: `clone_repo <url> <target_dir> <name>`

Three repositories to clone:
1. Oh My Zsh: `https://github.com/ohmyzsh/ohmyzsh.git` → `~/.oh-my-zsh`
2. dotfiles: `https://github.com/ydeng11/dotfiles.git` → `~/dotfiles`
3. fzf-git.sh: `https://github.com/junegunn/fzf-git.sh.git` → `~/.fzf-git.sh` (directory, not file)

Dry-run output (for each):
```
[WOULD CLONE] <name> -> <target_dir>
```
or
```
[ALREADY CLONED] <name>
```

Note on dotfiles: The script may be run from within dotfiles. If `~/dotfiles` already exists, skip cloning. The user can run setup from the cloned dotfiles directory.

Bug fix: Line 64 was `git https://...`, should be `git clone https://...`

## Usage

```bash
# Normal run
./setup_mac.sh

# Preview what would happen
./setup_mac.sh --dry-run
```

## File Structure

- `setup_mac.sh` - Main script (modified)
- `get_bat_theme.sh` - Can be deleted (functionality moved inline)