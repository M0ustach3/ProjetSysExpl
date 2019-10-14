#!/bin/bash

cp /etc/crontab /tmp/customCronJob;

wallpaper_changer=$(pwd)

full_path="$wallpaper_changer/wallpaperChanger.sh"

echo "* * * * * bash $full_path > /dev/null 2>&1" >> /tmp/customCronJob;

cat /tmp/customCronJob;

crontab /tmp/customCronJob;

rm /tmp/customCronJob;