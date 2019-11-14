#!/bin/bash

# Import the functions
source ../Library/Functions.sh;


# Trap signals
trap 'handler' SIGHUP SIGINT SIGQUIT SIGABRT;

# Handler function for SIGHUP, SIGINT, SIGQUIT and SIGABRT
function handler() {
	logThis "error" "Backup was interrupted. Cleaning up..." "Backup";
	if [[ -n "$CONTAINER" ]] && [[ -n "$TEMPFOLDER" ]]; then
		unmountAll "$CONTAINER" "$TEMPFOLDER";
	elif [[ -n "$CONTAINER" ]]; then
		logThis "info" "Unmounting container...";
		# Unmounting the container
		sudo veracrypt -d "$CONTAINER" 2>&1 /dev/null;
	elif [[ -n "$TEMPFOLDER" ]]; then
		# Unmount the partition
		sudo umount "$TEMPFOLDER"/backupPartition;
		# Close the partition
		sudo cryptsetup luksClose encryptedPartition;
	fi
	if [[ -n "$TEMPFOLDER" ]]; then
		cleanup "$TEMPFOLDER";
	fi
	exit 1;
}

# Trap SIGUSR1 and SIGUSR2
trap 'boop' SIGUSR1 SIGUSR2;
# Boop
function boop() {
	echo "
	\$tart|ng NMap 5.21 ( http://Nmap.org ) at 2013-09-18 17:45 UTC
	Nmap \$cAn r3p0rt F0r ThUGL@B\$.cOm (74.207.244.221)
	Ho\$t 1z Up (0.071z laT3ncy).
	Not sh0wN: 998 cl0\$Ed p0rt\$
	POrT   ST4TE \$ERV!C3
	22/tcp opEn  Ssh
	80/tcP 0p3n  HtTp

	Nmap d0n3: 1 iP AddrESz (1 h0\$t Up) \$canNed !n 1.34 secondz
	";
	echo "B0oP";
	exit 1;
}

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

# Custom usage function
function usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}

# Mounting function
function mountAll() {
	logThis "info" "Mounting container...";
	# Mounting the container
	sudo veracrypt "$1" "$3"/backupContainer;
	logThis "info" "Opening partition...";
	# Opening the Partition
	sudo cryptsetup luksOpen "$2" encryptedPartition;
	logThis "info" "Mounting partition...";
	# Mounting the partition
	sudo mount /dev/mapper/encryptedPartition "$3"/backupPartition;

}

# Unmounting function
function unmountAll(){
	logThis "info" "Unmounting container...";
	# Unmounting the container
	sudo veracrypt -d "$1";
	logThis "info" "Unmounting partition...";
	# Unmount the partition
	sudo umount "$2"/backupPartition;
	# Close the partition
	sudo cryptsetup luksClose encryptedPartition;
}

# Cleanup function
function cleanup(){
	logThis "info" "Removing directories...";
	# Remove the temp directories
	# This expression is used to avoid removing of "/", security stuff
	rm -rf "${1:?}/";
}

# Create temp dirs function
function makeTempDir(){
	# Create a temp directory
	local folder=""
	folder=$(mktemp -d);
	# Otherwise, create directories and returns the path of the newly created temp dir
	mkdir "$folder"/backupPartition;
	mkdir "$folder"/backupContainer;
	echo "$folder";
}

# Backup function
backup(){
	# If the container path exists
	if [[ ! -e "$1" ]]; then
		logThis "error" "Container path does not exist" "Backup";
		exit 1;
	fi
	# If the partition path exists
	if [[ ! -e "$2" ]]; then
		logThis "error" "Partition path does not exist" "Backup";
		exit 1;
	fi

	# Get the path of created temp dir
	TEMPFOLDER=$(makeTempDir);

	# If the temp dir creation failed, exit
	if [[ -z "$TEMPFOLDER" ]]; then
		logThis "error" "Error trying to create a temp directory" "Backup";
		exit 1;
	fi

	# Mount partition and container
	mountAll "$1" "$2" "$TEMPFOLDER"

	############ Backup work
	if [[ "$choice" = "1" ]]; then
		# If the mounted container does not contain anything, exit
		if [[ -z "$(ls -A "$TEMPFOLDER"/backupContainer)" ]]; then
			logThis "error" "Nothing to backup :(" "Backup";
			exit 1;
		fi
		# Container -> Partition
		if [[ ! -z "$3" ]]; then
			logThis "info" "Creating tar.gz file...";
			sudo tar --create -z -P --file="$TEMPFOLDER"/backupPartition/archive."$(date --rfc-3339=date)".tar.gz "$TEMPFOLDER"/backupContainer;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up and compressed your data !' --icon=dialog-information;
		else
			logThis "info" "Backing up...";
			sudo rsync -av "$TEMPFOLDER"/backupContainer/* "$TEMPFOLDER"/backupPartition;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up your data !' --icon=dialog-information;
		fi
	else
		# If the mounted partition does not contain anything, exit
		if [[ -z "$(ls -A "$TEMPFOLDER"/backupPartition)" ]]; then
			logThis "error" "Nothing to backup :(" "Backup";
			exit 1;
		fi
		# Partition -> Container
		if [[ ! -z "$3" ]]; then
			logThis "info" "Creating tar.gz file...";
			sudo tar --create -z -P --file="$TEMPFOLDER"/backupContainer/archive."$(date --rfc-3339=date)".tar.gz "$TEMPFOLDER"/backupPartition;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up and compressed your data !' --icon=dialog-information;
		else
			logThis "info" "Backing up...";
			sudo rsync -av "$TEMPFOLDER"/backupPartition/* "$TEMPFOLDER"/backupContainer;
			# Send a notification to the user
			notify-send 'Backup' 'Successfuly backed up your data !' --icon=dialog-information;
		fi
	fi

	############ Backup end

	# Unmounting partition and container
	unmountAll "$1" "$TEMPFOLDER";

	# Cleanup the temp folder
	cleanup "$TEMPFOLDER";

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
	backup "$CONTAINER" "$PARTITION" "$COMPRESS";
else
	logThis "error" "-f and/or -t are non-existent or have a wrong syntax. Please check the manual or the help." "Backup";
	exit 1;
fi
exit 0;
