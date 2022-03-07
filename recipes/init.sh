#!/bin/bash

# This is a script to be run on a fresh installation of Raspbian in order to make it suitable (to me) for CLI development
# ~ Zen, 2022

source ingredients/lead

echo "Updating the repositories..."
case $DISTRO in
    "debian")
        sudo apt update
        sudo apt autoremove
        sudo apt upgrade
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
        install_if_needed vim tmux zsh git silversearcher-ag
        ;;
    "arch")
        install_if_needed vim tmux zsh git the_silver_searcher
        ;;
    "mac")
        install_if_needed vim tmux zsh git the_silver_searcher
        ;;
esac
echo ""

echo "Getting tmux-powerline"
mkdir -p $HOME/.tmux
git clone https://github.com/erikw/tmux-powerline.git $HOME/.tmux/tmux-powerline
echo ""

echo "Copying configuration files"
mkdir -p $HOME/.vim/colors
cp resources/solarized.vim $HOME/.vim/colors/
cp resources/vimrc $HOME/.vimrc
cp resources/tmux.conf $HOME/.tmux.conf
cp resources/tmux-powerline-theme.sh $HOME/.tmux/tmux-powerline/themes/default.sh
echo ""

# TODO is this needed? can we install p10k on base zsh?
#echo "Installing Oh My Zsh for theming - this could take a moment"
#sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cat resources/zshrc-extras >> $HOME/.zshrc
echo ""

echo "Adding p10k for optimal dev experience"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/^ZSH_THEME.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $HOME/.zshrc
echo ""

$SHELL
