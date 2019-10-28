#!/bin/bash

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
              echo -e "\e[31m[ERROR] Partition does not exist\e[0m";
              logger -t ConfigProfiles -p local0.err "Partition $PARTITION does not exist";
              exit 1;
            else
              # If the directory doesn't exist, create it
              if [[ ! -d /media/encryptedPartition ]]; then
                sudo mkdir /media/encryptedPartition;
              else
                echo -e "\e[34m[INFO] /media/encryptedPartition already exists, skipping directory creation...\e[0m";
                logger -t ConfigProfiles -p local0.info "/media/encryptedPartition already exists";
              fi
              # Get the password partition from whiptail input box
              PASSWORD=$(whiptail --passwordbox "Please enter your encrypted partition password" 8 78 --title "$PARTITION password" 3>&1 1>&2 2>&3)
              # Remember the last exit code of whiptail
              exitstatus=$?
              # If enter or OK was pressed
              if [ $exitstatus = 0 ]; then
                  # Put the password inside the cryptsetup open command
                  echo "$PASSWORD" | sudo cryptsetup luksOpen "$PARTITION" encryptedPartition;
                  # Mount the partition
                  sudo mount /dev/mapper/encryptedPartition /media/encryptedPartition;
                  # Open the folder with thunar
                  /usr/bin/thunar /media/encryptedPartition/;
                  # TODO make xdg-open work to open folder with user's default application (not necessarly thunar)
                  # xdg-open /media/encryptedPartition/;
              else
                  logger -t ConfigProfiles -p local0.warning "User cancelled password input";
                  exit 1;
              fi
            fi
        else
          logger -t ConfigProfiles -p local0.warning "User cancelled partition path input";
            exit 1;
        fi
        echo -e "\e[32m[SUCCESS] Successfully switched to PRO configuration\e[0m";
        logger -t ConfigProfiles -p local0.info "Successfully switched to PRO configuration";
      ;;
      # Case TRAIN
      2 )
        # Change the wallpaper
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/train.jpg;
        # Open libreoffice
        /usr/bin/libreoffice;
        # TODO make nohup work to detach libreoffice process from terminal (stop showing messages in the terminal)
        #nohup /usr/bin/libreoffice > /dev/null 2>&1 &
        echo -e "\e[32m[SUCCESS] Successfully switched to TRAIN configuration\e[0m";
        logger -t ConfigProfiles -p local0.info "Successfully switched to TRAIN configuration";
      ;;
      # Case PERSONAL
      3 )
        # Change the wallpaper
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/perso.png;
        # Open firefox
        /usr/bin/firefox https://www.qwant.com;
        # TODO make xdg-open work to open the link with default browser (not necessarly firefox)
        # xdg-open https://www.qwant.com;
        echo -e "\e[32m[SUCCESS] Successfully switched to PERSONAL configuration\e[0m";
        logger -t ConfigProfiles -p local0.info "Successfully switched to PERSONAL configuration";
      ;;
    esac
else
    logger -t ConfigProfiles -p local0.warning "User cancelled profile switch";
    exit 1;
fi
exit 0;
