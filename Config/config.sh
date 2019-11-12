#!/bin/bash

# Import the functions
source ../Library/Functions.sh;

# Custom help function
help(){
	echo -e "Welcome to \e[32mConfig\e[0m ! ";
	echo "\
	Usage : ./config.sh [OPTION...]
	-h, --help; Print the help and exit
	-i, --install; Installs the daemon
  -u, --uninstall; Uninstalls the daemon
  -v, --verbose; Sets the verbose message output (HAS TO BE PUT AS THE FIRST OPTION)
	" | column -t -s ";"
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
    -i|--install)
      (( VERBOSE )) && logThis "info" "Copying script to /opt...";
      # Copy the config script inside /opt
      sudo cp ./configProfiles.sh /opt;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to copy configProfiles.sh to /opt" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Copying .desktop file to /etc/xdg/autostart...";
      # Add the .desktop file inside the autostart folder of xdg (to be launched with xfce)
      sudo cp ./configProfiles.desktop /etc/xdg/autostart/;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to copy configProfiles.desktop to /etc/xdg/autostart" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Copying backgrounds to /usr/share/xfce4/backdrops/...";
      # Copy the backgrounds to the backdrops folder
      sudo cp ./backgrounds/* /usr/share/xfce4/backdrops/;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to copy backgrounds to /usr/share/xfce4/backdrops" "ConfigProfiles";
				exit 1;
			fi
      # Send a notification to the user
      notify-send 'Config' 'Successfuly installed Config ! Check out the menu by rebooting !' --icon=dialog-information;
      if (whiptail --title "Reboot" --yesno "Would you like to reboot to check out the changes ? BE SURE TO CHECK OUT YOUR WORK BEFORE SELECTING YES" 8 78); then
          sudo systemctl reboot;
      fi
      exit 0;
    ;;
    -u|--uninstall)
      (( VERBOSE )) && logThis "info" "Removing script from /opt...";
      # Remove the script from opt
      sudo rm /opt/configProfiles.sh;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to remove /opt/configProfiles.sh" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Removing .desktop file from /etc/xdg/autostart...";
      # Add the .desktop file inside the autostart folder of xdg (to be launched with xfce)
      sudo rm /etc/xdg/autostart/configProfiles.desktop;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to remove /etc/xdg/autostart/configProfiles.desktop" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Removing backgrounds from /usr/share/xfce4/backdrops/...";
      # Copy the backgrounds to the backdrops folder
      cd /usr/share/xfce4/backdrops/ && sudo rm -f pro.jpg train.jpg perso.png;
			# If the previous command failed, exit the program
			if [[ "$?" -ne 0 ]]; then
				logThis "error" "Error trying to remove files from /usr/share/xfce4/backdrops/" "ConfigProfiles";
				exit 1;
			fi
      # Send a notification to the user
      notify-send 'Config' 'Successfuly uninstalled config. No more profiles for you :(' --icon=dialog-information;
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
