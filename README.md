# My Dotfiles

It includes the config for:
- `atuin` : terminal history management
- `bat` : better `cat`
- `thefuck` : auto corrected command
- `git` : version control
- `oh my zsh` : zsh framework
- `powerlevel10k` : zsh shell theme
- `wezterm` : terminal emulator

## How to use
1. Download the zip and unzip under the home directory
2. `sh setup_git.sh` setup github so we could pull repos at #3
3. `sh setup_mac.sh` install the above packages using `homebrew`
4. use `stow` to create the symlink for each config (**WARN:** remove the existing config created when installing the pacakge. Otherwise, `stow` will complain about the conflicted files.)