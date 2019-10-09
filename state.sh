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
	echo -e "";
}

# Custom usage function
usage(){
	echo -e "\tUsage : $0 [arguments]";
	echo -e "\tYou can check [arguments] (the help) by typing $0 -h";
	echo -e "";
}



# Handling options
while getopts ":hus" opt; do
	case ${opt} in
		# Help case
		h )
			help;
		;;
		# Case of the user
		u )
			user=$(who | cut -d ' ' -f 1);
			echo -e "---> The current connected user is \e[36m$user\e[0m\n";
		;;
		# Case of the system info
		s )
			proc_type=$(uname -p);
			os=$(uname -o);
			machine_name=$(uname -n);
			kernel_date=$(uname -v | cut -d ' ' -f 5,4,8);
			kernel_version=$(uname -v | cut -d ' ' -f 1 | cut -d '-' -f 1 | cut -d '~' -f 2 | cut -d '.' -f 1,2);
			echo -e "---> Recap of \e[36m$machine_name\e[0m : ";
			echo -en "\tType of processor : "
			if [ $proc_type = "x86_64" ]; then
				echo -en "\e[36m64-bit\e[0m";
			elif [ $proc_type = "x86" ]; then
				echo -en "\e[36m32-bit \e[31m(time to change, 2038 is coming...)\e[0m";
			else
				echo -en "\e[31mUNKNOWN\e[0m";
			fi
			echo -e ".";
			echo -e "\tOperating System : \e[36m$os\e[0m.";
			echo -e "\tCurrent kernel version : \e[36m$kernel_version\e[0m.";
			echo -e "\tDate of current kernel version : \e[36m$kernel_date\e[0m.";
			echo "";
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
