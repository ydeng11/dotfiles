#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Check if Homebrew is installed, install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    install_homebrew
else
    echo "Homebrew is already installed. Updating Homebrew..."
    brew update
fi

# Ensure Homebrew is in the PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install desired packages
echo "Installing packages..."
brew install --cask wezterm
brew install fzf
brew install fd
brew install bat
brew install git-delta
brew install eza
brew install tlrc
brew install thefuck
brew install zoxide
brew install stow
brew install node
brew install hugo
brew install atuin
brew install powerlevel10k

echo "All packages installed successfully!"

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
    git clone git@github.com:ydeng11/dotfiles.git ~/dotfiles
    echo "dotfiles cloned successfully!"
fi

if [ -d "$HOME/.fzf-git.sh" ]; then
    echo "fzf-git.sh is already cloned."
else
    echo "Cloning fzf-git.sh repository..."
    git clone git@github.com:junegunn/fzf-git.sh.git ~/.fzf-git.sh
    echo "fzf-git.sh cloned successfully!"
fi