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

backup(){
	# $1 must be container, $2 must be partition
	if [[ ! -e "$1" ]]; then
		echo "Container path does not exist.";
		exit 1;
	fi
	if [[ ! -e "$2" ]]; then
		echo "Partition does not exist.";
		exit 1;
	fi
	echo "Compress : $3";
	if [[ ! -d /media/backupPartition ]]; then
		sudo mkdir /media/backupPartition;
	else
		echo "/media/backupPartition already exists, please delete this directory to continue."
		exit 1;
	fi
	if [[ ! -d /media/backupContainer ]]; then
		sudo mkdir /media/backupContainer;
	else
		echo "/media/backupContainer already exists, please delete this directory to continue."
		exit 1;
	fi
	# Mounting the container
	sudo veracrypt "$1" /media/backupContainer;
	# Opening the Partition
	sudo cryptsetup luksOpen "$2" encryptedPartition;
	# Mounting the partition
	sudo mount /dev/mapper/encryptedPartition /media/backupPartition;


	############ Backup work

	if [[ "$choice" = "1" ]]; then
		# Container -> Partition
		rsync -rav /media/backupContainer/* /media/backupPartition;
	else
		# Partition -> Container
		rsync -rav /media/backupPartition/* /media/backupContainer;
	fi

	############ Backup end

	# Unmounting the container
	sudo veracrypt -d "$1";
	# Unmount the partition
	sudo umount /media/backupPartition;
	# Close the partition
	sudo cryptsetup luksClose encryptedPartition;

	# Remove the useless directories
	sudo rmdir /media/backupContainer;
	sudo rmdir /media/backupPartition;
}



################## Main menu
	# Handling options
	while getopts ":hc:p:f:t:" opt; do
		case ${opt} in
			# Help case
			h )
				help;
				exit 0;
			;;
			c)
				CONTAINER=$OPTARG;
			;;
			p )
				PARTITION=$OPTARG;
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

if [[ ("$FROM" == "container" && "$TO" == "partition") || ("$FROM" == "partition" && "$TO" == "container") ]]; then
	if [[ "$FROM" == "container" && "$TO" == "partition" ]]; then
		choice="1";
	else
		choice="2";
	fi
	backup $CONTAINER $PARTITION $COMPRESS;
else
	echo "-f and/or -t are non-existent or have a wrong syntax. Please check the manual or the help.";
	exit 1;
fi
exit 0;
