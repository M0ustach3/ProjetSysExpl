#!/bin/bash

# Import the functions
source ../Library/Functions.sh;


# Custom help function
help(){
	echo -e "Welcome to \e[32mDaemon\e[0m ! ";
	echo "\
	Usage : ./daemon.sh [OPTION...]
	-h, --help; Print the help and exit
	-i, --install; Installs the daemon
  -u, --uninstall; Uninstalls the daemon
  -v, --verbose; Sets the verbose message output (HAS TO BE PUT AS THE FIRST OPTION)
	" | column -t -s ";"
}

function createUnit() {
  # Get the current connected user
  local me=$(whoami);
  echo "[Unit]
  Description=Service to change wallpaper
  After=display-manager.service

  [Service]
  Type=simple
  User=$me
  ExecStart=/bin/bash /opt/wallpaperChanger.sh
  Restart=always

  [Install]
  WantedBy=multi-user.target";
}

PROGNAME=${0##*/};
SHORTOPTS="hiuv";
LONGOPTS="help,install,uninstall,verbose";


ARGS=$(getopt -s bash --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $PROGNAME -- "$@" );

eval set -- "$ARGS";


while true; do
	case $1 in
        # Help case
    -h|--help)
      help;
      exit 0;
    ;;
    -v|--verbose)
      VERBOSE=1;
      shift;
    ;;
    -i|--install )

      # Echo all the service into the file, specifying the user who will run the service
      createUnit > /tmp/daemonWallpaper.service;

      # Copy the script into /opt (the best place according to the FHS)
      (( VERBOSE )) && logThis "info" "Copying files to /opt...";
      sudo cp ./wallpaperChanger.sh /opt/;
      # Copy the service into the systemd folder
      (( VERBOSE )) && logThis "info" "Copying files to /etc/systemd/system...";
      sudo cp /tmp/daemonWallpaper.service /etc/systemd/system/;
      # Reload the daemons
      (( VERBOSE )) && logThis "info" "Reloading daemons...";
      sudo systemctl daemon-reload;
      # Stop the previous daemon (if existing)
      (( VERBOSE )) && logThis "info" "Trying to stop daemon...";
      sudo systemctl stop daemonWallpaper.service;
      # Start the daemon
      (( VERBOSE )) && logThis "info" "Starting daemon...";
      sudo systemctl start daemonWallpaper.service;
      # Delete the temp service file
      (( VERBOSE )) && logThis "info" "Deleting temp files...";
      rm /tmp/daemonWallpaper.service;
			(( VERBOSE )) && logThis "success" "Successfuly installed Daemon";
      # Send a notification to the user
      notify-send 'Daemon' 'Successfuly installed Daemon ! Enjoy your changing wallpaper !' --icon=dialog-information;
      # Exit with code 0
      exit 0;
    ;;
    -u|--uninstall )
      # Remove files from /opt
      (( VERBOSE )) && logThis "info" "Removing files from /opt...";
      sudo rm /opt/wallpaperChanger.sh;
      # Stop the previous daemon (if existing)
      (( VERBOSE )) && logThis "info" "Trying to stop daemon...";
      sudo systemctl stop daemonWallpaper.service;
      # Remove .service file
      (( VERBOSE )) && logThis "info" "Removing service from /etc/systemd/system...";
      sudo rm /etc/systemd/system/daemonWallpaper.service;
      # Reload the daemons
      (( VERBOSE )) && logThis "info" "Reloading daemons...";
      sudo systemctl daemon-reload;
			(( VERBOSE )) && logThis "success" "Successfuly uninstalled Daemon";
      # Send a notification to the user
      notify-send 'Daemon' 'Successfuly uninstalled Daemon. Sorry to see you go :(' --icon=dialog-information;
      # Exit with code 0
      exit 0;
    ;;
    -- )
      shift;
      break;
      ;;
    # All the other cases
    * )
      shift;
      break;
      ;;
  esac
done
exit 0;
