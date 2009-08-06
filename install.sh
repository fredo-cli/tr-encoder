#!/usr/local/bin/bash

LAME_VERSION=3.98

FFMPEG_VERSION=17655
FFMPEG_VERSION_TXT="custom1"


## -r 14424 old freebsd
## svn -r 17727 = version 0.5 -> not good
## svn -r 17768 = last version before removing vhook -> not good
## svn -r 17792 =  version recommanded for libavfilter


X264_VERSION="0.65"

MPLAYER_VERSION=29418
MPLAYER_VERSION_TXT="custom1"


IMAGEMAGICK_VERSION="6.5.1"

# config
INSTALL=0
REINSTALL=0





# config
INSTALL=0
REINSTALL=0




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
