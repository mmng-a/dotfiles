#!/bin/zsh

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
