# OS Project

--------------------------------

## Description
This project is meant to be multiple exercises for the OS course at ESIEA Laval. These can be resumed with this :
- Backup (exercise 1) : backup container and partitions
- SystemChecker (exercise 2) : display computer resources and state
- Config (exercise 3) : change profiles at startup
- Daemon (exercise 4) : change wallpaper every 30 mins

| Exercise        | Points           |
| ------------- |:-------------:|
| Backup      | 7 |
| SystemChecker      | 3      |
| Config | 7      |
| Daemon | 3      |
| Help ? | +7  ?    |
| *TOTAL* | 20      |

--------------------------------
## Features
- Hosted on GitHub with precise organization for the project (Pull requests, multiple branches, explicit commit messages, etc.).
You can view a beautiful version of this README (and the others) on [GitHub](https://github.com/M0ustach3/ProjetSysExpl)
- MAN pages for every script
- Useful functions made in a different file (e.g : Library/Functions.sh)
- Fun wallpapers.
- Both short **AND** long options for most of the scripts
- Documented code / READMEs
- Respect of the Linux FHS and LSB (scripts placed under ```/opt```, temporary files are in ```/tmp```, etc.)
- Journalization with ```systemctl``` with tags and loglevels adjusted with the level of the info
- Signals are handled during the backup between partition and container. If the application is interrupted, the sensible partition and container are closed and unmounted. (Still a WIP for the other scripts)
- Verbose mode available for some scripts (Still a WIP for some scripts)
- Backups can be compressed
- Notifications using the XFCE desktop are sent to the user when an important information needs to be displayed
- Graphical interface for some of the script using whiptail (It's important to notice that Backup is **MEANT TO BE WITHOUT AN INTERFACE**, thus to ease scripting using crontab to automate backups for example)
- Last but not least, Easter Eggs. Love them.

--------------------------------
## Table Of Contents

1. [Badges](#badges)
2. [Visuals](#visuals)
3. [Roadmap](#roadmap)
4. [Important Notes](#important-notes)
5. [Prerequisites](#prerequisites)
6. [Installation](#installation)
7. [Usage](#usage)
8. [Support](#support)
9. [Contributing](#contributing)
10. [Authors](#authors)
11. [License](#license)
12. [Project Status](#project-status)

--------------------------------

## Badges
[![GPLv3 license](https://img.shields.io/github/license/M0ustach3/ProjetSysExpl?style=for-the-badge)](https://choosealicense.com/licenses/gpl-3.0/)

--------------------------------

## Visuals
_Coming soon..._

--------------------------------

## Roadmap
- Display notifications for the user :heavy_check_mark:
- Adapt with xdg-open to be fully compatible :heavy_multiplication_x:
- Provide option to compress backups :heavy_check_mark:
- Added MAN pages for every script that needs it (SystemChecker and Backup) :heavy_check_mark:
- Help can be shown with ```-h and --help``` for every script that needs it (SystemChecker and Backup):heavy_check_mark:
- Log actions in journal :heavy_check_mark:
- Detached window from profile chooser with nohup (create an orphan process) and redirect to `/dev/null` :heavy_multiplication_x:
- Check if a screen is available, if there is one, use `Zenity`, if there isn't, use `whiptail`. Default is `whiptail` for now :heavy_multiplication_x:

--------------------------------

## **Important notes**
### Backup
Will ask you for sudo password to open partitions, create directories, mount partitions and open containers. Do not panic.
### SystemChecker
Will not ask you anything, this can be run by a normal user.
### Config
Will ask you for root password to copy files in protected locations (e.g : ```/opt``` for example), create directories and mount partitions. **This is only the case in the PRO config as this config needs to open encrypted partition, this is not the case in the TRAIN and PERSONAL configs**.
### Daemon
Will ask you for root password to copy files in protected locations, reload daemons and start daemons with ```systemctl```.

--------------------------------

## Prerequisites
All the scripts were tested with Xubuntu 18.04 LTS. The system was up-to-date. To ensure that all the scripts will run correctly, you can run this command :
```bash
sudo apt-get update && sudo apt-get install cryptsetup rsync tar xfconf whiptail thunar libreoffice firefox bc sed
```
**THIS ASSUMES THAT YOU ALREADY INSTALLED VERACRYPT CONSOLE FROM THE OFFICIAL SITE**

--------------------------------

## Installation
### Backup
No need to install, just run ```./backup.sh -h``` to launch the program. **We strongly recommend to check out the manual before doing anything... RTFM with** ```man ./backup.man```
### SystemChecker
No need to install, just run ```./systemChecker.sh -h``` to launch the program. **We strongly recommend to check out the manual before doing anything... RTFM with** ```man ./systemChecker.man```
### Config
No need to install, just run ```./config.sh -h``` to launch the program. **We strongly recommend to check out the manual before doing anything... RTFM with** ```man ./config.man```
### Daemon
No need to install, just run ```./daemon.sh -h``` to launch the program. **We strongly recommend to check out the manual before doing anything... RTFM with** ```man ./daemon.man```

--------------------------------

## Usage
For the Usage, please check the corresponding READMEs in the folders :
- [Backup](./Backup/README.md)
- [SystemChecker](./SystemChecker/README.md)
- [Config](./Config/README.md)
- [Daemon](./Daemon/README.md)

--------------------------------

## Support
Meh, no support needed, there are no bugs in our scripts :innocent:

--------------------------------

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

--------------------------------

## Authors
Made with :heart: by Pablo Bondia-Luttiau and Daël Mombo-Mombo

--------------------------------

## License
This project is licensed under [GPLv3](https://choosealicense.com/licenses/gpl-3.0/).

--------------------------------

## Project Status
This project will no be maintained after 22/11/2019 (Project deadline).
