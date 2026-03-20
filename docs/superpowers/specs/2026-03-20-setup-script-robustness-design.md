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

## Changes

### 1. Script Header and Flags

- Add `set -e` for fail-fast on errors
- Add `--dry-run` flag that prints summary and exits without making changes
- Exit code: 0 for success (including dry-run), non-zero for failure

### 2. Homebrew Installation

- Detect brew path using `command -v brew` first, then fallback to checking `/opt/homebrew/bin/brew`
- Idempotent zprofile modification (grep check before appending)
- Dry-run shows what would happen
- `brew update` runs every time when brew is already installed (intentional - keeps brew updated)

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
- Check if `$THEME_DIR/tokyonight_night.tmTheme` exists before downloading
- Config modification is idempotent (grep before appending)
- Add `-f` flag to curl for silent fail on errors

### 5. Repository Cloning

- Generic `clone_repo` function with signature: `clone_repo <url> <target_dir> <name>`
- Dry-run prints: `[WOULD CLONE] <name> -> <target_dir>` or `[ALREADY CLONED] <name>`
- Fix bug: line 64 was `git https://...`, should be `git clone https://...`

### 6. External Script Integration

- `get_bat_theme.sh` is replaced by inline `install_bat_theme` function
- No other external scripts are called

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