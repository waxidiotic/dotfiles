#!/bin/sh

echo "Setting up your Mac..."

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Make ZSH the default shell environment (not needed for macOS Catalina)
# chsh -s $(which zsh)

# Install global NPM packages
npm install --global pure-prompt

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
source .macos
