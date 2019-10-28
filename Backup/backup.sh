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
	echo -e "\t-c [FILE]\tThe container path *MANDATORY*";
	echo -e "\t-p [FILE]\tThe partition path *MANDATORY*";
	echo -e "\t-f\tFROM, this can take either 'container' or 'partition' values";
	echo -e "\t-t\tTO, this can take either 'container' or 'partition' values";
	echo -e "";
}
# Custom usage function
usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}

backup(){
	# If the container path exists
	if [[ ! -e "$1" ]]; then
		echo -e "\e[31m[ERROR] Container path does not exist.\e[0m";
		logger -p local0.err -t Backup "Container path does not exist ($1)";
		exit 1;
	fi
	# If the partition path exists
	if [[ ! -e "$2" ]]; then
		echo -e "\e[31m[ERROR] Partition does not exist.\e[0m";
		logger -p local0.err -t Backup "Partition path does not exist ($2)";
		exit 1;
	fi
	# If the directory for the partition doesn't exist, create it
	if [[ ! -d /media/backupPartition ]]; then
		sudo mkdir /media/backupPartition;
	else
		echo -e "\e[34m[INFO] /media/backupPartition already exists, skipping directory creation...\e[0m";
		logger -p local0.info -t Backup "/media/backupPartition already exists";
	fi
	# If the directory for the container doesn't exist, create it
	if [[ ! -d /media/backupContainer ]]; then
		sudo mkdir /media/backupContainer;
	else
		echo -e "\e[34m[INFO] /media/backupContainer already exists, skipping directory creation...\e[0m";
		logger -p local0.info -t Backup "/media/backupContainer already exists";
	fi
	echo -e "\e[34m[INFO] \t--> Mounting container...\e[0m";
	# Mounting the container
	sudo veracrypt "$1" /media/backupContainer;
	echo -e "\e[34m[INFO] \t--> Opening partition...\e[0m";
	# Opening the Partition
	sudo cryptsetup luksOpen "$2" encryptedPartition;
	echo -e "\e[34m[INFO] \t--> Mounting partition...\e[0m";
	# Mounting the partition
	sudo mount /dev/mapper/encryptedPartition /media/backupPartition;


	############ Backup work
	if [[ "$choice" = "1" ]]; then
		# Container -> Partition
		if [[ ! -z "$3" ]]; then
			echo -e "\e[34m[INFO] \t--> Creating tar.gz file...\e[0m";
			tar --create -z -P --file=/media/backupPartition/archive.`date --rfc-3339=date`.tar.gz /media/backupContainer;
		else
			echo -e "\e[34m[INFO] \t--> Backing up...\e[0m";
			rsync -rav /media/backupContainer/* /media/backupPartition;
		fi
	else
		# Partition -> Container
		if [[ ! -z "$3" ]]; then
			echo -e "\e[34m[INFO] \t--> Creating tar.gz file...\e[0m";
			tar --create -z -P --file=/media/backupContainer/archive.`date --rfc-3339=date`.tar.gz /media/backupPartition;
		else
			echo -e "\e[34m[INFO] \t--> Backing up...\e[0m";
			rsync -rav /media/backupPartition/* /media/backupContainer;
		fi
	fi

	############ Backup end
	echo -e "\e[34m[INFO] \t--> Unmounting container...\e[0m";
	# Unmounting the container
	sudo veracrypt -d "$1";
	echo -e "\e[34m[INFO] \t--> Unmounting partition...\e[0m";
	# Unmount the partition
	sudo umount /media/backupPartition;
	# Close the partition
	sudo cryptsetup luksClose encryptedPartition;
	echo -e "\e[34m[INFO] \t--> Removing directories...\e[0m";
	# Remove the useless directories
	sudo rmdir /media/backupContainer;
	sudo rmdir /media/backupPartition;
}



################## Main menu
	# Handling options
	while getopts ":hc:p:f:t:s" opt; do
		case ${opt} in
			# Help case
			h )
				help;
				exit 0;
			;;
			# Container parameter
			c)
				CONTAINER=$OPTARG;
			;;
			# Partition parameter
			p )
				PARTITION=$OPTARG;
			;;
			# From parameter
			f )
				FROM=$OPTARG;
			;;
			# To parameter
			t )
				TO=$OPTARG;
			;;
			# Compress parameter
			s )
				COMPRESS="true";
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

# If the supplied options are either container -> partition OR partition -> container
if [[ ("$FROM" == "container" && "$TO" == "partition") || ("$FROM" == "partition" && "$TO" == "container") ]]; then
	if [[ "$FROM" == "container" && "$TO" == "partition" ]]; then
		choice="1";
	else
		choice="2";
	fi
	# Start the backup
	backup $CONTAINER $PARTITION $COMPRESS;
else
	echo -e "\e[31m[ERROR] -f and/or -t are non-existent or have a wrong syntax. Please check the manual or the help.\e[0m";
	exit 1;
fi
exit 0;