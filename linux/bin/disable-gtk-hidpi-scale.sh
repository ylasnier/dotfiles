#!/bin/bash
gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <1>}"
gnome-shell --replace

