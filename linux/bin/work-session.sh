#!/usr/bin/env bash
# Opens a Ptyxis terminal window and an nvim window sharing a random favourite theme, picked among
# the dark or light ones depending on the GNOME color scheme.
# Usage: work-session [DIR]   (both windows start in DIR, the current directory by default)
# Without DIR and outside a terminal (e.g. from a keyboard shortcut), a folder chooser asks for it,
# opened in ~/Code/digiforma-worktrees.
set -euo pipefail

code_dir=$HOME/Code

fail() {
  echo "work-session: $1" >&2
  # a shortcut has no terminal to show the error in
  [[ -t 2 ]] || zenity --error --title="Work session" --text="$1"
  exit 1
}

dir=${1:-}
launched_from_terminal=$([[ -t 0 ]] && echo true || echo false)
if [[ -z $dir && $launched_from_terminal == true ]]; then
  dir=$PWD
elif [[ -z $dir ]]; then
  # trailing slash: opens inside the folder rather than selecting it in its parent
  dir=$(zenity --file-selection --directory --title="Work session" \
    --filename="$code_dir/digiforma-worktrees/") || exit 0
fi

# absolute, since Ptyxis resolves -d from its own working directory, not this script's
work_dir=$(realpath -e -- "$dir" 2>/dev/null) || fail "$dir does not exist"
[[ -d $work_dir ]] || fail "$work_dir is not a directory"

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
# The profile's command exports the colorscheme, so every tab opened with it (new tabs inherit the
# active tab's profile) gets the theme for nvim too. It also starts nvim when the marker is there
# (rm is atomic, so a single tab claims it), then falls back to the shell when nvim exits.
nvim_marker=${XDG_RUNTIME_DIR:-/tmp}/work-session-nvim
gsettings set "$profile_schema" use-custom-command true
gsettings set "$profile_schema" custom-command \
  "env NVIM_COLORSCHEME=$colorscheme sh -c 'rm $nvim_marker 2>/dev/null && nvim; exec $SHELL'"

# Ptyxis can only open a new window with the default profile, so swap it for the launch
default_profile=$(gsettings get org.gnome.Ptyxis default-profile-uuid)
trap 'gsettings set org.gnome.Ptyxis default-profile-uuid "$default_profile"' EXIT
gsettings set org.gnome.Ptyxis default-profile-uuid "$profile_uuid"

# setsid: when Ptyxis isn't running yet, the first launch becomes the app and doesn't return.
open_window() { setsid -f ptyxis --new-window -d "$work_dir" >/dev/null 2>&1; }

touch "$nvim_marker"
open_window
# open the shell window only once the nvim one has claimed the marker
for _ in {1..50}; do
  [[ -e $nvim_marker ]] || break
  sleep 0.1
done
rm -f "$nvim_marker" # unclaimed: the nvim window failed to open, don't let a later tab claim it
open_window
sleep 1 # let Ptyxis create the windows before the default profile is restored

echo "$colorscheme"
