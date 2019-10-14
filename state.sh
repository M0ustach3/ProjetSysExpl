#!/bin/bash


# A custom banner to be printed in all cases
banner(){
	echo -e "\e[32m
#   ____  _  _  ____  ____  ____  _  _     ___  _  _  ____  ___  __ _  ____  ____ 
#  / ___)( \/ )/ ___)(_  _)(  __)( \\/ )   / __)/ )( \\(  __)/ __)(  / )(  __)(  _ \\
#  \\___ \\ )  / \\___ \\  )(   ) _) / \\/ \\  ( (__ ) __ ( ) _)( (__  )  (  ) _)  )   /
#  (____/(__/  (____/ (__) (____)\\_)(_/   \\___)\\_)(_/(____)\\___)(__\\_)(____)(__\\_)
\e[0m";
}

# Clear screen
clear
# Displaying the banner
banner

# Custom help function
help(){
	echo -e "Welcome to \e[32msystem checker\e[0m ! ";
	echo -e "\tThis is the help of the possible commands : ";
	echo -e "\t-h\tPrint this help and exit";
	echo -e "\t-u\tPrint the current logged in user";
	echo -e "\t-s\tPrint the system information";
	echo -e "The log tags of this program can be found with tag \"SystemChecker\" under /var/log/syslog or with journalctl"
	echo -e "";
}

# Custom usage function
usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}



# Handling options
while getopts ":husr" opt; do
	case ${opt} in
		# Help case
		h )
			help;
		;;
		# Case of the user
		u )
			user=$(who | cut -d ' ' -f 1 | head -n 1);
			echo -e "---> The current connected user is \e[36m$user\e[0m\n";
		;;
		# Case of the system info
		s )
			# Get processor type
			proc_type=$(hostnamectl | tail -n 1 | cut -d ':' -f2);
			# Get the OS
			os=$(hostnamectl | tail -n 3 | head -n 1 | cut -d ':' -f2);
			# Get the machine name
			machine_name=$(uname -n);
			
			# Get the date of the last update of the kernel
			kernel_date=$(uname -v | cut -d ' ' -f 5,4,8);
			echo -e "---> Recap of \e[36m$machine_name\e[0m : ";
			echo -en "\tType of processor : "
			# If the computer is a 64-bit proc
			if [ $proc_type = "x86-64" ]; then
				echo -en "\e[36m64-bit\e[0m";
			# If the computer is a 32-bit proc
			elif [ $proc_type = "x86" ]; then
				echo -en "\e[36m32-bit \e[31m(time to change, 2038 is coming...)\e[0m";
			else
				# Log an entry to syslog
				logger -t SystemChecker "The processor type wasn't recognized (using uname)";
				echo -en "\e[31mUNKNOWN\e[0m";
			fi
			echo -e ".";
			echo -e "\tOperating System : \e[36m$os\e[0m.";
			echo -e "\tDate of current kernel version : \e[36m$kernel_date\e[0m.";
			echo "";
		;;
		# Case of the resources
		r )
			all_data=$(free -m | sed -n '/ /s/ \+/ /gp' | tail -n 2 | cut -d ':' -f2 | tr '\n' ' ' );
			used_ram=$(echo $all_data | cut -d ' ' -f2);
			total_ram=$(echo $all_data | cut -d ' ' -f1);
			percentage_used_ram=$( expr 100 '*' $used_ram '/' $total_ram)
			echo "$percentage_used_ram% Ram";
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
exit 0
