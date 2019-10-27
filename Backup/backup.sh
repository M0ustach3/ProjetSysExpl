#!/bin/bash


# A custom banner to be printed in all cases
banner(){
	echo -e "\e[32m
   ######
   #     #    ##     ####   #    #  #    #  #####
   #     #   #  #   #    #  #   #   #    #  #    #
   ######   #    #  #       ####    #    #  #    #
   #     #  ######  #       #  #    #    #  #####
   #     #  #    #  #    #  #   #   #    #  #
   ######   #    #   ####   #    #   ####   #
\e[0m";
}

# Clear screen
clear
# Displaying the banner
banner

# Custom help function
help(){
	echo -e "Welcome to \e[32mBackup\e[0m ! ";
	echo -e "\tThis is the help of the possible options : ";
	echo -e "\t-h\tPrint this help and exit";
	echo -e "";
}

# Custom usage function
usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}

menu(){
	echo -e "\t1. Container to encrypted partition";
	echo -e "\t2. Encrypted partition to container";
}



backup(){
	# $1 must be container, $2 must be partition
	echo "Container path : $1";
	echo "Partition path : $2";
	echo "Compress ? $3";
}



################## Main menu
unset CHOICE

menu
read -p 'Choice (1 or 2) : ' choice;
if [[ "$choice" = "1" || "$choice" = "2" ]]; then
	# Handling options
	while getopts ":hacf:t:" opt; do
		case ${opt} in
			# Help case
			h )
				help;
				exit 0;
			;;
			c )
				COMPRESS=true;
			;;
			f )
				FROM=$OPTARG;
			;;
			t )
				TO=$OPTARG;
			;;
			# Unknown option
			\? )
				echo -e "Invalid option : \e[31m-$OPTARG\e[0m" 1>&2;
				usage;
				exit 1;
			;;
			# All the other cases
			* )
				usage;
				exit 1;
			;;
		esac
	done
	shift $((OPTIND -1))

	if [[ "$choice" = "1" ]]; then
		backup $FROM $TO $COMPRESS;
	else
		backup $TO $FROM $COMPRESS;
	fi

	exit 0;
else
	echo -e "\n\e[31mPlease select either 1 or 2.\e[0m";
	exit 1;
fi
