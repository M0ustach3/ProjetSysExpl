#!/bin/bash

# Get all the possible wallpapers from the system
wallpapers=("/usr/share/xfce4/backdrops"/*);
# Get a random wallpaper path from the previous array
random_wallpaper=$(printf "%s\n" "${wallpapers[RANDOM % ${#wallpapers[@]}]}");
# Get the PID of the current xfce session to use in cron
pid_xfce=$(pgrep xfce4-session)
# Export the correct environment variable to let cron update the wallpaper
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid_xfce/environ|cut -d= -f2-)
# Change the actual wallpaper of the computer
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set $random_wallpaper;