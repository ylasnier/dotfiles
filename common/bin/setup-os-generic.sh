#!/bin/bash
#===============================================================================
#
#         FILE: install-apps.sh
#
#        USAGE: install-apps [-u [<user>,...]] [-v]
#
#  DESCRIPTION: install core applications
#
#      OPTIONS: see function ’usage’ below
# REQUIREMENTS: osx: homebrew or macports
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Yves Lasnier <yves.lasnier@ansamb.com>
#      COMPANY: Ansamb
#      VERSION: 0.1
#      CREATED: 27.03.2015
#
#==============================================================================

function usage() {
cat <<EOF
usage: install-apps [-a [<app>,...]] [-v]

install-apps - install core applications

OPTIONS:
-a APPS :   Applications to install. If not indicated, install all core-set
            applications (see available set below).
-v :        Redirect log messages to stdout
-h :        Print this help message

Available apps : core set : zsh, vim, git, hub, ctags, terminator (linux),
                            iterm2 (osx), nodejs, npm, coffee, meteor
EOF
}

function build_hub() {
  git clone https://github.com/github/hub.git
  case $pm in
    port*)
      go="go";;
    ?)
      go="golang"
  esac
  cd hub
  if ! which go; then
    pm $go
  fi
  ./script/build
  cp hub $bin
  cd ..
  rm -r hub
}

function init_pm() {
  case "$OSTYPE" in
    linux*)
      # I personnally prefer aptitude over apt-get
      which aptitude; [[ $? -eq 0 ]] && pm="aptitude install -y"
                                     && aptitude update && break
      which apt-get;  [[ $? -eq 0 ]] && pm="apt-get install -y"
                                     && apt-get update && break
      which yum; [[ $? -eq 0 ]] && pm="yum -y install" && break
      # TODO complete for other package managers ..
      ;;
    darwin*)
      if which brew; then
        brew update
        pm="brew install"
      elif which port; then
        port selfupdate
        pm="port install"
      else
        echo "error: no package manager found."
        echo "Please check if Homebrew or MacPorts is installed. /
              If not, pick and install one of them before retrying : /
              http://brew.sh, https://www.macports.org/"
        exit 1
  esac
  return 0
}

function install_apps() {
  if [ $pm != "brew" ]; then
    apps=`echo $apps | sed 's/hub//g'`
    [[ "$apps" == *"git"* ]] && gitapps="hub"
  fi
  if [[ "$apps" == *"npm"* ]]
    apps=`echo $apps | sed 's/coffee//g'`
    npmapps="coffee-script"
  fi
  if [[ "$apps" == *"iterm2"* ]]; then
    apps=`echo $apps | sed 's/iterm2//g'`
    caskapps="iterm2"
  fi

  if [[ "$apps" == *"ctags"* ]]; then
    case $pm in
      port*)
        apps=$apps;;
      brew*)
        apps=`echo $apps | sed 's/ctags//g'`
        apps="$apps ctags-exuberant ";;
      ?)
        apps=`echo $apps | sed 's/ctags//g'`
        apps="$apps exuberant-ctags"
    esac
  fi

  if [[ "$apps" == *"meteor"* ]]; then
    apps=`echo $apps | sed 's/meteor//g'`
    if ! which curl; then pm curl; fi
    curl https://install.meteor.com/ | sh
  fi

  if [ $apps ]; then
    log "Install apps ${apps// /,}..."
    pm $apps
    log "Install apps ${apps// /,}... Done."
  fi
  if [ $npmapps ]; then
    log "Install npm apps ${npmapps// /,}..."
    npm install -g $npmapps
    log "Install npm apps ${npmapps// /,}... Done."
  fi
  if [ $gitapps ]; then
    log "Clone git repos ${gitapps// /,}..."
    if [[ "$gitapps" == *"hub"* ]]; then
      build_hub
    fi
    log "Clone git repos ${gitapps// /,}... Done."
  fi
  if [ $caskapps ]; then
      if ! which brew-cask; then
          brew install caskroom/cask/brew-cask
      fi
      $pm cask $caskapps
  fi
  if [[ "$apps" == *"zsh"* ]]
    chsh -s $(which zsh)
  fi
  return 0
}

function parse_args() {
  while getopts r:u:vh OPT; do
    case $OPT in
      a)
          apps=$(echo "${OPTARG//,/ }" | tr ' ' '\n' | nl | sort -u -k2 \
                                       | sort -n | cut -f2-)
          exit 0
          ;;
      h)
          usage;
          exit 0
          ;;
      ?)
          echo "error: bad usage ;)"
          usage;
          exit 1
    esac
  done
}


### main

function main() {
  init_pm
  users=$USERNAME
  verbose=false
  bin="/usr/local/bin"
  apps="zsh vim git hub nodejs npm coffee meteor ctags"
  case "$OSTYPE" in
      linux*)
          apps="${apps} terminator";;
      darwin*)
          apps="${apps} iterm2"
  esac
  parse_args $@
  install_apps
  return 0
}

main $@

