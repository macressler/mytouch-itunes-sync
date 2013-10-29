#!/bin/bash

# syncmusic version 1.1.0
# Copyright (C) 2013 by Shawn Rieger
# <riegersn@gmail.com>

# syncmusic comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
# are welcome to redistribute it under certain conditions.  See the GNU
# General Public Licence for details.

# syncmusic is a program used for syncing your iTunes music and playlists to a
# USB thumbdrive for use in a MyFordTouch music system.

sync_dir=/Volumes/ITUNES
ituns_dir=~/Music/iTunes/iTunes\ Media/Music/

usage() {
cat << EOF
syncmusic version 1.1.0
Copyright (C) 2013 by Shawn Rieger
<riegersn@gmail.com>

syncmusic comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
are welcome to redistribute it under certain conditions.  See the MIT Licence
for details.

syncmusic is a program used for syncing your iTunes music and playlists to a
USB thumbdrive for use in a MyFordTouch music system. rsync is utilized for 
syncing the library while exportip, a python script, is used for generating
m3u playlists from the iTunes Music Library.xml.

usage: syncmusic options

OPTIONS SUMMARY
 -h, --help			Display this.
 -s, --sync_dir path		Sets the path to sync music too. Defaults to /Volumes/ITUNES.
 -i, --itunes_dir path		Sets the location of your iTunes Music directory.

EOF
}

while test $# -gt 0
do
	case $1 in

		# Normal option processing
		-s | --sync_dir)
		 	sync_dir=$2
		  	;;
		-i | --ituns_dir)
		  	ituns_dir=$2
		  	;;
		-h | --help)
			usage
			exit
			;;
		# ...

		# Special cases
		--)
		  	break
		  	;;
		--*|-?)
			echo "Invalid option! ($1) See \"syncmusic --help\""
		  	exit
		  	;;

		# Split apart combined short options
		-*)
		  	split=$1
		  	shift
		  	set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
		  	continue
		  	;;

		# Done with options
		*)
		  	break
		  	;;
	esac

	shift
done

# make sure our main sync destination exists
if [ ! -d $sync_dir ]; then
	echo "Default sync_dir \"$sync_dir\" does not exist! Please specify new path. See \"syncmusic --help\""
	exit
fi

if [ ! -d $sync_dir/music ]; then
	mkdir $sync_dir/music
fi

cd $sync_dir/music;
rsync --ignore-existing --recursive --human-readable --progress --exclude=".DS_Store" "$ituns_dir" "$sync_dir/music"

cd ..
echo -en "\nremoving old playlists..."
rm *.m3u >/dev/null 2>&1
echo " done."

echo -en "generating new playlists..."
exportip $sync_dir
echo " done."

echo "sync completed!"
