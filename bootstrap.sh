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
    sudo ./linux/install-packages
    ./install -c linux/install.conf.yaml
    ;;
  darwin*)
    ./osx/install-packages
    ./install -c osx/install.conf.yaml
esac

./common/install-packages
./install -c common/install.conf.yaml

if [ -d workstation ]; then
  ./workstation/install-packages
  ./install -c workstation/install.conf.yaml
fi

