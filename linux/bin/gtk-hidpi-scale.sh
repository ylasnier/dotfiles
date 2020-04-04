#!/bin/bash

function usage() {
cat <<EOF
usage: highdpi-scale [options]

highdpi-scale - Change resolution scale

OPTIONS:
-e, --enable  :   Enable High-DPI scale
-d, --disable :   Disable High-DPI scale
-h, --help    :   Print this help message
EOF
}

function enable_hidpi() {
  gsettings set org.gnome.desktop.interface scaling-factor 2
  gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <2>}"
  gnome-shell --replace
}

function disable_hidpi() {
  gsettings set org.gnome.desktop.interface scaling-factor 1
  gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <1>}"
  gnome-shell --replace
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

opts=$(getopt -n "$0" -o edph -l enable,disable,print,help -- "$@")
eval set -- "$opts"

while [ "$#" -gt 0 ]; do
  case $1 in
    -e | --enable)
      echo "Enable High-DPI"
      enable_hidpi
      shift
      ;;
    -d | --disable)
      echo "Disable High-DPI"
      disable_hidpi
      shift
      ;;
    -h | --help)
      usage
      shift
      ;;
    --)
      shift
      ;;
    *)
      shift
      break
      ;;
  esac
done

