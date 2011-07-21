#!/usr/local/bin/bash

APP_NAME=`basename "$0"`
APP_DIR=$(readlink -f $0 | xargs dirname)
SUB_DIRECTORY="$APP_DIR/fonts"

### Include all functions
. "$APP_DIR/lib/BASICS"
. "$APP_DIR/lib/DETECTIONS"
. "$APP_DIR/lib/AUDIO"
. "$APP_DIR/lib/VIDEO"
. "$APP_DIR/lib/LOGO"
. "$APP_DIR/lib/SUB"
. "$APP_DIR/lib/MAIN"

### include ini
. "$APP_DIR/conf/INI"


### possibly overriding defaults conf
CONF_NAME=."$APP_NAME"rc
[ -r ~/"$CONF_NAME" ] && . ~/"$CONF_NAME"


        while getopts "f:T:l:o:e:c:s:S:b:DydYE" option
        do
            case "$option" in

                d)      DEBUG=1;;
                D)      DEBUG=2;;
                e)      EXTENTION="$OPTARG";;
                E)      EVALUTE=1;;
                f)      OUTPUT_FORMATS="$OPTARG";;
                l)      LOGOS_ADD="$OPTARG";;
                o)      OPERATION="$OPTARG";;
                s)      SS="$OPTARG";;
                S)      SUB="$OPTARG";;
                y)      OVERWRITE=1;;
                [?])    ERROR="Unknown option on the command line"; usage; exit 1;;

            esac
        done
        shift $(($OPTIND - 1))



	   ### TODO ###
	   # check_ouput_size "$FF_SIZE"
	   

		### $1 is a file ###
		if [[ -f $(realpath "${1}") ]]
		then
		
		SCAN_TYPE=1
		EXTENTION=$(echo $1  |grep -o  -E "\..{2,4}$")
		
		execute  "$(realpath "${1}")" 
		
		
		### $1 is a folder ###
		elif [[ -d  $(realpath "${1}") ]]
		then
		
		
		    SCAN_TYPE=2
		    DIRECTORY=$(realpath "${1}")
		
		    
		    for VIDEO  in `find ${DIRECTORY}  -name "*${EXTENTION}"`
		    do
		
		    SUBDIR=`basename "$VIDEO"`
		    SUBDIR=${SUBDIR%%${EXTENTION}}	

		      execute $VIDEO 

		    done

		else
        ERROR="ERROR: $1 is not a file or a folder"
        usage

		fi



exit 0
