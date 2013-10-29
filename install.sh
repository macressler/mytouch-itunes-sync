#!/bin/bash

if [ "$(id -u)" == "0" ]; then
   echo "Do not run this script as root" 1>&2
   exit 1
fi

echo -ne "This script simply creates a link to local bin (~/bin). Would you like to continue? [y/n]: "
read result

if [ $result == 'n' ]; then
	echo "exit"
	exit
fi

if [ ! -d src ]; then
	echo "Missing src directory!"
	exit
fi

if [ ! -f src/syncmusic.sh ] || [ ! -f src/exportip.py ]; then
	echo "Missing source files from ./src!"
	exit
fi

if [ ! -d ~/bin ]; then
	mkdir ~/bin
fi

if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
	echo -n "missing bin in path, shall I add it? [y/n]: "
	read addbin

	if [ $addbin == 'y' ]; then
		
		bashprofile=""
		if [ ! -f ~/.profile ]; then
			bashprofile=~/.profile
		elif [ ! -f ~/.bash_profile ]; then
			bashprofile=~/.bash_profile
		else
			echo "unable to set path. please add ~/bin to your \$PATH variable."
		fi

		if [ ! -z $bashprofile ]; then
			echo -e "# add bin to path\nexport PATH=~/bin:\$PATH" >> $bashprofile
		fi
	fi

fi

chmod +x src/*

cd src; location=$(pwd)
cd ~/; bin=$(pwd)/bin

ln -s $location/syncmusic.sh $bin/syncmusic
ln -s $location/exportip.py $bin/exportip