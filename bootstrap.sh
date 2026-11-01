#!/bin/zsh

cd $HOME
git clone https://github.com/masasam-shi/dotfiles

cd $HOME/dotfiles/ln-files
for file in .??*; do
	case "$file" in
		.codex|.claude) continue ;;
	esac
	ln -s $HOME/dotfiles/ln-files/$file $HOME/$file
done

mkdir -p "$HOME/.codex" "$HOME/.claude"
for file in .codex/AGENTS.md .claude/CLAUDE.md; do
	ln -s "$HOME/dotfiles/ln-files/$file" "$HOME/$file"
done

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | sh
cd $HOME/dotfiles/
brew bundle
cd $HOME
