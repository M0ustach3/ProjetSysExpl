# Backup

Backup is a program meant to create backups between Veracrypt container and encrypted partition.

## Installation

This program does not need to be installed. It can be run inside this folder.

## Manual
To check the MAN page of SystemChecker, use :
```bash
man ./backup.man
```
You can also check a short manual by typing :
```bash
./backup.sh -h # Show the help
```

## Options
| Option        | Description           |
| :-------------: |:-------------:|
| `-h`      | Show the help and exit |
|`-c`|Path of the Veracrypt container file (**MANDATORY**)|
|`-p`|Path of the encrypted partition (**MANDATORY**)|
|`-f`|FROM. This can either take _container_ or _partition_ as values|
|`-t`|TO. This can either take _container_ or _partition_ as values|
|`-s`|Compress into a .tar.gz file|



## Usage

```bash
./backup.sh -c /home/jp/container -p /dev/sda9 -f container -t partition #Copy the contents of the Veracrypt container located in /home/jp/container into the encrypted /dev/sda9 partition.
./backup.sh -p /dev/sdb5 -c /media/container -f partition -t container #Copy the contents of the partition /dev/sdb5 and put it inside the Veracrypt container located in /media/container
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

This was originally made by Pablo Bondia-Luttiau and Daël Mombo-Mombo

## License
[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
