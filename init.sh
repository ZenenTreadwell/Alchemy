#!/bin/bash

# This is a script to be run on a fresh installation of Raspbian in order to make it suitable (to me) for CLI development
# ~ Zen, 2022

if [ -f "/etc/debian_version" ]; then
	DISTRO="debian"
	echo "Debian, Ubuntu, or Raspbian OS detected, proceeding with Debian-compatible AO installation."
elif [ -f "/etc/arch-release" ]; then
	DISTRO="arch"
	echo Arch- or Manjaro-based OS detected, proceeding with Arch-compatible AO installation.
elif [ $(uname | grep -c "Darwin") -eq 1 ]; then
	DISTRO="mac"
	echo MacOS detected, proceeding with Mac-compatible AO installation.
else
	echo Could not detect your OS distribution. Running this script could make a mess, so installing manually is recommended.
	exit 1
fi

echo ""

install_if_needed() {
	if [ "$DISTRO" = "debian" ]; then
		for package in "$@"
		do
			if [ -z $(which $package) ]; then
				echo "installing" $package
				sudo apt install -y $package
			else
				echo $package 'already installed!'
			fi
		done
	
	else 
		echo "Only working on Debian right now!"
	fi
}

echo "Making sure we've got the basics..."
install_if_needed vim tmux zsh git silversearcher-ag
echo ""

echo "Getting tmux-powerline"
mkdir $HOME/.tmux
git clone https://github.com/erikw/tmux-powerline.git $HOME/.tmux/
echo ""

echo "Copying configuration files"
mkdir -p $HOME/.vim/colors
cp resources/solarized.vim $HOME/.vim/colors/
cp resouces/vimrc $HOME/.vimrc
cp resouces/tmux.conf $HOME/.tmux.conf
cp resouces/tmux-powerline-theme.sh $HOME/.tmux/tmux-powerline/themes/default.sh
echo ""

echo "Installing Oh My Zsh for theming - this could take a moment"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Adding p10k for optimal dev experience"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/^ZSH_THEME.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $HOME/.zshrc
