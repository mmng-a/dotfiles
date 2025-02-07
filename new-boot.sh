#!/bin/zsh

cd $HOME/dotfiles/ln-files
for file in .??*; do
	ln -s $HOME/dotfiles/ln-files/$file $HOME/$file
done

cd $HOME/dotfiles/
brew bundle
cd $HOME
