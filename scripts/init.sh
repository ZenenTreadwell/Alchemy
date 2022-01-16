#!/bin/bash

# This is a script to be run on a fresh installation of Raspbian in order to make it suitable (to me) for CLI development
# ~ Zen, 2022

if [ -f "/etc/debian_version" ]; then
	DISTRO="debian"
	echo "Debian, Ubuntu, or Raspbian OS detected."
elif [ -f "/etc/arch-release" ]; then
	DISTRO="arch"
	echo "Arch- or Manjaro-based OS detected."
elif [ $(uname | grep -c "Darwin") -eq 1 ]; then
	DISTRO="mac"
	echo "MacOS detected."
else
	echo "I don't know what OS you're running! Cancelling this operation."
	exit 1
fi

echo ""

install_if_needed() {
    for package in "$@"
    do
        if [ -z $(which $package) ]; then
            echo "installing" $package

            case $DISTRO in
                "debian")
                    sudo apt install -y $package
                    ;;
                "arch")
                    sudo pacman -S $package
                    ;;
                "mac")
                    brew install $package
                    ;;
            esac

        else
            echo $package 'already installed!'
        fi
    done

}

echo "Updating the repositories..."
case $DISTRO in
    "debian")
        sudo apt update
        sudo apt autoremove
        ;;
    "arch")
        sudo pacman -Syu
        ;;
    "mac")
        install
        sudo brew update
        ;;
esac
echo ""

echo "Making sure we've got the basics..."
case $DISTRO in
    "debian")
        echo "Updating the repositories!"
        sudo apt update
        sudo apt autoremove
        install_if_needed vim tmux zsh git silversearcher-ag
        ;;
    "arch")
        echo "Updating the repositories!"
        sudo pacman -Syu
        install_if_needed vim tmux zsh git the_silver_searcher
        ;;
    "mac")
        install_if_needed vim tmux zsh git the_silver_searcher
        ;;
esac
echo ""

echo "Getting tmux-powerline"
mkdir $HOME/.tmux
git clone https://github.com/erikw/tmux-powerline.git $HOME/.tmux/
echo ""

echo "Copying configuration files"
mkdir -p $HOME/.vim/colors
cp resources/solarized.vim $HOME/.vim/colors/
cp resources/vimrc $HOME/.vimrc
cp resources/tmux.conf $HOME/.tmux.conf
cp resources/tmux-powerline-theme.sh $HOME/.tmux/tmux-powerline/themes/default.sh
echo ""

echo "Installing Oh My Zsh for theming - this could take a moment"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cat resources/zshrc-extras >> $HOME/.zshrc
echo ""

echo "Adding p10k for optimal dev experience"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/^ZSH_THEME.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $HOME/.zshrc
echo ""

echo "...and we're back! Now that you've installed everything you need, try closing your connection to the terminal and re-opening."
