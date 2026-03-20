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

# Clone repositories (idempotent)
clone_repo() {
    local repo_url="$1"
    local target_dir="$2"
    local name="$3"

    if [[ -d "$target_dir" ]]; then
        if $DRY_RUN; then
            echo "[ALREADY CLONED] $name"
        else
            echo "$name is already cloned."
        fi
        return
    fi

    if $DRY_RUN; then
        echo "[WOULD CLONE] $name -> $target_dir"
        return
    fi

    echo "Cloning $name..."
    git clone "$repo_url" "$target_dir"
    echo "$name cloned successfully!"
}

clone_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh" "Oh My Zsh"
clone_repo "https://github.com/ydeng11/dotfiles.git" "$HOME/dotfiles" "dotfiles"
clone_repo "https://github.com/junegunn/fzf-git.sh.git" "$HOME/.fzf-git.sh" "fzf-git.sh"
