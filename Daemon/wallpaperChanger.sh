#!/bin/bash

# Get the PID of the current xfce session
pid_xfce="$(echo $(ps -C xfce4-session -o pid=))";
# Set the correct environment variable
DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/"$pid_xfce"/environ|cut -d= -f2-)";
# Export the correct environment variable
export DBUS_SESSION_BUS_ADDRESS;

# Log the env variable
logger -t WallpaperChanger -p daemon.debug "DBUS env var : $DBUS_SESSION_BUS_ADDRESS";

while true; do
	# Get all the possible wallpapers from the system
	wallpapers=("/usr/share/xfce4/backdrops"/*);
	# Get a random wallpaper path from the previous array
	random_wallpaper=$(printf "%s\n" "${wallpapers[RANDOM % ${#wallpapers[@]}]}");
	# Change the actual wallpaper of the computer
	xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set "$random_wallpaper";
	# Log the changed image
	logger -t WallpaperChanger -p daemon.info "Current wallpaper : $random_wallpaper";
	# Sleep for 30 minutes
	sleep 5;
done
# The next line is basically useless.. You know, coding norms...
exit 0;
