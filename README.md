# My Dotfiles

It includes the config for:
- `atuin` : terminal history management
- `bat` : better `cat`
- `thefuck` : auto corrected command
- `git` : version control
- `stow` : the dotfiles management (actually a symlink management)
- `oh my zsh` : zsh framework
- `powerlevel10k` : zsh shell theme
- `wezterm` : terminal emulator

## How to use
1. Download the zip and unzip under the home directory
2. `sh setup_git.sh` setup github so we could pull repos at #3
3. `sh setup_mac.sh` install the above packages using `homebrew`
4. Use `stow` to create the symlinks for each config. Here are different scenarios:

### For a fresh OS installation
- Simply run `stow <package>` for each package you want to set up
- Example: `stow zsh` to create symlinks for `.zshrc`, `.zprofile` and `.p10k.zsh`
- If your dotfiles are not in your home directory, use the `-t` flag to specify the target directory:
  - Example: `stow -t ~ zsh` to create symlinks in your home directory

### When you've already used stow before
- If you want to update all symlinks, first unstow everything: `stow -D *`
- Then restow the packages you want: `stow <package>`
- Or use `stow -R <package>` to restow a specific package (this will first unstow and then stow)
- With target directory: `stow -t ~ -R <package>`

### When there are existing configs
- First, backup your existing configs if needed
- Remove the existing config files that would conflict with stow
- Then run `stow <package>` to create the symlinks
- If you want to force stow to overwrite existing files (not recommended), use `stow -f <package>`
- With target directory: `stow -t ~ -f <package>`

