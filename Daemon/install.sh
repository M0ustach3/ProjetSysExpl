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
sudo cp ./wallpaperChanger.sh /opt/;
# Copy the service into the systemd folder
sudo cp /tmp/daemonWallpaper.service /etc/systemd/system/;
# Reload the daemons
sudo systemctl daemon-reload;
# Start the daemon
sudo systemctl start daemonWallpaper;
# Delete the temp service file
rm /tmp/daemonWallpaper.service;
