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
    -i|--install)
      (( VERBOSE )) && logThis "info" "Copying script to /opt...";
			# Copy the script to /opt
			# If the last exit code was not 0, quit the program (THANK YOU LENNAÏG)
			if [[ $(sudo cp ./configProfiles.sh /opt) -ne 0 ]]; then
				logThis "error" "Error trying to copy configProfiles.sh to /opt" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Copying .desktop file to /etc/xdg/autostart...";
      # Add the .desktop file inside the autostart folder of xdg (to be launched with xfce)
			# If the last exit code was not 0, quit the program (THANK YOU LENNAÏG)
			if [[ $(sudo cp ./configProfiles.desktop /etc/xdg/autostart/) -ne 0 ]]; then
				logThis "error" "Error trying to copy configProfiles.desktop to /etc/xdg/autostart" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Copying backgrounds to /usr/share/xfce4/backdrops/...";
      # Copy the backgrounds to the backdrops folder
			# If the last exit code was not 0, quit the program (THANK YOU LENNAÏG)
			if [[ $(sudo cp ./backgrounds/* /usr/share/xfce4/backdrops/) -ne 0 ]]; then
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
			# If the previous command failed, exit the program
			if [[ $(sudo rm /opt/configProfiles.sh) -ne 0 ]]; then
				logThis "error" "Error trying to remove /opt/configProfiles.sh" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Removing .desktop file from /etc/xdg/autostart...";
      # Add the .desktop file inside the autostart folder of xdg (to be launched with xfce)
			# If the last exit code was not 0, quit the program (THANK YOU LENNAÏG)
			if [[ $(sudo rm /etc/xdg/autostart/configProfiles.desktop) -ne 0 ]]; then
				logThis "error" "Error trying to remove /etc/xdg/autostart/configProfiles.desktop" "ConfigProfiles";
				exit 1;
			fi
      (( VERBOSE )) && logThis "info" "Removing backgrounds from /usr/share/xfce4/backdrops/...";
      # Copy the backgrounds to the backdrops folder
			# If the last exit code was not 0, quit the program (THANK YOU LENNAÏG)
			if [[ $(cd /usr/share/xfce4/backdrops/ && sudo rm -f pro.jpg train.jpg perso.png) -ne 0 ]]; then
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
