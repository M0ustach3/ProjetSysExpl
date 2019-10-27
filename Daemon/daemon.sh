#!/bin/bash
# Custom help function
help(){
	echo -e "Welcome to \e[32mDaemon\e[0m ! ";
	echo -e "\t-h Display this help and exit";
	echo -e "\t-i Install the cron job";
	echo -e "\t-r Remove the cron job";
	echo -e "";
}

# Custom usage function
usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}

# Get the current working directory
script_path=$(pwd)


# Handling options
while getopts ":hir" opt; do
	case ${opt} in
		# Help case
		h )
			help;
		;;
		# Install cron job
		i )
			# Make a copy of crontab to edit it
			cp /etc/crontab /tmp/customCronJob;
			# If a backup hasn't been made before
			if [ ! -f "$script_path/.crontab.bak" ]; then
				echo -e "\e[34m[INFO]\e[0m Backing up your actual crontab in .crontab.bak...";
				# Backup the current crontab before editing
				crontab -l > $script_path/.crontab.bak;
			else
				echo -e "\e[34m[INFO]\e[0m File .crontab.bak already exists, skipping backup.";
			fi
			# Append the script's name to the path
			full_path="$script_path/wallpaperChanger.sh"
			echo -e "\e[34m[INFO]\e[0m Modifying your crontab...";
			# Add a new cron job inside the temporary cron job (with redirection to avoid any messages on the terminal)
			echo "*/30 * * * * bash $full_path > /dev/null 2>&1" >> /tmp/customCronJob;
			# Load the new cron job from tmp
			crontab /tmp/customCronJob;
			# Delete the temporary cron job
			rm /tmp/customCronJob;
			echo -e "\e[32mSuccessfully modified your crontab ! Enjoy your rotating wallpaper :)\e[0m";
			exit 0;		
		;;
		# Restoring case
		r )
			echo "Trying to restore your crontab...";
			# If the file .crontab.bak exists
			if [ -f "$script_path/.crontab.bak" ]; then
				# If the file .crontab.bak is readable
				if [ -r "$script_path/.crontab.bak" ]; then
					# Update the crontab
					crontab $script_path/.crontab.bak;
					echo -e "\e[32mSuccessfully restored your crontab !\e[0m";
					exit 0;
				else
					echo -e "\e[31m[ERROR] The file .crontab.bak is not readable.\e[0m";
					logger -t Daemon "Failed to restore crontab. The file .crontab.bak is not readable.";
					exit 1;
				fi
			else
				echo -e "\e[31m[ERROR] The file .crontab.bak does not exist.\e[0m";
				logger -t Daemon "Failed to restore crontab. The file .crontab.bak does not exist.";
				exit 1;
			fi
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
exit 1;
