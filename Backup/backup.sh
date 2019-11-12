#!/bin/bash

# A custom banner to be printed in all cases
function banner(){
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
function help(){
	echo -e "Welcome to \e[32mBackup\e[0m ! ";
	echo -e "\tThis is the help of the possible options : ";
	echo -e "\t-h\tPrint this help and exit";
	echo -e "\t-c [FILE]\tThe container path *MANDATORY*";
	echo -e "\t-p [FILE]\tThe partition path *MANDATORY*";
	echo -e "\t-f\tFROM, this can take either 'container' or 'partition' values";
	echo -e "\t-t\tTO, this can take either 'container' or 'partition' values";
	echo -e "\t-s\tCompress into a .tar.gz compressed file";
	echo -e "";
}

# Basic info function
function printInfo() {
	echo -e "\e[34m[INFO] \t--> $1\e[0m";
}

# Basic error logging function
function printError() {
	echo -e "\e[31m[ERROR] $1\e[0m";
	logger -t Backup -p local0.error "$1";
}


# Custom usage function
function usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}

# Mounting function
function mountAll() {
	printInfo "Mounting container...";
	# Mounting the container
	sudo veracrypt "$1" `echo $3`/backupContainer;
	printInfo "Opening partition...";
	# Opening the Partition
	sudo cryptsetup luksOpen "$2" encryptedPartition;
	printInfo "Mounting partition...";
	# Mounting the partition
	sudo mount /dev/mapper/encryptedPartition `echo $3`/backupPartition;

}

# Unmounting function
function unmountAll(){
	printInfo "Unmounting container...";
	# Unmounting the container
	sudo veracrypt -d "$1";
	printInfo "Unmounting partition...";
	# Unmount the partition
	sudo umount `echo $2`/backupPartition;
	# Close the partition
	sudo cryptsetup luksClose encryptedPartition;
}

# Cleanup function
function cleanup(){
	printInfo "Removing directories...";
	# Remove the temp directories
	rm -rf `echo $1`/;
}

# Create temp dirs function
function makeTempDir(){
	# Create a temp directory
	local folder=$(mktemp -d);
	# If the last exit code was not 0, echo nothing as a path (THANK YOU LENNAÏG)
	if [[ "$?" -ne 0 ]]; then
		echo "";
	# Otherwise, create directories and returns the path of the newly created temp dir
	else
		mkdir `echo $folder`/backupPartition;
		mkdir `echo $folder`/backupContainer;
		echo $folder;
	fi
}

# Backup function
backup(){
	# If the container path exists
	if [[ ! -e "$1" ]]; then
		printError "Container path does not exist";
		exit 1;
	fi
	# If the partition path exists
	if [[ ! -e "$2" ]]; then
		printError "Partition path does not exist";
		exit 1;
	fi

	# Get the path of created temp dir
	TEMPFOLDER=$(makeTempDir);

	# If the temp dir creation failed, exit
	if [[ -z "$TEMPFOLDER" ]]; then
		printError "Error trying to create a temp directory";
		exit 1;
	fi

	# Mount partition and container
	mountAll $1 $2 $TEMPFOLDER

	############ Backup work
	if [[ "$choice" = "1" ]]; then
		# If the mounted container does not contain anything, exit
		if [[ -z "$(ls -A `echo $TEMPFOLDER`/backupContainer)" ]]; then
			printError "Nothing to backup :(";
			exit 1;
		fi
		# Container -> Partition
		if [[ ! -z "$3" ]]; then
			printInfo "Creating tar.gz file...";
			sudo tar --create -z -P --file=`echo $TEMPFOLDER`/backupPartition/archive.`date --rfc-3339=date`.tar.gz `echo $TEMPFOLDER`/backupContainer;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up and compressed your data !' --icon=dialog-information;
		else
			printInfo "Backing up...";
			sudo rsync -av `echo $TEMPFOLDER`/backupContainer/* `echo $TEMPFOLDER`/backupPartition;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up your data !' --icon=dialog-information;
		fi
	else
		# If the mounted partition does not contain anything, exit
		if [[ -z "$(ls -A `echo $TEMPFOLDER`/backupPartition)" ]]; then
			printError "Nothing to backup :(";
			exit 1;
		fi
		# Partition -> Container
		if [[ ! -z "$3" ]]; then
			printInfo "Creating tar.gz file...";
			sudo tar --create -z -P --file=`echo $TEMPFOLDER`/backupContainer/archive.`date --rfc-3339=date`.tar.gz `echo $TEMPFOLDER`/backupPartition;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up and compressed your data !' --icon=dialog-information;
		else
			printInfo "Backing up...";
			sudo rsync -av `echo $TEMPFOLDER`/backupPartition/* `echo $TEMPFOLDER`/backupContainer;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up your data !' --icon=dialog-information;
		fi
	fi

	############ Backup end

	# Unmounting partition and container
	unmountAll $1 $TEMPFOLDER;

	# Cleanup the temp folder
	cleanup $TEMPFOLDER;

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
	printError "-f and/or -t are non-existent or have a wrong syntax. Please check the manual or the help.";
	exit 1;
fi
exit 0;
