#!/bin/bash

# Function to install Git using Homebrew
install_git() {
    echo "Installing Git..."
    brew install git
}

# Check if Git is installed, install if not
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing Git..."
    install_git
else
    echo "Git is already installed. Updating Git..."
    brew upgrade git
fi

# Prompt user for GitHub username and email
read -p "Enter your GitHub username: " github_username
read -p "Enter your GitHub email: " github_email

# Configure Git with the provided username and email
git config --global user.name "$github_username"
git config --global user.email "$github_email"

echo "Git configuration completed with username: $github_username and email: $github_email"

# Check if an SSH key already exists
if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "An SSH key already exists."
else
    # Prompt user to generate a new SSH key
    read -p "No SSH key found. Would you like to generate a new SSH key? (y/n): " generate_ssh_key

    if [ "$generate_ssh_key" == "y" ]; then
        ssh-keygen -t rsa -b 4096 -C "$github_email"

        # Start the ssh-agent
        eval "$(ssh-agent -s)"

        # Add the SSH key to the ssh-agent
        ssh-add -K "$HOME/.ssh/id_rsa"

        echo "SSH key generated and added to the ssh-agent."

        echo "Copy the SSH key to your clipboard with the following command:"
        echo "pbcopy < ~/.ssh/id_rsa.pub"

        echo "Then, add the SSH key to your GitHub account by following these steps:"
        echo "1. Go to GitHub -> Settings -> SSH and GPG keys -> New SSH key"
        echo "2. Paste the SSH key and save it"
    else
        echo "Skipping SSH key generation."
    fi
fi

echo "GitHub setup completed!"
