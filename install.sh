#!/bin/sh

echo "Setting up your Mac..."

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Install Node via NVM
nvm install node

# Install global NPM packages
yarn global add create-next-app netlify-cli yalc yo

# Create a Repos directory
# This is a default directory for git repositories
mkdir $HOME/Repos

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Setup Hyper
rm -rf $HOME/.hyper.js
cp $HOME/.dotfiles/.hyper.js $HOME

# Setup gitconfig and global ignores
rm -rf $HOME/.gitconfig $HOME/.gitignore_global
cp $HOME/.dotfiles/.gitconfig $HOME/.dotfiles/.gitignore_global $HOME

# Set macOS preferences
# We will run this last because this will reload the shell
# source .macos
