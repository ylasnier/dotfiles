#!/usr/bin/env bash
# Opens a Ptyxis terminal window and an nvim window sharing a random favourite theme, picked among
# the dark or light ones depending on the GNOME color scheme.
# Usage: work-session [DIR]   (both windows start in DIR, the current directory by default)
set -euo pipefail

# absolute, since Ptyxis resolves -d from its own working directory, not this script's
work_dir=$(realpath -e -- "${1:-$PWD}")
if [[ ! -d $work_dir ]]; then
  echo "work-session: $work_dir is not a directory" >&2
  exit 1
fi

# nvim colorscheme => Ptyxis built-in palette
declare -A dark_themes=(
  [tokyonight-night]="Tokyo Night"
  [rose-pine-moon]="Rosé Pine Moon"
  [catppuccin-mocha]="Catppuccin Mocha"
)
declare -A light_themes=(
  [tokyonight-day]="Tokyo Night Day"
  [rose-pine-dawn]="Rosé Pine Dawn"
  [catppuccin-latte]="Catppuccin Latte"
  [tokyonight-night]="Tokyo Night"
  [rose-pine-moon]="Rosé Pine Moon"
  [catppuccin-mocha]="Catppuccin Mocha"
)

if [[ $(gsettings get org.gnome.desktop.interface color-scheme) == "'prefer-dark'" ]]; then
  declare -n themes=dark_themes
else
  declare -n themes=light_themes
fi

colorschemes=("${!themes[@]}")
colorscheme=${colorschemes[RANDOM % ${#colorschemes[@]}]}
palette=${themes[$colorscheme]}

# One profile per theme rather than a shared one: a palette change applies live to every window
# using the profile, so re-themeing a shared profile would repaint the windows opened before.
profile_uuid=$(printf 'themed-term %s' "$palette" | md5sum | cut -c1-32)
profile_schema="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$profile_uuid/"
profile_uuids=$(gsettings get org.gnome.Ptyxis profile-uuids)
if [[ $profile_uuids != *"'$profile_uuid'"* ]]; then
  gsettings set org.gnome.Ptyxis profile-uuids "${profile_uuids%]}, '$profile_uuid']"
fi
gsettings set "$profile_schema" label "Themed: $palette"
gsettings set "$profile_schema" palette "$palette"

# Ptyxis can only open a new window with the default profile, so swap it for the launch
default_profile=$(gsettings get org.gnome.Ptyxis default-profile-uuid)
trap 'gsettings set org.gnome.Ptyxis default-profile-uuid "$default_profile"' EXIT
gsettings set org.gnome.Ptyxis default-profile-uuid "$profile_uuid"

# the shell exports the colorscheme too, so an nvim started from it later gets the same theme.
# setsid: when Ptyxis isn't running yet, the first launch becomes the app and doesn't return.
setsid -f ptyxis -d "$work_dir" -- env NVIM_COLORSCHEME="$colorscheme" "$SHELL" >/dev/null 2>&1
setsid -f ptyxis -d "$work_dir" -- env NVIM_COLORSCHEME="$colorscheme" nvim >/dev/null 2>&1
sleep 1 # let Ptyxis create the windows before the default profile is restored

echo "$colorscheme"
