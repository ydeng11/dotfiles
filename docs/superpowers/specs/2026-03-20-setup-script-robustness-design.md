---
title: Robust Setup Script Design
date: 2026-03-20
---

# Setup Script Improvements

## Goals

1. **Idempotent** - Safe to run repeatedly without side effects
2. **Testable** - Dry-run mode with summary of actions

Non-goal: Intel Mac support (Apple Silicon only is fine)

## Changes

### 1. Script Header and Flags

- Add `set -e` for fail-fast on errors
- Add `--dry-run` flag that prints summary and exits without making changes

### 2. Homebrew Installation

- Detect brew path instead of hardcoding `/opt/homebrew/bin/brew`
- Idempotent zprofile modification (grep check before appending)
- Dry-run shows what would happen

### 3. Package Installation

- Define packages in arrays at top of file for easy modification
- Dry-run prints clean list of casks and packages
- Use loops instead of individual install lines

### 4. Bat Theme and Repository Cloning

- Bat theme function checks if already installed
- Config modification is idempotent (grep before appending)
- Generic `clone_repo` function with dry-run support
- Fix bug: line 64 was `git https://...`, should be `git clone https://...`
- Add `-f` flag to curl for silent fail on errors

## Usage

```bash
# Normal run
./setup_mac.sh

# Preview what would happen
./setup_mac.sh --dry-run
```

## File Structure

Single file remains - `setup_mac.sh`. No new files needed.