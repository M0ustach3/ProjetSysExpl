# Get the current connected user
me=$(whoami);

# Echo all the service into the file, specifying the user who will run the service
echo "[Unit]
Description=Service to change wallpaper
After=display-manager.service

[Service]
Type=simple
User=$me
ExecStart=/bin/bash /opt/wallpaperChanger.sh
Restart=always

[Install]
WantedBy=multi-user.target" > /tmp/daemonWallpaper.service;

# Copy the script into /opt (the best place according to the FHS)

echo -e "\e[34m[INFO] Copying files to /opt...\e[0m";
sudo cp ./wallpaperChanger.sh /opt/;
# Copy the service into the systemd folder
echo -e "\e[34m[INFO] Copying files to /etc/systemd/system...\e[0m";
sudo cp /tmp/daemonWallpaper.service /etc/systemd/system/;
# Reload the daemons
echo -e "\e[34m[INFO] Reloading daemons...\e[0m";
sudo systemctl daemon-reload;
# Start the daemon
echo -e "\e[34m[INFO] Starting daemon...\e[0m";
sudo systemctl start daemonWallpaper;
# Delete the temp service file
echo -e "\e[34m[INFO] Deleting temp files...\e[0m";
rm /tmp/daemonWallpaper.service;
# Send a notification to the user
notify-send 'Daemon' 'Successfuly installed Daemon ! Enjoy your changing wallpaper !' --icon=dialog-information;
# Exit with code 0
exit 0;
