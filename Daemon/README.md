# Daemon

daemon is a program meant to change the wallpaper every 30 mins. This does NOT YET activate itself at startup.

## Installation

This program does not need to be installed. It can be run inside this folder.

## Manual
To check the MAN page of Daemon, use :
```bash
man ./daemon.man
```
You can also check a short manual by typing :
```bash
./daemon.sh -h # Show the help
```

## Options
| Option        | Description           |
| :-------------: |:-------------:|
| `-h` or `--help`      | Show the help and exit |
|`-v`  or `--verbose`|Sets verbosity on or off. **HAS TO BE THE FIRST OPTION TO WORK**|
|`-l` or `--local`|Locally installs the daemon|
|`-g` or `--global`|Globally installs the daemon|
|`-u` or `--uninstall`|Uninstalls the daemon|


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

This was originally made by Pablo Bondia-Luttiau and Daël Mombo-Mombo

## License
[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
