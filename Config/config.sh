#!/bin/bash


OPTION=$(whiptail --title "Configuration" --menu "Choose your profile" 15 60 3 \
"1" "Professionnal" \
"2" "Train" \
"3" "Personal" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    case $OPTION in
      1 )
        echo "Pro";
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/pro.jpg;
        PARTITION=$(whiptail --inputbox "Please enter the path of your encrypted partition" 8 78 --title "Opening partition" 3>&1 1>&2 2>&3);
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if [[ ! -e "$PARTITION" ]]; then
              echo "Partition does not exist";
              exit 1;
            else
              if [[ ! -d /media/encryptedPartition ]]; then
                sudo mkdir /media/encryptedPartition;
              else
                echo -e "\e[34m[INFO] /media/encryptedPartition already exists, skipping directory creation...\e[0m";
              fi

              PASSWORD=$(whiptail --passwordbox "Please enter your encrypted partition password" 8 78 --title "$PARTITION password" 3>&1 1>&2 2>&3)
              exitstatus=$?
              if [ $exitstatus = 0 ]; then
                  echo "$PASSWORD" | sudo cryptsetup luksOpen "$PARTITION" encryptedPartition;
                  sudo mount /dev/mapper/encryptedPartition /media/encryptedPartition;
                  xdg-open /media/encryptedPartition/;
                  exit 0;
              else
                  exit 1;
              fi
            fi
            exit 0;
        else
            exit 1;
        fi
      ;;
      2 )
        echo "Train";
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/train.jpg;
        nohup libreoffice > /dev/null 2>&1 &
      ;;
      3 )
        echo "Perso";
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --set /usr/share/xfce4/backdrops/perso.png;
        xdg-open https://www.qwant.com;
      ;;
    esac
    exit 0;
else
    echo "Vous avez annulé";
    exit 1;
fi
