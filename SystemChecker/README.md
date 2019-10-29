# SystemChecker

SystemChecker is a program meant to show a recap of the state of the system.

## Installation

This program does not need to be installed. It can be run inside this folder.

## Manual
To check the MAN page of SystemChecker, use :
```bash
man ./systemChecker.man
```
You can also check a short manual by typing :
```bash
./systemChecker.sh -h # Show the help
```
## Options
| Option        | Description           |
| :-------------: |:-------------:|
| `-h`      | Show the help and exit |
|`-u`|Print the current connected user|
|`-s`|Print system info (OS, proc type, etc.)|
|`-r`|Print system resources (RAM and Swap usage)|
|`-b`|Tells if critical boot errors were found|


## Examples

```bash
./systemChecker -u -r #Show the user and the resources
./systemChecker -b -s #Show the critical boot errors and the system information
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

This was originally made by Pablo Bondia-Luttiau and Daël Mombo-Mombo

## License
[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
