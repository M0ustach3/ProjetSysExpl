#!/bin/bash

# Import the functions
source ../Library/Functions.sh;


# Custom help function
help(){
	echo -e "Welcome to \e[32mDaemon\e[0m ! ";
	echo "\
	Usage : ./daemon.sh [OPTION...]
	-h, --help; Print the help and exit
	-l, --local; Installs the daemon in local mode
	-g, --global; Installs the daemon for all users
  -u, --uninstall; Uninstalls the daemon
  -v, --verbose; Sets the verbose message output (HAS TO BE PUT AS THE FIRST OPTION)
	" | column -t -s ";"
}

function createUnit() {
	if [[ -n "$1" ]]; then
		# Get the current connected user
		local me="";
		me=$(whoami);
		echo "[Unit]
		Description=Service to change wallpaper
		After=display-manager.service

		[Service]
		Type=simple
		User="$me"

		ExecStart=/bin/bash /opt/wallpaperChanger.sh
		Restart=always

		[Install]
		WantedBy=multi-user.target";
	else
		echo "[Unit]
		Description=Service to change wallpaper
		After=display-manager.service

		[Service]
		Type=simple

		ExecStart=/bin/bash /opt/wallpaperChanger.sh
		Restart=always

		[Install]
		WantedBy=multi-user.target";
	fi
}

PROGNAME=${0##*/};
SHORTOPTS="hiuvgl";
LONGOPTS="help,uninstall,verbose,global,local";


ARGS=$(getopt -s bash --options "$SHORTOPTS"  \
  --longoptions "$LONGOPTS" --name "$PROGNAME" -- "$@" );

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
    -g|--global )
			# Create a temp file
			$tempFile=$(mktemp);
      # Echo all the service into the file
      createUnit "global" > "$tempFile";
      # Copy the script into /opt (the best place according to the FHS)
      (( VERBOSE )) && logThis "info" "Copying files to /opt...";
      sudo cp ./wallpaperChanger.sh /opt/;
      # Copy the service into the systemd folder
      (( VERBOSE )) && logThis "info" "Copying files to /etc/systemd/system...";
      sudo cp"$tempFile" /etc/systemd/system/;
      # Reload the daemons
      (( VERBOSE )) && logThis "info" "Reloading daemons...";
      sudo systemctl --system daemon-reload;
      # Stop the previous daemon (if existing)
      (( VERBOSE )) && logThis "info" "Trying to stop daemon...";
      sudo systemctl --system stop daemonWallpaper.service;
      # Start the daemon
      (( VERBOSE )) && logThis "info" "Starting daemon...";
      sudo systemctl --system start daemonWallpaper.service;
      # Delete the temp service file
      (( VERBOSE )) && logThis "info" "Deleting temp files...";
      rm "$tempFile";
			(( VERBOSE )) && logThis "success" "Successfuly installed Daemon";
      # Send a notification to the user
      notify-send 'Daemon' 'Successfuly installed Daemon ! Enjoy your changing wallpaper !' --icon=dialog-information;
      # Exit with code 0
      exit 0;
    ;;
		-l|--local )
			# Create a temp file
			tempFile=$(mktemp);
			# Echo all the service into the file
			createUnit > "$tempFile";
			# If the directory doesn't exist
			if [[ ! -d ~/.local/share/systemd/user ]]; then
				(( VERBOSE )) && logThis "info" "Creating ~/.local/share/systemd/user";
					mkdir -p ~/.local/share/systemd/user
			fi
			# Copy the script into /opt (the best place according to the FHS)
			(( VERBOSE )) && logThis "info" "Copying files to /opt...";
			sudo cp ./wallpaperChanger.sh /opt/;
			# Copy the service into the systemd folder
			(( VERBOSE )) && logThis "info" "Copying files to ~/.local/share/systemd/user/...";
 			cp "$tempFile" ~/.local/share/systemd/user/daemonWallpaper.service;
			# Reload the daemons
			(( VERBOSE )) && logThis "info" "Reloading daemons...";
			systemctl --user daemon-reload;
			# Stop the previous daemon (if existing)
			(( VERBOSE )) && logThis "info" "Trying to stop daemon...";
			systemctl --user stop daemonWallpaper.service;
			# Start the daemon
			(( VERBOSE )) && logThis "info" "Starting daemon...";
			systemctl --user start daemonWallpaper.service;
			# Delete the temp service file
			(( VERBOSE )) && logThis "info" "Deleting temp files...";
			rm "$tempFile";
			(( VERBOSE )) && logThis "success" "Successfuly installed Daemon";
			# Send a notification to the user
			notify-send 'Daemon' 'Successfuly installed Daemon ! Enjoy your changing wallpaper !' --icon=dialog-information;
			# Exit with code 0
			exit 0;
		;;
    -u|--uninstall )
			if [[ -f /opt/wallpaperChanger.sh ]]; then
				# Remove files from /opt
				(( VERBOSE )) && logThis "info" "Removing files from /opt...";
				sudo rm /opt/wallpaperChanger.sh;
			fi
			if [[ -f /etc/systemd/system/daemonWallpaper.service ]]; then
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
			fi
			if [[ -f ~/.local/share/systemd/user/daemonWallpaper.service ]]; then
				# Stop the previous daemon (if existing)
				(( VERBOSE )) && logThis "info" "Trying to stop daemon...";
				systemctl --user stop daemonWallpaper.service;
				# Remove .service file
				(( VERBOSE )) && logThis "info" "Removing service from ~/.local/share/systemd/user...";
				rm ~/.local/share/systemd/user/daemonWallpaper.service;
				# Reload the daemons
				(( VERBOSE )) && logThis "info" "Reloading daemons...";
				systemctl --user daemon-reload;
				(( VERBOSE )) && logThis "success" "Successfuly uninstalled Daemon";
				# Send a notification to the user
				notify-send 'Daemon' 'Successfuly uninstalled Daemon. Sorry to see you go :(' --icon=dialog-information;
			fi
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
