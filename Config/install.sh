#!/bin/bash

# Copy the config script inside /opt
sudo cp ./config.sh /opt;
# Add the .desktop file inside the autostart folder of xdg (to be launched with xfce)
sudo cp ./configProfiles.desktop /etc/xdg/autostart/;
# Copy the backgrounds to the backdrops folder
sudo cp ./backgrounds/* /usr/share/xfce4/backdrops/;
# Send a notification to the user
notify-send 'Config' 'Successfuly installed Config ! Check out the menu by rebooting !' --icon=dialog-information;
