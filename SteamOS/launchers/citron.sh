#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "citron"
emuName="citron" #parameterize me
emufolder="$emusFolder" # has to be applications for ES-DE to find it

#find full path to emu executable
exe=$(find $emufolder -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo $exe

#if appimage doesn't exist fall back to flatpak.
if [[ $exe == '' ]]; then
	#flatpak
	flatpakApp=$(flatpak list --app --columns=application | grep 'citron')
	exe="/usr/bin/flatpak run "$flatpakApp
else
	#make sure that file is executable
	chmod +x $exe
fi

#fix the invalid rom format given
${exe} -f -g "$@" >/dev/null 2>&1 &

rm -rf "$savesPath/.gaming"
