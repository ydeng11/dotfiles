#!/bin/bash
set -e  # Exit on any error

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DRY_RUN=true
    fi
done

if $DRY_RUN; then
    echo "=== DRY RUN MODE ==="
    echo "No changes will be made."
    echo ""
fi

# Constants
BREW_ZPROFILE_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'

# Package arrays
CASKS=("wezterm" "keepingyouawake" "raycast" "font-jetbrains-mono" "font-jetbrains-mono-nerd-font")
PACKAGES=("fzf" "fd" "bat" "git-delta" "eza" "tlrc" "thefuck" "zoxide" "stow" "node" "hugo" "atuin" "uv" "mise" "powerlevel10k")

# Detect Homebrew path
get_brew_path() {
    if command -v brew &> /dev/null; then
        which brew
    elif [[ -f /opt/homebrew/bin/brew ]]; then
        echo "/opt/homebrew/bin/brew"
    fi
}

# Install Homebrew if not present
install_homebrew() {
    if $DRY_RUN; then
        echo "[WOULD INSTALL] Homebrew"
        echo "[WOULD ADD] Homebrew to ~/.zprofile"
        return
    fi

    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to zprofile (idempotent)
    mkdir -p ~/.config
    if [[ ! -f ~/.zprofile ]] || ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
        echo "$BREW_ZPROFILE_LINE" >> ~/.zprofile
    fi

    eval "$(get_brew_path) shellenv"
    echo "Homebrew installed."
}

# Check if Homebrew is installed
BREW_PATH=$(get_brew_path)
if [[ -z "$BREW_PATH" ]]; then
    install_homebrew
else
    if $DRY_RUN; then
        echo "[ALREADY INSTALLED] Homebrew"
    else
        echo "Homebrew already installed. Updating..."
        brew update
    fi
fi

# Ensure Homebrew is in PATH
if [[ -n "$BREW_PATH" ]]; then
    eval "$($BREW_PATH shellenv)"
fi

# Install packages
if $DRY_RUN; then
    echo ""
    echo "[WOULD INSTALL] Casks:"
    printf '  - %s\n' "${CASKS[@]}"
    echo "[WOULD INSTALL] Packages:"
    printf '  - %s\n' "${PACKAGES[@]}"
else
    echo "Installing packages..."
    for cask in "${CASKS[@]}"; do
        brew install --cask "$cask"
    done
    for pkg in "${PACKAGES[@]}"; do
        brew install "$pkg"
    done
    echo "All packages installed successfully!"
fi

# Install bat theme
install_bat_theme() {
    local theme_dir config_file

    # Compute paths lazily (bat must be installed)
    theme_dir="$(bat --config-dir)/themes"
    config_file="$(bat --config-dir)/config"

    if [[ -f "$theme_dir/tokyonight_night.tmTheme" ]]; then
        if $DRY_RUN; then
            echo "[ALREADY INSTALLED] Bat theme (tokyonight_night)"
        else
            echo "Bat theme already installed."
        fi
        return
    fi

    if $DRY_RUN; then
        echo "[WOULD INSTALL] Bat theme (tokyonight_night)"
        return
    fi

    echo "Installing bat theme..."
    mkdir -p "$theme_dir"
    curl -fsSL -o "$theme_dir/tokyonight_night.tmTheme" \
        https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
    bat cache --build

    # Update config (replace existing theme or append)
    mkdir -p "$(dirname "$config_file")"
    if [[ -f "$config_file" ]]; then
        if grep -q '^--theme="tokyonight_night"' "$config_file"; then
            : # Already correct, do nothing
        elif grep -q '^--theme=' "$config_file"; then
            # Replace existing theme line with different theme
            sed -i '' 's/^--theme=.*/--theme="tokyonight_night"/' "$config_file"
        else
            echo '--theme="tokyonight_night"' >> "$config_file"
        fi
    else
        echo '--theme="tokyonight_night"' >> "$config_file"
    fi
    echo "Bat theme installed."
}

install_bat_theme

# Clone Oh My Zsh repository
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
else
    echo "Cloning Oh My Zsh repository..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    echo "Oh My Zsh cloned successfully!"
fi

if [ -d "$HOME/dotfiles" ]; then
    echo "dotfiles is already cloned."
else
    echo "Cloning dotfiles repository..."
    git https://github.com/ydeng11/dotfiles.git ~/dotfiles
    echo "dotfiles cloned successfully!"
fi

if [ -d "$HOME/.fzf-git.sh" ]; then
    echo "fzf-git.sh is already cloned."
else
    echo "Cloning fzf-git.sh repository..."
    git clone https://github.com/junegunn/fzf-git.sh.git ~/.fzf-git.sh
    echo "fzf-git.sh cloned successfully!"
fi
