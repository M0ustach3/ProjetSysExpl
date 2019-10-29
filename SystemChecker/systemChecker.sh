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
	echo -e "Welcome to \e[32mSystemChecker\e[0m ! ";
	echo -e "\tThis is the help of the possible options : ";
	echo -e "\t-h\tPrint this help and exit";
	echo -e "\t-u\tPrint the current logged in user";
	echo -e "\t-s\tPrint the system information";
	echo -e "\t-r\tPrint the resources usage";
	echo -e "\t-b\tPrint if critical boot errors were found";
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
while getopts ":husrb" opt; do
	case ${opt} in
		# Help case
		h )
			help;
		;;
		# Case of the user
		u )
			user=$(whoami);
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
			# Get all the numbers from free, with formatted output
			all_data=$(free -m | sed -n '/ /s/ \+/ /gp' | tail -n 2 | cut -d ':' -f2 | tr '\n' ' ' );
			used_ram=$(echo $all_data | cut -d ' ' -f2);
			total_ram=$(echo $all_data | cut -d ' ' -f1);
			used_swap=$(echo $all_data | cut -d ' ' -f8);
			total_swap=$(echo $all_data | cut -d ' ' -f7);
			# Get the real percentage of RAM used
			#awk '{print $used_ram/$total_ram*100.0}';
			percentage_used_ram=$( echo "scale=4; 100*($used_ram / $total_ram)" | bc);
			# Get the integer corresponding to it (to test later on)
			integer_used_ram=$(( $((100 * $used_ram)) / $total_ram ));
			# Get the real percentage of swap used
			percentage_used_swap=$( echo "scale=4; 100*($used_swap / $total_swap)" | bc);
			# Get the integer corresponding to it (to test later on)
			integer_used_swap=$(( $((100 * $used_ram)) / $total_ram ));
			echo -e "---> Resources used";

			######################## RAM ######################

			# Green output (RAM percentage between 0 and 50)
			if [ $integer_used_ram -ge 0 -a $integer_used_ram -lt 50 ]; then
				echo -e "\t\e[32mRAM is used at $percentage_used_ram%\e[0m";
			# Yellow output (RAM percentage between 50 and 80)
			elif [ $integer_used_ram -ge 50 -a $integer_used_ram -lt 80 ]; then
				echo -e "\t\e[33mRAM is used at $percentage_used_ram%\e[0m";
			# Red output  (RAM percentage between 80 and 100)
			elif [ $integer_used_ram -ge 80 -a $integer_used_ram -le 100 ]; then
				echo -e "\t\e[31mRAM is used at $percentage_used_ram%\e[0m";
			# Default case output
			else
				echo -e "\t\e[31mFree RAM cannot be determined...\e[0m";
				logger -t SystemChecker "Free and Total RAM couldn't be determined correctly (using free). Got result $integer_used_ram";
			fi

			######################## Swap ######################

			# Green output (Swap percentage between 0 and 50)
			if [ $integer_used_swap -ge 0 -a $integer_used_swap -lt 50 ]; then
				echo -e "\t\e[32mSwap is used at $percentage_used_swap%\e[0m";
			# Yellow output (Swap percentage between 50 and 80)
			elif [ $integer_used_swap -ge 50 -a $integer_used_swap -lt 80 ]; then
				echo -e "\t\e[33mSwap is used at $percentage_used_swap%\e[0m";
			# Red output (Swap percentage between 80 and 100)
			elif [ $integer_used_swap -ge 80 -a $integer_used_swap -le 100 ]; then
				echo -e "\t\e[31mSwap is used at $percentage_used_swap%\e[0m";
			# Default case output
			else
				echo -e "\t\e[31mFree Swap cannot be determined...\e[0m";
				logger -t SystemChecker "Free and Total Swap couldn't be determined correctly (using free). Got result $integer_used_swap";
			fi
			echo "";
		;;
		b )
			echo -e "---> Boot errors";
			# This counts the number of lines starting and ending with -- No entries --.
			number_of_entries=$(journalctl -xb -p crit | grep -E "^\-\- No entries \-\-$" | wc -l);
			if [ $number_of_entries -eq 1 ]; then
				echo -e "\t\e[32mNo boot errors were found ! :)\e[0m";
			else
				echo -e "\t\e[31mBoot errors were found, please check your boot logs\e[0m";
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
exit 0
