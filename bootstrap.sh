#!sh

cd ~
git clone https://github.com/masasam-shi/dotfiles

cd ~/dotfiles/ln-files
for file in .??*; do
	ln -s $HOME/dotfiles/ln-files/$file $HOME/$file
done
