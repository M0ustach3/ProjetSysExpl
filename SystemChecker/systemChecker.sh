#!/bin/bash

# Import the functions
source ../Library/Functions.sh;

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
	echo "\
	Usage : ./systemChecker.sh [OPTION...]
	-h, --help; Print the help and exit
	-u, --user; Print the current logged in user
	-s, --system; Print the system information
	-r, --resources; Print the resources usage
	-b, --boot; Print if critical boot errors were found
	-f, --firefox; What ? Firefox ?
	" | column -t -s ";"
}

SHORTOPTS="husrbf";
LONGOPTS="help,user,system,resources,boot,firefox";
PROGNAME=${0##*/};


ARGS=$(getopt -s bash --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $PROGNAME -- "$@" )

eval set -- "$ARGS"

# Handling options
while true; do
	case $1 in
		# Help case
		-h|--help)
			help;
			exit 0;
		;;
		# Case of the user
		-u|--user )
			user=$(whoami);
			echo -e "---> The current connected user is \e[36m$user\e[0m\n";
		;;
		# Case of the system info
		-s|--system )
			# Get processor type
			proc_type=$(hostnamectl | tail -n 1 | cut -d ':' -f2);
			# Get the OS
			os=$(lsb_release -ds);
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
		-r|--resources )
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
		-b|--boot )
			echo -e "---> Boot errors";
			# This counts the number of lines starting and ending with -- No entries --.
			number_of_entries=$(journalctl -xb -p crit | grep -E "^\-\- No entries \-\-$" | wc -l);
			if [ $number_of_entries -eq 1 ]; then
				echo -e "\t\e[32mNo boot errors were found ! :)\e[0m";
			else
				echo -e "\t\e[31mBoot errors were found, please check your boot logs\e[0m";
			fi
		;;
		# Wut ?
		-f | --firefox )
			logThis "info" "Portal to another dimension were opened.";
			nohup firefox about:robots > /dev/null 2>&1 &
		;;
		-- )
			shift;
			break;
		;;
		# All the other cases
		* )
			shift;
			break;
		;;
	esac
	shift
done

exit 0
