#!/usr/local/bin/bash

# config
INSTALL=0
REINSTALL=0


LAME_VERSION=3.98
FFMPEG_VERSION=17768
X264_VERSION=0.65
MPLAYER_VERSION=29242

usage() {
echo >&2 "Usage: `basename $0` [-i install] [-i reinstall]"
}


    while getopts "iI" option
    do
	case "$option" in
	  i)	INSTALL=1;;	
	  I)	REINSTALL=1;;
	[?])    usage
		exit 1;;
	esac
    done
    shift $(($OPTIND - 1))


### Define some colors:

red='\e[0;31m'
RED='\e[1;31m'

green='\e[0;32m'
GREEN='\e[1;32m'

yellow='\e[0;33m'
YELLOW='\e[1;33m'

NC='\e[0m' 

### get System
SYSTEM=$(uname)




		if [[ $SYSTEM  == "Linux" ]]
		then
		echo -e "$GREEN $SYSTEM $NC"
		. lib/install/linux_install.sh
		elif [[ $SYSTEM  == "FreeBSD" ]]
		then
			 echo -e "$GREEN $SYSTEM $NC"
		. lib/install/freebsd_install.sh
		else
		echo -e "$RED $SYSTEM not supported $NC"
		fi
