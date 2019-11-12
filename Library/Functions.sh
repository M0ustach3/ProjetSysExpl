#!/bin/bash

################################################################

#                 This file is a library
# You can import the functions by typing `source Functions.sh`

################################################################

# Log function
function logThis() {
	case $1 in
		"info" )
			echo -e "\e[34m[INFO] \t--> $2\e[0m";
			;;
		"error" )
			echo -e "\e[31m[ERROR] $2\e[0m";
			logger -t ConfigProfiles -p local0.error "$2";
			;;
    "success" )
      echo -e "\e[32m[SUCCESS] \t--> $2\e[0m";
      ;;
    "warning" )
      echo -e "\e[33m[WARNING] $2\e[0m";
      logger -t ConfigProfiles -p local0.warning "$2";
      ;;
	esac
}
