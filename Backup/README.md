# Backup

Backup is a program meant to create backups between Veracrypt container and encrypted partition.

## Installation

This program does not need to be installed. It can be run inside this folder. You can view the manual by typing

```bash
man ./backup.man
```

## Usage

```bash
./backup.sh -h #Show the help and exit
./backup.sh -c /home/jp/container -p /dev/sda9 -f container -t partition #Copy the contents of the Veracrypt container located in /home/jp/container into the encrypted /dev/sda9 partition.
./backup.sh -p /dev/sdb5 -c /media/container -f partition -t container #Copy the contents of the partition /dev/sdb5 and put it inside the Veracrypt container located in /media/container
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

This was originally made by Pablo Bondia-Luttiau and Daël Mombo-Mombo

## License
[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
