#!/bin/bash

# Import the functions
source ../Library/Functions.sh;

# Prompt with whiptail
OPTION=$(whiptail --title "Configuration" --menu "Choose your profile" 15 60 3 \
"1" "Professionnal" \
"2" "Train" \
"3" "Personal" 3>&1 1>&2 2>&3)
# Remember the last exit code of whiptail
exitstatus=$?
# If enter or OK was pressed
if [ $exitstatus = 0 ]; then
    case $OPTION in
      # Case PRO
      1 )
        # Change the wallpaper
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/pro.jpg;
        # Get the text of the input box
        PARTITION=$(whiptail --inputbox "Please enter the path of your encrypted partition" 8 78 --title "Opening partition" 3>&1 1>&2 2>&3);
        # Remember the last exit code of whiptail
        exitstatus=$?
        # If enter or OK was pressed
        if [ $exitstatus = 0 ]; then
            # If the file does not exist
            if [[ ! -e "$PARTITION" ]]; then
              logThis "error" "Partition $PARTITION does not exist" "ConfigProfiles";
              exit 1;
            else
              # If the directory doesn't exist, create it
              if [[ ! -d /media/encryptedPartition ]]; then
                sudo mkdir /media/encryptedPartition;
              else
                logThis "info" "/media/encryptedPartition already exists";
              fi
              # Get the password partition from whiptail input box
              PASSWORD=$(whiptail --passwordbox "Please enter your encrypted partition password" 8 78 --title "$PARTITION password" 3>&1 1>&2 2>&3)
              # Remember the last exit code of whiptail
              exitstatus=$?
              # If enter or OK was pressed
              if [ $exitstatus = 0 ]; then
                  # Put the password inside the cryptsetup open command
                  # If the previous command failed, exit the program
                  if [[ $(echo "$PASSWORD" | sudo cryptsetup luksOpen "$PARTITION" encryptedPartition) -ne 0 ]]; then
                    logThis "error" "Error trying to open encrypted partition" "ConfigProfiles";
                    exit 1;
                  fi
                  # Mount the partition
                  # If the previous command failed, exit the program
                  if [[ $(sudo mount /dev/mapper/encryptedPartition /media/encryptedPartition) -ne 0 ]]; then
                    logThis "error" "Error trying to mount partition to /media/encryptedPartition" "ConfigProfiles";
                    exit 1;
                  fi
                  # Send a notification to the user
                  notify-send 'Config' 'Successfuly switched to PRO profile' --icon=dialog-information;
                  logThis "success" "Successfully switched to PRO configuration";
                  # Open the folder with thunar
                  /usr/bin/thunar /media/encryptedPartition/;
                  # TODO make xdg-open work to open folder with user's default application (not necessarly thunar)
                  # xdg-open /media/encryptedPartition/;
              else
                  logThis "warning" "User cancelled password input" "ConfigProfiles";
                  exit 1;
              fi
            fi
        else
            logThis "warning" "User cancelled partition path input" "ConfigProfiles";
            exit 1;
        fi
      ;;
      # Case TRAIN
      2 )
        # Change the wallpaper
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/train.jpg;
        # Send a notification to the user
        notify-send 'Config' 'Successfuly switched to TRAIN profile' --icon=dialog-information;
        logThis "success" "Successfully switched to TRAIN configuration";
        # Open libreoffice
        /usr/bin/libreoffice;
        # TODO make nohup work to detach libreoffice process from terminal (stop showing messages in the terminal)
        #nohup /usr/bin/libreoffice > /dev/null 2>&1 &
      ;;
      # Case PERSONAL
      3 )
        # Change the wallpaper
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/perso.png;
        logThis "success" "Successfully switched to PERSONAL configuration";
        # Send a notification to the user
        notify-send 'Config' 'Successfuly switched to PERSONAL profile' --icon=dialog-information;
        # Open firefox
        /usr/bin/firefox https://www.qwant.com;
        # TODO make xdg-open work to open the link with default browser (not necessarly firefox)
        # xdg-open https://www.qwant.com;
      ;;
    esac
else
    logThis "warning" "User cancelled profile switch" "ConfigProfiles";
    exit 1;
fi
exit 0;
