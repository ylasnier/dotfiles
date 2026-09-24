#!/bin/bash

if [ $# -eq 0 ]; then
  DOTFILES="$HOME/.dotfiles"
else
  DOTFILES=$1
fi

git clone --recursive https://github.com/ylasnier/dotfiles.git $DOTFILES
if [ ! -d $DOTFILES ]; then
  echo "Cloning ylasnier/dotfiles.git into $DOTFILES..."
  git clone --recursive https://github.com/ylasnier/dotfiles.git $DOTFILES
  echo "Cloning ylasnier/dotfiles.git into $DOTFILES... Done."
else
  echo "$DOTFILES already exists"
fi

cd $DOTFILES

case "$OSTYPE" in
  linux*)
    VERSION=$(source /etc/os-release && echo $ID)

    case "$VERSION" in
	Debian)
	    sudo ./linux/install-packages-apt
	;;
	Fedora)
	    sudo ./linux/install-packages-dnf
	
	esac
	./install -c linux/install.conf.yaml
    ;;

  darwin*)
    ./macos/install-packages
    ./install -c macos/install.conf.yaml
esac

./install -c common/install.conf.yaml

if [ -d workstation ]; then
  ./workstation/install-packages
  ./install -c workstation/install.conf.yaml
fi

