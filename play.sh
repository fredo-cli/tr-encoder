#!/bin/bash
DEBUG=0
DISPLAY=0
OVERWRITE=0
CROPDETECTION=1
TRY=""
LOGO_ADD=""

EXTENTION="org"
#EXTENTION="VOB"


Vert='\[\033[1;32m' 

# Define some colors first:
BLACK='\e[0;30m'

red='\e[0;31m'
RED='\e[1;31m'

green='\e[0;32m'
GREEN='\e[1;32m'

yellow='\e[0;33m'
YELLOW='\e[1;33m'

blue='\e[0;34m'
BLUE='\e[1;34m'

pink='\e[0;35m'
PINK='\e[1;35m'

cyan='\e[0;36m'
CYAN='\e[1;36m'

# 37 With

NC='\e[0m' # No Color


# Set up reasonable defaults.
APPNAME=`basename "$0"`
CONFNAME=."$APPNAME"rc
APP_DIR=`dirname "$0"`


# Import configuration file, possibly overriding defaults.
[ -r ~/"$CONFNAME" ] && . ~/"$CONFNAME"

# minimum duration of the video 
MINIMUM_DURATION=12


# minimum general biterate accepted
MINIMUM_BITERATE=500000
# minimum video biterate accepted
MINIMUM_VBITERATE=446000
# minimum Audio biterate accepted
MINIMUM_ABITERATE=64000


# qualite minimun de l'image
MINIMUM_BPF=0.06
# number of frames for the crop detection
CROP_FRAMES_S=250
CROP_FRAMES_L=500


MAXSIZE=480
FPS=12000/1001
    usage() {
	echo >&2 "Usage: `basename $0` [-f jpeg|sample|normal] [-d] [file|folder]"
    }

    while getopts "f:T:l:c:DydY" option
    do
	case "$option" in
	c)	   CROPDETECTION=$OPTARG;;	
	d)      DISPLAY=1;;	
	D)      DEBUG=1;;
	f)      OUTPUT_FORMAT="$OPTARG";;	
	l)	   LOGO_ADD="$OPTARG";;
	T)	   TRY="${OPTARG}-";;	
	y)      OVERWRITE=1;;
	Y)      OVERWRITE=2;;
	[?])    usage
		exit 1;;
	esac
    done
    shift $(($OPTIND - 1))




timeout(){
command=$1
# run $command in background, sleep for our timeout then kill the process if it is running
$command &
pid=$!
echo "sleep $2; kill $pid" | at now
wait $pid &> /dev/null
		if [ $? -eq 143 ]
		then
		echo "WARNING - command was terminated - timeout of $2 secs reached ($pid)$?."
		echo
		fi
}


    round16 () {
	echo "("$1" + 8) / 16 * 16" | bc
    }

    round8 () {
	echo "("$1" + 4) / 8 * 8" | bc
    }

    round2 () {
	echo "("$1" + 1) / 2 * 2" | bc
    }

    floor2 () {
	echo "("$1" ) / 2 * 2" | bc
    }


add_logo(){
				    
	   LOGO="${LOGO_DIR}/${LOGO_FILE}"
	    
	    echo -e "\\n${cyan}# Logo informations${NC}\\n"
	    

	   echo -e "LOGO_FILE=$LOGO_FILE\\nLOGO_PC_W=$LOGO_PC_W\\nLOGO_PC_X=$LOGO_PC_X\\nLOGO_PC_Y=$LOGO_PC_Y\\nLOGO_MODE=$LOGO_MODE\\nLOGO_TRESHOLD=$LOGO_TRESHOLD\\nLOGO_DURATION=$LOGO_DURATION\\n"
	    

	    # get the logo size
	    LOGO_W=$(identify -format %w $LOGO )
	    LOGO_H=$(identify -format %h $LOGO ) 
	    
	    # find the new size for the logo exemple 10% of the new size 
	    
	    LOGO_RESIZED_W=$(echo "($NEW_WIDTH) * $LOGO_PC_W / 100 "|bc)
	    LOGO_RATIO=$(echo "scale=2;$LOGO_W / $LOGO_RESIZED_W" |bc) 
	    LOGO_RESIZED_H=$(echo "$LOGO_H / $LOGO_RATIO "|bc)
	    echo -e "# Resize the logo to 10% (base on the new Width $NEW_WIDTH):\\t${LOGO_W}x${LOGO_H} -> ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
	  
	    # if the video is anamorphe -> the logo need a distortion to fit
	    
	    if [[  $DISTORTION != "1" ]]
	    then
	    LOGO_RESIZED_W=$(echo "$LOGO_RESIZED_W  $DISTORTION "|bc)
	    echo -e "# Add the Distortion ($DISTORTION):\\t ${LOGO_W}x${LOGO_H} -> ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
	    fi
	    
	    # create the resized logo
	    
	    convert "${LOGO}" -resize ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}\! -depth 8 $LOGO_RESIZED 
	    
	    # get the exact size of the resized logo (imagemagick do not respect the exactly thr -resize parameter)
	    LOGO_RESIZED_W=$(identify -format %w $LOGO_RESIZED )
	    LOGO_RESIZED_H=$(identify -format %h $LOGO_RESIZED )

	    echo -e "# The final size of the logo:\\t${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
 
	    
	    ### find the logo position 
	    
		# the position of the logo is base on the original size of the video
		
		if [[ $PAD -ne 0 ]]
		then
		echo "# The logo can not be on the paddind area"
		LOGO_X=$(echo "(($NEW_WIDTH * $LOGO_PC_X ) / 100) "|bc)
		LOGO_Y=$(echo "scale=3;(($NEW_HEIGHT  * $LOGO_PC_Y) / 100) - $PADTOP "|bc)

		else
		# no padding 
		#echo "scale=3;(($NEW_HEIGHT / 100 ) * $LOGO_PC_Y ) + $CROPTOP"
		LOGO_X=$(echo "scale=3;(($NEW_WIDTH  / 100) *  $LOGO_PC_X) + $CROPLEFT"|bc)
		LOGO_Y=$(echo "scale=3;(($NEW_HEIGHT / 100 ) * $LOGO_PC_Y ) + $CROPTOP"|bc)
		fi
    

	    # if the video is anamorphe -> the position need a ajustment base on the distortion
	    
	    if [[ $DISTORTION != "1" ]]
	    then
	    LOGO_X=$(echo "$LOGO_X  $DISTORTION "|bc)
	    fi
	    
	    
	    LOGO_X=${LOGO_X%.???}
	    LOGO_Y=${LOGO_Y%.???}
	    echo -e "# Position of the logo:\\tx = $LOGO_X Y = $LOGO_Y"
	    VHOOK=" -vhook \"/usr/local/lib/vhook/pip.so -f  ${DIRECTORY}/${SUBDIR}/${OUTPUT}.png -x $LOGO_X -y $LOGO_Y  -w $LOGO_RESIZED_W -h $LOGO_RESIZED_H  $LOGO_MODE   $LOGO_TRESHOLD -s $(echo "$SS  * $FPS "|bc) -e $(echo "($SS + $LOGO_DURATION) * $FPS "|bc) \" "
 	    #echo $VHOOK
}

get_vbitrate_mplayer () {	
# Return VBITERATE_MPLAYER=VBITERATE_MPLAYER=4324320   or  (90 %  $BITERATE_CALC )

#echo "get the video bitrate from mplayer"
VBITERATE_MPLAYER=`mplayer  $INPUT  -frames 0 -identify -quiet -vo null -ao null  2>&1 |grep  "ID_VIDEO_BITRATE=" |tail -1`   
VBITERATE_MPLAYER=${VBITERATE_MPLAYER#ID_VIDEO_BITRATE=}

		# check the value != null
		
		if [[ -z $VBITERATE_MPLAYER || $VBITERATE_MPLAYER == 0 ]] 
		then
		VBITERATE_MPLAYER=`echo "$BITERATE_CALC  * 100 / 90" |bc`
		fi


#echo "VBITERATE_MPLAYER=$VBITERATE_MPLAYER"
}


get_abitrate_mplayer () {	      
#echo  get the audio bitrate from mplayer
ABITERATE_MPLAYER=`mplayer  $INPUT  -frames 0 -identify -quiet -vo null -ao null  2>&1 |grep  "ID_AUDIO_BITRATE=" |tail -1`   ABITERATE_MPLAYER=${ABITERATE_MPLAYER#ID_AUDIO_BITRATE=}

		# check the value != null
		
		if [[   -z $ABITERATE_MPLAYER ||  $VBITERATE_MPLAYER == 0 ]] 
		then
		ABITERATE_MPLAYER=0
		fi

#echo "ABITERATE_MPLAYER=$ABITERATE_MPLAYER"
}


get_fps_mplayer () {	

# get the FPS from mplayer
FPS_MPLAYER=`mplayer  $INPUT  -frames 0 -identify -quiet -vo null -ao null  2>&1 |grep  "ID_VIDEO_FPS=" |tail -1`   
FPS_MPLAYER=${FPS_MPLAYER#ID_VIDEO_FPS=}
#echo "FPS_MPLAYER=$FPS_MPLAYER"
}


get_duration_mplayer () {	
# return  DURATION_MPLAYER=0 or DURATION_MPLAYER=345.78

# echo " get the DURATION from mplayer"
DURATION_MPLAYER=`mplayer  $INPUT  -frames 0 -identify -quiet -vo null -ao null  2>&1 |grep  "ID_LENGTH=" |tail -1`   

		# check the value != null
		if [[  ! -z $DURATION_MPLAYER ||  $DURATION_MPLAYER != 0 ]] 
		then
		DURATION_MPLAYER=${DURATION_MPLAYER#ID_LENGTH=}
		else
		DURATION_MPLAYER=0
		fi

#echo "DURATION_MPLAYER=$DURATION_MPLAYER"
}


get_general_infos () {	      
	      GENERAL_INFOS=""
	      FORMAT=""
	      FILE_SIZE=0
	      DURATION=0
	      BITERATE=0
	      VIDEO_COUNT=0
	      VIDEO_COUNT=0
	      
	      echo -e "\\n${BLUE}# General informations${NC}"

	     # get some general info about the video
	      GENERAL_INFOS=`mediainfo "--Inform=General;FORMAT='%Format%' FILE_SIZE=%FileSize% DURATION=%Duration% BITERATE=%OverallBitRate% VIDEO_COUNT=%VideoCount% AUDIO_COUNT=%AudioCount%" ${INPUT}`
	      #echo "$GENERAL_INFOS"
	      eval "$GENERAL_INFOS"


	      # display the file name and the size
	      
	      echo -e "$INPUT\\t#`echo "$FILE_SIZE / 1024 /1024 "| bc `MB\\n"
		 
		 
		 
		 
		 
		 # check if the video codec is supPorted by ffmpeg
		 
		FFMPEG_TEST=`ffmpeg -i "$INPUT" -sameq -vframes 1 -y "${DIRECTORY}/${SUBDIR}/test.jpg" 2>&1 `   
		#echo "$FFMPEG_TEST"
		
		 FFMPEG_TAIL="`echo "$FFMPEG_TEST"|tail  -n 1   `"	
		 FFMPEG_HEAD="`echo "$FFMPEG_TEST"| head -25 `"
		 FFMPEG_VIDEO_YES=`echo "$FFMPEG_TAIL"|grep -o "^video:[1-9][0-9]*kB" `
		 
		  if [[ ! -z $FFMPEG_VIDEO_YES ]]
		  then
		  echo -e "${GREEN}# Video codec supported by ffmpeg${NC} "
		  #echo $FFMPEG_YES
		  else
		  
		  ERROR="# ERROR: Video codec not supported by ffmpeg"

				  if [[ $DEBUG == 1 ]]
				  then

				  echo "$FFMPEG_HEAD"
				  fi 

		  echo -e "${RED}${ERROR}${NC}\\n${FFMPEG_TAIL}"
		  echo -e ${ERROR} ${FFMPEG_HEAD}  >> ${DIRECTORY}/${OUTPUT}.err    
			  
		  fi
				
				

				
		
				
		 
		 # check if the AUDIO  codec is supported by ffmpeg
		 
		FFMPEG_TEST=`ffmpeg -i "$INPUT" -t 1 -ac 2 -y "${DIRECTORY}/${SUBDIR}/test.mp3" 2>&1 `   
		#echo "$FFMPEG_TEST"
		
		 FFMPEG_TAIL="`echo "$FFMPEG_TEST"|tail  -n 1   `"	
		 #echo $FFMPEG_TAIL
		 FFMPEG_HEAD="`echo "$FFMPEG_TEST"| head -25 `"
		 FFMPEG_AUDIO_YES=`echo "$FFMPEG_TAIL"|grep -o " audio:[1-9][0-9]*kB" `
		 
		  if [[ ! -z $FFMPEG_AUDIO_YES ]]
		  then
		  echo -e "${GREEN}# Audio codec supported by ffmpeg${NC} "
		  #echo $FFMPEG_YES
		  else
		  
		  ERROR="# ERROR: Audio codec not supported by ffmpeg"

				  if [[ $DEBUG == 1 ]]
				  then

				  echo "$FFMPEG_HEAD"
				  fi 

		  echo -e "${RED}${ERROR}${NC}\\n${FFMPEG_TAIL}"
		  echo -e ${ERROR} ${FFMPEG_HEAD}  >> ${DIRECTORY}/${OUTPUT}.err    
		  
		  fi
		  
		# check if video can be read with mplayer  
		  
		ID_VIDEO_ID=0
		ID_AUDIO_ID=0
		ID_FILENAME=""
 
		  
		  
				
		ID_LENGTH=0
		ID_DEMUXER="" 

		ID_VIDEO_FORMAT=""
		ID_VIDEO_WIDTH=0
		ID_VIDEO_HEIGHT=0
		ID_VIDEO_ASPECT=0
		
		ID_VIDEO_CODEC=""
		ID_VIDEO_BITRATE=0
		ID_VIDEO_FPS=0
		
		ID_AUDIO_FORMAT=
		ID_AUDIO_CODEC=""
		ID_AUDIO_BITRATE=0
 		ID_AUDIO_RATE=0
		ID_AUDIO_BITRATE=0
 		ID_AUDIO_NCH=0		
								  
	
		
		MPLAYER_TEST=`mplayer -identify "$INPUT" -quiet -frames 1 -vo null -ao null  2>&1 /dev/nul | grep - -e "ID_VIDEO" -e "ID_AUDIO_" -e "ID_LENGTH" -e "ID_DEMUXER" `  
		
		if [[ $DEBUG == 1 ]]
		then
		echo "$MPLAYER_TEST"
		fi 		
		echo -e "${MPLAYER_TEST}" > ${DIRECTORY}/${SUBDIR}/mplayer.txt	
		eval $MPLAYER_TEST
		
		
		if [[ ! -z $ID_VIDEO_CODEC ]]
		then
		MPLAYER_VIDEO_TEST=1
		echo -e "${GREEN}# Video codec supported by mplayer\\t$ID_VIDEO_CODEC${NC}"

		echo $ID_VIDEO_CODEC >> ./config/VCODEC_MPLAYER
		else
		MPLAYER_VIDEO_TEST=0		
		ERROR="# ERROR: Video codec not supported by mplayer"
		echo -e "${RED}${ERROR}${NC}\\n"
		echo -e ${ERROR}  >> ${DIRECTORY}/${OUTPUT}.err 
		fi

		if [[ ! -z $ID_AUDIO_CODEC ]]
		then
		MPLAYER_AUDIO_TEST=1
		echo -e "${GREEN}# Audio codec supported by mplayer\\t$ID_AUDIO_CODEC${NC}"
		echo $ID_AUDIO_CODEC >> ./config/ACODEC_MPLAYER
		else
		MPLAYER_AUDIO_TEST=0
		ERROR="#ERROR: Audio codec not supported by mplayer"
		echo -e "${RED}${ERROR}${NC}\\n"
		fi






	      # check the container FORMAT

	      if [[ ! -z ` grep  "^${FORMAT}$" ./config/FORMATS ` ]]
	      then
	      echo -e "FORMAT=${GREEN}$FORMAT${NC}"
	      else
	      echo -e "FORMAT=${YELLOW}$FORMAT${NC}"
	      fi





	      # check the duration of the video	 
		 
		 # duration null try with mplayer 
	      if [[ -z $DURATION ||  $DURATION == 0 ]]
		 then
		 get_duration_mplayer
		 
		 # set DURATION to  DURATION_MPLAYER value  in miliseconds
		 DURATION=`echo "$DURATION_MPLAYER * 1000"|bc `
		 # set DURATION_S to  DURATION_MPLAYER value  in seconds
		 DURATION_S=${DURATION_MPLAYER%.??}
		 else		 
	      DURATION_S=`echo "$DURATION / 1000"|bc`
		 fi
		 
		 
	      if [[  $DURATION_S -lt  $MINIMUM_DURATION ]] 
	      then
	      ERROR="ERROR: Duration of the video is ($DURATION_S secondes).The minimun duration for a video is ($MINIMUM_DURATION secondes)  "
	      echo -e ${RED}${ERROR}${NC}
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err   
	      else
	      echo -e "DURATION=${GREEN}$DURATION_S${NC}"
	      CROPSTART=`echo ${DURATION_S} / 2|bc`
	      fi


	      
	      # Get the general bitrate by calculation
	      
	      BITERATE_CALC=$(echo "scale=10;$FILE_SIZE * 8 / ($DURATION/1000)"|bc)
	      BITERATE_CALC=${BITERATE_CALC%.*}
		 
		 
	      # Check the general bitrate of thevideo
	      
	      if [[ ! -z $BITERATE && ! -z $BITERATE_CALC && $BITERATE == $BITERATE_CALC  ]]
	      then
	      FF_BITERATE=$(echo "$BITERATE / 1000 "|bc)
	      FF_BITERATE=${FF_BITERATE%.*}k
		 
				# check the size
				if [[ $BITERATE -gt $MINIMUM_BITERATE ]]
				then
				echo -e "BITERATE=${GREEN}$BITERATE${NC}\\t$FF_BITERATE"
				else
				WARNING="WARNING: General biterate  of the video is ( $BITERATE / $FF_BITERATE ).The minimun biterate for a $FORMAT video is ($MINIMUM_BITERATE)  "
				echo -e ${PINK}${WARNING}${NC}
				echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
				fi
		 
		 # BITERATE not detected from mediainfo take the BITERATE_CALC instead
		 elif [[  -z $BITERATE && ! -z $BITERATE_CALC ]]
	      then
		 BITERATE=$BITERATE_CALC
		 FF_BITERATE=$(echo "$BITERATE / 1000 "|bc)
	      FF_BITERATE=${FF_BITERATE%.*}k

				# check the size
				if [[ $BITERATE -gt $MINIMUM_BITERATE ]]
				then
				echo -e "BITERATE=${GREEN}$BITERATE${NC}\\t$FF_BITERATE\\t(calc)"
				else
				WARNING="WARNING: General biterate  of the video is ( $BITERATE / $FF_BITERATE ).The minimun biterate for a $FORMAT video is ($MINIMUM_BITERATE)  "
				echo -e ${PINK}${WARNING}${NC}
				echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
				fi

	      fi



	      # Chek the number of video stream
	      
	      if [[ $VIDEO_COUNT == 1 ]] 
	      then
	      echo -e "VIDEO_COUNT=${GREEN}$VIDEO_COUNT${NC}"
	      else
	      ERROR="ERROR: 1 video stream is needed (Detection: $VIDEO_COUNT)."
	      echo -e ${RED}${ERROR}${NC}
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err 
	      fi
	      
	      # Chek the number of audio stream	      
	      
	      if [[ $AUDIO_COUNT == 1 ]] 
	      then
	      echo -e "AUDIO_COUNT=${GREEN}$AUDIO_COUNT${NC}"
		 elif [[ $AUDIO_COUNT -gt 1 ]]
		 then
		 WARNING="WARNING: More than 1 audio stream is detected ($AUDIO_COUNT)"
	      echo -e ${PINK}${WARNING}${NC}
	      echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err 
	      else
	      ERROR="ERROR: 1 audio stream is needed (Detection: $AUDIO_COUNT)"
	      echo -e ${RED}${ERROR}${NC}
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err 
	      fi
}

get_video_infos () {

	      VIDEO_INFOS=""
	      
	      FPS=0
		 FPS_MODE=""
	      INTERLACED=""
	      DEINTERLACE=""
	      DELAY=0
	      WIDTH=0
	      HEIGHT=0
	      ASPECT=0
		 VFORMAT=""
		 VCODEC=""
		 
	      
	      VIDEO_INFOS=`mediainfo "--Inform=Video;FPS_MODE=%FrameRate_Mode% VCODEC='%Codec%' VDURATION=%Duration% VBITERATE=%BitRate% FPS=%FrameRate% DELAY=%Delay%  INTERLACED=%ScanType% WIDTH=%Width% HEIGHT=%Height%  VFORMAT='%Format%'  " ${INPUT}`
	      #echo $VIDEO_INFOS
	      eval $VIDEO_INFOS
	      echo -e "\\n${cyan}# Video informations${NC}"
	      
	      
	      # Check the FPS (Frame Rate)
	      
		 # standard
	      if [[ ! -z ` grep  "^${FPS}$" ./config/FPS ` ]]
	      then
		 FPS=${FPS%.000}
	      echo -e "FPS=${GREEN}$FPS${NC}"
	      else
	      # round the FPS 
	      FF_FPS=` echo $FPS | awk '{printf("%d\n",$1 + 0.5)}' `
		 
			 # variabre frame rate
			 if [[ $FF_FPS == 24 ||  $FF_FPS == 25 || $FF_FPS == 30 ]]
			 then
			 echo -e "FPS=${GREEN}$FF_FPS${NC} ${FPS_MODE}\\t$FF_FPS"
			 # bad
			 else
				    
				    # try to get it from mplayer
				    get_fps_mplayer
				    FPS=$FPS_MPLAYER
				    # check again
				    
				    # standard
				    if [[ ! -z ` grep  "^${FPS}$" ./config/FPS ` ]]
				    then
				    FPS_MPLAYER=${FPS%.000}
				    echo -e "FPS=${GREEN}$FPS${NC}\\t(from mplayer)"
				    else
				    
				    # round the FPS 

				    FF_FPS=` echo $FPS | awk '{printf("%d\n",$1 + 0.5)}' `
				    
						    # good
						    if [[ $FF_FPS == 24 ||  $FF_FPS == 25 || $FF_FPS == 30 ]]
						    then

						    echo -e "FPS=${GREEN}$FF_FPS${NC} ${FPS_MODE}\\t$FPS\\t(from mplayer)"
						    # bad
						    else
						    echo -e  "FPS=${RED}$FF_FPS ${FPS_MODE}\\t$FPS${NC}"
						    fi
				    fi
				    
				    
			 fi
		  #[[ $FF_FPS == 23  ]] && FF_FPS=24
		  fi	        
	      
		 
		 
		 
		  # check the  VFORMAT

	      if [[ ! -z ` grep  "^${VFORMAT}$" ./config/VFORMATS ` ]]
	      then
	      echo -e "VFORMAT=${GREEN}$VFORMAT${NC}"
	      else
	      echo -e "VFORMAT=${YELLOW}$VFORMAT${NC}"
	      fi
		 		 
		 
		 
	      # check the  VCODEC
		 
		 VCODEC_INFOS=`grep "^${VCODEC}|*" ./config/VCODECS `

	      if [[ ! -z $VCODEC_INFOS ]]
	      then
			   # Checkc the codec compatibility
			   VCODEC_COMP=`echo "$VCODEC_INFOS" | awk -F "|" '{ print $2 }' `

			   VCODEC_TEXT=`echo "$VCODEC_INFOS" | awk -F "|" '{ print $3 }' `
			   
			   case $VCODEC_COMP in
			   1)echo -e  "VCODEC=${GREEN}${VCODEC} ${NC}\\t$VCODEC_TEXT";;
			   2)echo -e  "VCODEC=${YELLOW}${VCODEC} ${NC}\\t$VCODEC_TEXT";;
			   3)echo -e  "VCODEC=${PINK}${VCODEC} ${NC}\\t$VCODEC_TEXT";;
			   4)echo -e  "VCODEC=${RED}${VCODEC} ${NC}\\t$VCODEC_TEXT";;
			   esac
		 
	      
	      else
		 # codec not defined
	      echo -e "VCODEC=${YELLOW}${VCODEC}${NC}\\tCodec undefined!"
	      fi
		 
		 
		 
		 




	      # check the size
	      
	      SIZE="${WIDTH}x${HEIGHT}"
	      SIZE_INFOS=`grep  "^${SIZE}," ./config/SIZES`
	      #echo $SIZE_INFOS
	      if [[ ! -z $SIZE_INFOS  ]]
	      then
	      SIZE_INFOS=`echo $SIZE_INFOS | awk  -F , '{ print $2"  "$3"  "$4  }'`
	      echo -e "SIZE=${GREEN}$SIZE${NC}\\t$SIZE_INFOS"
	      else
	      echo -e "SIZE=${YELLOW}$SIZE${NC}"
	      fi
	      
	      
	      
	     # Check the RATIO  
	      
	      RATIO=`echo "scale=3;${WIDTH}/${HEIGHT} "|bc`
# 		 RATIO=`echo $RATIO | awk '{printf("%d\n",$1 + 0.5)}'`
# 		 RATIO=`echo "scale=2;${RATIO}/ 100"|bc`
	      if [[ ! -z ` grep  "${RATIO%?}" ./config/RATIOS ` ]]
	      then
	      echo -e "RATIO=${GREEN}${RATIO%?}${NC}"
	      else
 	      echo -e "RATIO=${YELLOW}${RATIO%?pal}${NC}"
	      fi
	      	     


	      		 
		# Get the aspect ratio or DAR (mplayer)
	      
		 DAR=${ID_VIDEO_ASPECT%??}

		 # remove somm eexecptions
	      if [[ $DAR == 1.75 ]] 
		 then 
		 DAR=0
		 ID_VIDEO_ASPECT=0
		 fi
		 
	      [[ $DAR == 1.00 ]]  && DAR=0
		 [[  $DAR == 0.00  ]] && DAR=0 
		 [[  $DAR == ${RATIO%?}  ]] && DAR=0 
		 
		 if [[ $DAR == 1.77 || $DAR == 1.33 || $DAR == 0 ]]
		 then
	      echo -e "DAR=${GREEN}${DAR}${NC}"
		 elif [[ $DAR == 2.21 ]]
		 then
	      echo -e "DAR=${YELLOW}${DAR}${NC}"		 
		 else
	      echo -e "DAR=${RED}${DAR}${NC}"		 
		 fi

	      

	      # Check the PAR (Pixel aspect Ratio)
		  	      
		PAR=`echo "scale=3; $ID_VIDEO_ASPECT / $RATIO" |bc`
		 # case NULL
		 if [[  $PAR == 1.000 ]]
	      then
		 FF_PAR=1
		 PAR=1		 
	      echo -e "PAR=${GREEN}$PAR${NC}"
		 
	      # standard 1.77 etc
		 elif [[ ! -z ` grep  "^${PAR}$" ./config/PAR ` ]]
	      then
	      echo -e "PAR=${GREEN}$PAR${NC}"
 		 FF_PAR=$PAR
	      else
		 
# 			 # case like 0.006 0.000 1.004 
# 			 FF_PAR=`echo "($PAR * 100) / 100 "|bc`
# 			 if [[ $FF_PAR  -gt  0  ]]
# 			 then 
# 			 echo -e "PAR=${GREEN}$FF_PAR${NC}\\t$PAR\\tmplayer$ID_VIDEO_ASPECT" 
# 			 
# 			 # case like 2.4
# 			 else
			 FF_PAR=$PAR
		 	 echo -e "PAR=${RED}$PAR${NC}"
#			 fi  
	      fi


	      
	      # Check the VBITERATE
	      
		 # VBITERATE is null, try with mplayer
	      if [[  -z $VBITERATE || $VBITERATE == 0 ]]
	      then
		 get_vbitrate_mplayer
		 VBITERATE=$VBITERATE_MPLAYER
		 fi
		 
		 # check the size of VBITERATE
			 
		 # VBITERATE is good
		 if [[   $VBITERATE -gt $MINIMUM_VBITERATE ]]
		 then
	      FF_VBITERATE=$(echo "$VBITERATE / 1000 "|bc)
	      FF_VBITERATE=${FF_VBITERATE%.*}k
	      echo -e "VBITERATE=${GREEN}$VBITERATE${NC}\\t$FF_VBITERATE"
	
		 # VBITERATE too small
	      else
	      WARNING="WARNING: Video biterate is ($VBITERATE $VFF_BITERATE ).The minimun biterate for a $VFORMAT video is ($MINIMUM_VBITERATE)  "
	      echo -e ${PINK}${WARNING}${NC}
	      echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
	      fi
	      
	      
	      # check the VDURATION	     
		 
		 # if VDURATION si null take DURATION
		 
		 [[ $VDURATION == 0 || -z $VDURATION ]] &&  VDURATION=$DURATION
		 
		 
	      
	      VDURATION_S=`echo "$VDURATION / 1000"|bc`
	      if [[  $VDURATION_S -lt $MINIMUM_DURATION ]] 
	      then
	      ERROR="Error: Duration of the video is ($VDURATION_S secondes).The minimun duration for a video is ($MINIMUM_DURATION secondes)  "
	      echo -e ${RED}${ERROR}${NC}
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err   
	      else
	      echo -e "VDURATION=${GREEN}$VDURATION_S${NC}"
	      CROPSTART=`echo ${VDURATION_S} / 2|bc`
	      fi

	      
	      # Check for a DELAY 

	      if [[ ! -z $DELAY ]]
	      then
	      echo -e "DELAY=${GREEN}$DELAY${NC}"
	      fi     
	      
	      
	      
	      # Check interlaced with mediainfo
	      
	      if [[ $INTERLACED == "Interlaced" ]]
	      then
	      DEINTERLACE=" -deinterlace "
	      echo -e "INTERLACED=${GREEN}$INTERLACED${NC}"
	      fi
	      
	      
}	      

get_extra_infos () {	 
	      # check the BPF of the video (test)
	      
	      echo -e "\\n${cyan}# Extra informations${NC}\\n"
	      
	      NB_FRAMES=$(mediainfo "--Inform=Video;%FrameCount%" ${INPUT})
	      STREAMSIZE=$(mediainfo "--Inform=Video;%StreamSize%" ${INPUT})
	      NB_PIXELS=$(echo "$WIDTH * $HEIGHT"|bc)
	      if [[ ! -z $STREAMSIZE && ! -z $NB_FRAMES ]]
	      then
	      NB_PIXELS=$(echo "$WIDTH * $HEIGHT"|bc)
	      BPF=$(echo "($STREAMSIZE * 1080 / $NB_FRAMES) / $NB_PIXELS  "|bc)
	      echo -e "fredo BPF1=${GREEN}${BPF}${NC}"
	      fi
	      
	      # check the BPF of the video
	      
	      BPF=$(mediainfo "--Inform=Video;%Bits-(Pixel*Frame)%" ${INPUT})
	           
	      if [[ $BPF < $MINIMUM_BPF && ! -z $BPF ]] 
	      then
	      WARNING="WARNING: BPF quality  of the video is ($BPF).The minimun quality is ($MINIMUM_BPF)  "
	      echo -e "${PINK}$WARNING${NC}"
	      echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
	      else
	      echo  -e "BPF=${GREEN}${BPF}${NC}"
	      fi
	      

	      
	      VBRPP=$(echo "scale=1;$BITERATE / $NB_PIXELS  "|bc)
	      if [[ $VBRPP <  1.5  ]]
	      then
	      WARNING="WARNING: VBRPP quality  of the video is ($VBRPP).The minimun quality is (1)  "
	      echo -e "${PINK}$WARNING${NC}"
	      echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
	      else
	      echo -e "fredo VBRPP=${GREEN}${VBRPP}${NC}"
	      fi
}

get_audio_infos() {
	      AUDIO_INFOS=""
	      

	      AFORMAT=""
	      ABITERATE=0
	      ABITERATE2=0
	      FF_ABITERATE=0
	      ADURATION=0
	      AR=0
	      CHANNELS=0
	      
	      echo -e "\\n${cyan}# Audio informations${NC}"
	      
	      AUDIO_INFOS=`mediainfo "--Inform=Audio;ACODEC='%Codec%' AR=%SamplingRate% ABITERATE2=%BitRate_Nominal% ADURATION=%Duration% CHANNELS=%Channel(s)% AFORMAT='%Format%' ABITERATE=%BitRate% " ${INPUT}`
	      #echo $AUDIO_INFOS	     
	      eval $AUDIO_INFOS

	      

	      
# 		 # check the  ACODEC
# 
# 	      if [[ ! -z ` grep  "^${ACODEC}$" ./config/ACODECS ` ]]
# 	      then
# 	      echo -e -n "ACODEC=${GREEN}$ACODEC${NC}"
# 	      else
# 	      echo -e -n "ACODEC=${YELLOW}$ACODEC${NC}"
# 	      fi
		 
		 
		 # check the  AFORMAT

	      if [[ ! -z ` grep  "^${AFORMAT}$" ./config/AFORMATS ` ]]
	      then
	      echo -e "AFORMAT=${GREEN}$AFORMAT${NC}"
	      else
	      echo -e "AFORMAT=${YELLOW}$AFORMAT${NC}"
	      fi
		 
		
		
		# check the  ACODEC
		 
		 ACODEC_INFOS=`grep "^${ACODEC}|*" ./config/ACODECS `

	      if [[ ! -z $ACODEC_INFOS ]]
	      then
			   # Checkc the codec compatibility
			   ACODEC_COMP=`echo "$ACODEC_INFOS" | awk -F "|" '{ print $2 }' `
			   ACODEC_TEXT=`echo "$ACODEC_INFOS" | awk -F "|" '{ print $3 }' `
			   
			   case $ACODEC_COMP in
			   1)echo -e  "ACODEC=${GREEN}${ACODEC} ${NC}\\t$ACODEC_TEXT";;
			   2)echo -e  "ACODEC=${YELLOW}${ACODEC} ${NC}\\t$ACODEC_TEXT";;
			   3)echo -e  "ACODEC=${PINK}${ACODEC} ${NC}\\t$ACODEC_TEXT";;
			   4)echo -e  "ACODEC=${RED}${ACODEC} ${NC}\\t$ACODEC_TEXT";;
			   esac
		 
	      
	      else
		 # codec not defined
	      echo -e -n "ACODEC=${YELLOW}${ACODEC}${NC}\\tCodec undefined!"
	      fi
	      
		  # Check the ABITERATE
		  ABITERATE_NOTICE=""
	      
		 
		  # if mediainfo did not detect the auio bitrate -> try to get if from mplayer 
		  if [[  -z $ABITERATE || $ABITERATE == 0 ]]
		  then
		  get_abitrate_mplayer
		  ABITERATE=$ABITERATE_MPLAYER
		  ABITERATE_NOTICE="# detected by mplayer"
		  fi
		  
		 
		  
		  # take the value  and parse it to ffmpeg
		  
		  if [[ $AFORMAT == "PCM" ]]
		  then
		  TMP_ABITERATE=`echo "$ABITERATE / 1000"|bc `
		  PCM[1411]=128000 
		  PCM[1536]=192000
		  FF_ABITERATE=${PCM[TMP_ABITERATE]}
		  
				# if not a pcm standart send ABITERATE as value
				[[ -z $FF_ABITERATE ]] && FF_ABITERATE=$ABITERATE
		  
		  else
		  FF_ABITERATE=`echo "($ABITERATE + 16000 ) / 32000 * 32000" |bc`
		  fi
		  
		  # compare ABITERATE_MPLAYER with ABITERATE2
		  
		  if [[  -z $FF_ABITERATE  ]] 
		  then
		  ABITERATE=0
		  ABITERATE_NOTICE="# not detected by mplayer"
		  elif [[ ! -z $ABITERATE_NOTICE && $FF_ABITERATE != $ABITERATE2 ]]
		  then
		  # just add a notice that the 2 value are not equal
		  ABITERATE_NOTICE="$ABITERATE_NOTICE but! [$FF_ABITERATE != $ABITERATE2]"	 
		  elif [[ ! -z $ABITERATE2  && $FF_ABITERATE != $ABITERATE2 ]]
		  then
		  # just notice that the 2 value are not equal
		  
		  ABITERATE_NOTICE=" [$FF_ABITERATE != $ABITERATE2]"	
		  fi
		  
		  # check if the value of ABITERATE is acceptable
		
		  # ABITERATE is a standar
		  if [[ ! -z ` grep  "^${FF_ABITERATE}$" ./config/ABITRATES ` ]]
		  then
		  echo -e "ABITERATE=${GREEN}$FF_ABITERATE${NC}\\t$ABITERATE\\t$ABITERATE_NOTICE"
		  # too small
		  elif [[ $FF_ABITERATE -gt $MINIMUM_ABITERATE ]]
		  then
		  echo -e "ABITERATE=${YELLOW}$FF_ABITERATE${NC}\\t$ABITERATE\\t$ABITERATE_NOTICE"
		  else
		  WARNING="WARNING: audio biterate is ($FF_ABITERATE $ABITERATE ).The minimun biterate for a $AFORMAT audio is ($MINIMUM_ABITERATE)  "
		  echo -e ${PINK}${WARNING}${NC}
		  echo $WARNING >> ${DIRECTORY}/${OUTPUT}.err
		  fi

	      
	      
	      # check the ADURATION	      
		 
		  # if ADURATION si null take DURATION


		 [[ $ADURATION == 0 || -z $ADURATION ]] &&  ADURATION=$DURATION
	      
	      ADURATION_S=`echo "$ADURATION / 1000"|bc`
		 
	      if [[  $ADURATION_S -gt $MINIMUM_DURATION ]] 
	      then
		 echo -e "ADURATION=${GREEN}$ADURATION_S${NC}"
	      else
		 ERROR="Error: Duration of the audio is ($ADURATION_S secondes).The minimun duration for a audio is ($MINIMUM_DURATION secondes)  "
	      echo -e ${RED}${ERROR}${NC}
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err 
	      fi
	      
	      # Check the number of CHANNELS
	      
	      if [[ ${CHANNELS} == 2 || ${CHANNELS} == 6 ]]
	      then
	      echo -e "CHANNELS=${GREEN}$CHANNELS${NC}"
	      else
	      echo -e "CHANNELS=${YELLOW}$CHANNELS${NC}"
	      fi
	      
	      
	      # Check the AR (Sampling rate)
	      
	      if [[ ${AR} == 48000 || ${AR} == 44100 ]]
	      then
	      echo -e "AR=${GREEN}$AR${NC}"
	      elif [[ ${AR} == 32000 || ${AR} == 22050 ]]
	      then
	      echo -e "AR=${YELLOW}$AR${NC}"
	      else
	      echo -e "AR=${RED}$AR${NC}"
	      fi


	      
	      
	      
}

cropdetection() {

    
		 if [[ $OVERWRITE != 1  ]]
		 then
    
				if [[ -n $1 ]]
				then
				CROPFRAMES_TMP=$1
				CROPSTART_TMP=0
				echo -e "\\n${cyan}# Crop from -ss $CROPSTART_TMP detction on $1 frames${NC}"

				else

				CROPFRAMES_TMP=$CROP_FRAMES_S
				CROPSTART_TMP=$CROPSTART
				echo -e "\\n${cyan}# Crop detction from -ss $CROPSTART_TMP  on $CROP_FRAMES_S frames${NC}"
				
				fi
		 
		 
				# Run mplayer to get somme parameters of the video.
				CROPDETECTION_CMD="mplayer \"$INPUT\" -ss $CROPSTART_TMP -frames $CROPFRAMES_TMP -vf cropdetect -ac dummy -quiet -vo null -ao null > ${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop 2>&1"
				eval $CROPDETECTION_CMD 
				if [[  $DEBUG -eq 1 ]]
				then
				cat "${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop" |tail -n 10
				fi
				
		fi
	      
		# Get the output of -vf cropdetect.

		CROP=`cat ${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop | grep CROP | tail -1`
		CROP=${CROP#* crop=}
		CROP=${CROP%%\).*}

	      
	      if [[ ! -z $CROP ]]
	      then 
				echo "CROP=${CROP}"

				# get crop left
				CROPLEFT=`echo $CROP|awk -F ':' '{print $3 }'`
				echo  "CROPLEFT=$CROPLEFT"

				if [ $CROPLEFT -gt 0 ]
				then
				FF_CROP_WIDTH=" -cropleft $CROPLEFT"
				fi
				
				# get crop right
				CROPRIGHT=`echo $CROP|awk -F ':' '{print  $1 }'`
				CROPRIGHT=`echo "$WIDTH - $CROPRIGHT - $CROPLEFT"|bc`
				echo  "CROPRIGHT=$CROPRIGHT"

				if [ $CROPRIGHT -gt 0 ]
				then
				FF_CROP_WIDTH="$FF_CROP_WIDTH -cropright $CROPRIGHT"
				fi


				# get crop top
				CROPTOP=`echo $CROP|awk -F ':' '{print $4 }'`
				echo  "CROPTOP=$CROPTOP"

				if [ $CROPTOP -gt 0 ]
				then
				FF_CROP_HEIGHT=" -croptop $CROPTOP"
				fi

				# get crop bottom
				CROPBOTTOM=`echo $CROP|awk -F ':' '{print  $2 }'`
				CROPBOTTOM=`echo "$HEIGHT - $CROPBOTTOM - $CROPTOP"|bc`
				echo  "CROPBOTTOM=$CROPBOTTOM"

				if [ $CROPBOTTOM -gt 0 ]
				then
				FF_CROP_HEIGHT="$FF_CROP_HEIGHT -cropbottom $CROPBOTTOM"
				fi
		 
				#  CROP_RATIO = DAR of the video after cropping
				CROP_RATIO=`echo "scale=3;($WIDTH - $CROPLEFT - $CROPRIGHT)/($HEIGHT - $CROPTOP - $CROPBOTTOM)"|bc`
				echo -e "CROP_RATIO=${cyan}$CROP_RATIO${NC}"
				
				
						 

				CROPHEIGHT=`echo "$CROPTOP+$CROPBOTTOM"|bc`
				#echo "CROPHEIGHT=$CROPHEIGHT"
				CROPHEIGHT_AV=`echo "$CROPHEIGHT / 2"|bc`
				
				CROPWIDTH=`echo "$CROPLEFT+$CROPRIGHT"|bc`
				#echo "CROPWIDTH=$CROPWIDTH"
				CROPWIDTH_AV=`echo "$CROPWIDTH / 2"|bc`
				  
	  
				echo -e "CROPWIDTH_AV=${cyan}$CROPWIDTH_AV${NC}"
				echo -e "CROPHEIGHT_AV=${cyan}$CROPHEIGHT_AV${NC}"

				
		# detection failled once, try one more time with CROPSTART = 0		
		elif [[ -z $CROP && $CROPSTART != 0 && $CROPDETECTION_2PASS != 1 ]]	
		then
		CROPSTART=0
		# avoid loop
		CROPDETECTION_2PASS=1
		
		cropdetection $CROP_FRAMES_L		
		
		 # detection failed
	      else
		 ERROR="Crop detection failled!"
		 ERROR=${ERROR}$CROPDETECTION_CMD
		 ERROR=${ERROR}`cat "${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop" |tail -n 10`
		 
	      echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err   
	      echo -e "${RED}${ERROR}${NC}\\n"

	      fi
	      
	     }

resample_audio(){
file ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav | grep -qs 'PCM, 8 bit'
if [ $? = 0 ]; then
    SOX_B="-b -u"
    SOX_W="-w"
COMMAND="${COMMAND}sox $SOX_B ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav -r 48000 $SOX_W ${DIRECTORY}/${SUBDIR}/resample.wav resample;###"
#echo "sox: resampling PCM, 8 bi to PCM, 16 bit" 
 

#     if sox $SOX_B ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav -r 48000 $SOX_W ${DIRECTORY}/${SUBDIR}/resample.wav resample  ; then
#     mv -f ${DIRECTORY}/${SUBDIR}/resample.wav ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav
#     echo "sox: resampling done" 
#     fi
fi
}

resample_video(){
echo -e "\\n${CYAN}# pipe mplayer to ffmpeg${NC}\\n"
rm -f ${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv
mkfifo ${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv

mplayer $INPUT -fps 24 -ass -embeddedfonts -sid 0 -aid 1 -vf eq2=0.9:1:0:1.02 -vo yuv4mpeg:file=${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv   -ao null -quiet < /dev/null & 
}
	
pal-dar133(){
	
                                                                                                
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.33|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ./config/CROPS `
		echo $CROP_PRESET                                                                                        
																									 
                                                                                                                               
                                                                                                                                        
                                                                                                                                        
				# Width                                                                                                  
                                                                                                                                        
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`                                         
				if [[ ! -z $CROP_PRESET_WIDTH ]] 
				then
				
				# change to the preset values
				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				echo -e "${cyan}Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"				
				else
				
				# keep the cropping detected values
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				echo -e "${cyan}Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				# Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
			     # change to the preset values
				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				echo -e "${cyan}Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc ` 
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				echo -e "${cyan}Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# DISTORTION
				
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				echo -e "${cyan}Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
	               # stantart    
				DISTORTION="/$PAR" # PAR 16:15 = 1.0666666
				echo -e "${cyan}Distortion: $DISTORTION${NC}\\t(standart)"				
				
				fi
				
				
	      # no padding
		 echo -e "${cyan}Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes
	
	
	
	}
	
pal-dar177(){
	 
		 
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.77|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ./config/CROPS `
		echo $CROP_PRESET
				
				
		 
				# Width
				
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`
				if [[ ! -z $CROP_PRESET_WIDTH ]]
				then
				
				# change to the preset values
				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				echo -e "${cyan}Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"				
				else
				
				# keep the cropping detected values
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				echo -e "${cyan}Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				# Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
			     # change to the preset values
				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				echo -e "${cyan}Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc ` 
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				echo -e "${cyan}Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# Distortion
			
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				echo -e "${cyan}Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
	               # stantart    
				DISTORTION="/$PAR " 
				echo -e "${cyan}Distortion: $DISTORTION${NC}\\t(standart)"				
				
				fi
		 
	 
		 #no  padding
	      echo -e "${cyan}Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes

	 
	 }
      
calc_new_sizes(){
		# new width
		NEW_WIDTH=`echo "($WIDTH -  $CROPLEFT - $CROPRIGHT) * ${DISTORTION#/} /1 "|bc`
		# new height before padding
		NEW_HEIGHT_BP=`echo "($HEIGHT -  $CROPTOP - $CROPBOTTOM )  "|bc`
		#echo "$NEW_HEIGHT_BP $PADTOP $PADBOTTOM"
		# new height (after padding)
		NEW_HEIGHT=`echo "( $NEW_HEIGHT_BP +  $PADTOP + $PADBOTTOM ) "|bc`

		NEW_SIZE=${NEW_WIDTH}x${NEW_HEIGHT}

		echo -e "${cyan}Resize: $SIZE -> $NEW_SIZE${NC}"

}

get_infos() {
	      INPUT=$1

	      

	      NOTICE=""
	      WARNING=""
	      ERROR=""
	      
	      SS=0
	      
	      PAD=0
		 PADTOP=0
		 PADBOTTOM=0
	      FF_PAD=""
		 
		 CROPDETECTION_2PASS=0
		 
		 FF_CROP_WIDTH=""
	      FF_CROP_HEIGHT=""
	      CROP=""
	      CROPTOP=0
	      CROPRIGHT=0
	      CROPBOTTOM=0
	      CROPLEFT=0
	      
	      DISTORTION=1
	    

	      
	      
	      
	      
	      DIRECTORY=`dirname $1`
	      
	      SUBDIR=`basename "$INPUT"`
	      SUBDIR=${SUBDIR%%.${EXTENTION}}
	      
	      OUTPUT=` basename $INPUT`
	      OUTPUT=${OUTPUT%%.???}
	      
	      # create the dir
	      if [[ ! -d  "${DIRECTORY}/${SUBDIR}" ]]
	      then
	      mkdir "${DIRECTORY}/${SUBDIR}"
	      fi
	      


     
	      ### General informations 
	    
	      get_general_infos
	      
 	      ### Video informations 
	    
	      get_video_infos	      
	      
	      ### extra informations
	      
	      #get_extra_infos
	      
	      ### Audio Informations
	      
	      get_audio_infos
	      
	      ### crop detection
	      
	      #cropdetection 
	      
		
	      
	      if [[ ! -z $ERROR ]]
	      then
	      mediainfo ${INPUT} >> ${DIRECTORY}/${OUTPUT}.err
	      #mv ${DIRECTORY}/${OUTPUT}.${EXTENTION} ${DIRECTORY}/${OUTPUT}.mrd
	      
	      fi
	
	
	      


		DETECTED_FORMAT=""
		RATIO_I=`echo "($RATIO * 100) /1"|bc `

		
		
		
	      # pal DAR 1.25
		 

if [[ ( $RATIO_I  -ge 122 && $RATIO_I -le 128 ) && ( $DAR == 0 || $DAR  == 1.25 ) ]]
	      then
		 
		 DETECTED_FORMAT="1.25 - pal reencoded !"
		 echo -e "\\n${pink}Format: $DETECTED_FORMAT ${NC}"
	      
	      # get a new cropdetection 
	      cropdetection $CROP_FRAMES_L


		 
		 
				# small black border 
				
				if [[  $CROPTOP -lt `echo $HEIGHT / 16 |bc`    &&  $CROPBOTTOM  -lt `echo $HEIGHT / 16 |bc` ]]
				then
				
				echo -e "\\nSmall black border less than `echo $HEIGHT / 16 |bc`" 
				echo    "1/  pal DAR 1.77" 
				echo    "2/  pal DAR 1.33 (if the  crop detection didn't work)"
				

				
				# remove very small black border on the top and bottom (optional)
				
				if [[ $CROPHEIGHT_AV  -lt `echo "$HEIGHT * 0.3 * 2 / 2" |bc` ]]
				then
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				echo -e "${cyan}Cropping H:\\t$FF_CROP_HEIGHT${NC}"
				else
				CROPTOP=0
				CROPBOTTOM=0
				FF_CROP_HEIGHT="" 
				echo -e "${cyan}Cropping H:\\t no${NC}"
				fi
				
				# remove very small black border on the left and right (optional)
							   
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 / 1" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				echo -e "${cyan}Cropping W:\\t$FF_CROP_WIDTH${NC}"
				else
				CROPLEFT=0
				CROPRIGHT=0
				FF_CROP_WIDTH="" 
				echo -e "${cyan}Cropping W:\\t no${NC}"
				fi
				
				
				# distortion 
				DISTORTION="/1.422 "
				echo -e "${cyan}Distortion:\\t$DISTORTION${NC}"				
		 
				# Padding: no
				echo -e "${cyan}Padding:\\tno${NC}"
				
				# get new sizes
				calc_new_sizes
				
				
				
				
				# medium black boder 

				
				elif [[ $CROPHEIGHT_AV -ge `echo "$HEIGHT * 0.111 / 1" |bc` && $CROPHEIGHT_AV  -le `echo "$HEIGHT * 0.155 / 1"|bc`   ]]
				then
				
				echo -e "\\nMedium black border less than `echo "$HEIGHT * 0.155 / 1"|bc` AND more than `echo "$HEIGHT * 0.111 / 1"|bc` "
				echo    "1/ pal DAR 1.33 with a image 1.77 "
				echo    "2/ pal DAR 1.77 with a image 2.35 "
				
				
				CHOICE=0
				read -t 5 CHOICE
				echo $CHOICE
				
				case $CHOICE in
				1)pal-dar133;;
				2)pal-dar177;;
				*)pal-dar133;;
				esac
				

				
				
				
				
				
				
				# large black border cinemascope = 136 | 16/9=  |pal DAR 1.77 = 80 -> dont cut just strech the image
				else
				
				echo -e "\\nLarge Black border more than `echo "$HEIGHT * 0.155 / 1"|bc` "
				echo    "1/  pal DAR 1.33"
				echo    "2/  pal DAR 1.77"				
				
				CHOICE=0
				read -t 5 CHOICE
				echo $CHOICE
				
				case $CHOICE in
				1)pal-dar133;;
				2)pal-dar177;;
				*)pal-dar133;;
				esac
		
				
				fi
				
				
				


	      fi


	      # PAL DAR 1.33
		 
	      if [[ ($RATIO_I -eq 125 || $RATIO_I -eq 122 ) && $DAR == 1.33 ]]
	      then
	      # get a  cropdetection 
	      cropdetection $CROP_FRAMES_L
		 
		 DETECTED_FORMAT="PAL DAR 1.33"
		 echo -e "\\n${pink}Format: $DETECTED_FORMAT${NC}"
		
		 pal-dar133
	      fi


	      # 1.25 DAR 1.77
		 
	      if [[ ($RATIO_I -eq 125 || $RATIO_I -eq 122 ) && $DAR == 1.77 ]]
	      then
	 
		 # get a  cropdetection
	      cropdetection $CROP_FRAMES_S
		 
		 DETECTED_FORMAT="PAL DAR 1.77"
		 echo -e "\\n${pink}Format: $DETECTED_FORMAT${NC}"

		 pal-dar177	      
	      fi
		 
	      # 1.25 DAR 2.21 !!!
		 
	      if [[ $RATIO_I -eq 125 && $DAR == 2.21 ]]
	      then

		 DETECTED_FORMAT="PAL DAR 2.21"
		 echo -e "\\n${red}Format: $DETECTED_FORMAT${NC}"
		 

	      # padding
		 
		 PAD=`echo "scale=3;(($WIDTH / 1.777) - $HEIGHT) / 2"|bc`
	      PAD=`round2 $PAD`
		 PADTOP=$PAD
		 PADBOTTOM=$PAD
	      FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
		 echo -e "${cyan}Padding: $FF_PAD${NC}"
		  

	      # Cropping: no
		 
	      echo -e "${cyan}Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
				
		  # distortion 1.768
		  DISTORTION="/1.768 "
		  echo -e "${cyan}Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  echo -e "${cyan}Padding: no${NC}"
		  
		  # get new sizes
		  calc_new_sizes				 
				 
				 
	      fi      	 
		 
	      # 1.50 ntsc reencoded !
		 
	      if [[ $RATIO_I == 150  && ( $DAR == 0 || $DAR  == 1.50 ) ]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc reencoded !"
		 echo -e "\\n${RED}Format: $DETECTED_FORMAT${NC}"
		 # get a new cropdetection 
	      cropdetection $CROP_FRAMES_L
		 

	      # Cropping: no
		 
	      echo -e "${cyan}Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="/`echo "scale=3; 1.777 / $RATIO "|bc` "
		  echo -e "${cyan}Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  echo -e "${cyan}Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi	
		 
	      # 1.50 ntsc DAR 1.77
		 
	      if [[ $RATIO_I == 150  &&  $DAR == 1.77 ]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc DAR 1.77"
		 echo -e "\\n${green}Format: $DETECTED_FORMAT${NC}"

	      # Cropping: no
		 
	      echo -e "${cyan}Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="/`echo "scale=3; $ID_VIDEO_ASPECT  / $RATIO "|bc` "
		  echo -e "${cyan}Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  echo -e "${cyan}Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi		 		 
		 
	      # 1.33
		 
	      if [[ ( $RATIO_I  -gt 127 && $RATIO_I -lt 160  && $RATIO_I != 150 ) && ($DAR == 0 || $DAR == 1.33 ) ]]
	      then
		 DETECTED_FORMAT="1.33"
		 echo -e "\\n${pink}Format: $DETECTED_FORMAT${NC}"

	      # Cut the top and the bottom 
		 
		 CUT=`echo "scale=3;( $HEIGHT - ( $WIDTH / 1.777 )) / 2"|bc ` 
 	      CUT=`floor2 $CUT` 
		 CROPTOP=$CUT
	      CROPBOTTOM=$CUT
	      FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
		 
		 echo -e "${cyan}Cutting: $FF_CROP_HEIGHT${NC}"
		 
		 # get new sizes
		 calc_new_sizes

	      fi
 
		 # 1.33 DAR 16/9 !!!
		 
		 if [[ ( $RATIO_I  -ge 127 && $RATIO_I -lt 160 && $RATIO_I != 150 ) && ( $DAR  == 1.77 ) ]]
		 then
		 DETECTED_FORMAT="4/3 DAR 16/9"
		 NOTICE="${NOTICE}This format($DETECTED_FORMAT) is not a video standart, please follow your recommendation."
		 
		 echo -e "\\n${red}Format: $DETECTED_FORMAT${NC}"
		 
	      # Cropping: no
		 
	      echo -e "${cyan}Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
				
		  # distortion 
		  DISTORTION="/1.333 "
		  echo -e "${cyan}Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  echo -e "${cyan}Padding: no${NC}"
		  
		  # get new sizes
		  calc_new_sizes
		
	      
	      fi
		       
	      # 1.77
		 
	      if [[ $RATIO_I -ge 160 && $RATIO_I -lt 199 ]]
	      then
		 DETECTED_FORMAT="16/9"
		 echo -e "\\n${green}Format:$DETECTED_FORMAT ${NC}"


		 
				# cropping
		 
		 
				# normal (no detection)
				if [[ $CROPDETECTION  == 1 ]]
				then
				
				# Cropping H: no
				echo -e "${cyan}Cropping W: no${NC}"
				CROPLEFT=0              
				CROPRIGHT=0
				FF_CROP_WIDTH=""
				
				# Cropping H: no
				echo -e "${cyan}Cropping H: no${NC}"
				CROPTOP=0
				CROPBOTTOM=0
				FF_CROP_HEIGHT=""
				
				else 
				
						# make a crop detection 
						cropdetection $CROP_FRAMES_S
						
						# detection H (level detection 2)

						if [[ $CROPDETECTION  -gt 1 && $CROPHEIGHT_AV  -lt `echo "$HEIGHT * 0.03 * 2 / 2" |bc` ]]
						then
						FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
						echo -e "${cyan}Cropping H:$FF_CROP_HEIGHT${NC}"
						else
						CROPTOP=0
						CROPBOTTOM=0
						FF_CROP_HEIGHT="" 
						echo -e "${cyan}Cropping H: no${NC}"
						fi

		  
				
						# detection W (level detection 2 and 3)
						   
						if [[  $CROPDETECTION  -gt 2 && $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
						then
						FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
						echo -e "${cyan}Cropping W:$FF_CROP_WIDTH${NC}"
						else
						CROPLEFT=0
						CROPRIGHT=0
						FF_CROP_WIDTH="" 
						echo -e "${cyan}Cropping W: no${NC}"
						fi

							
			   fi

				
				
		# Padding: no
		echo -e "${cyan}Padding: no${NC}"
		
		# get new sizes
		 calc_new_sizes

		fi				
				
	      # 2.35
		 
	      if [[ $RATIO_I -ge  199 && $RATIO_I -le 255 ]]
	      then
		 DETECTED_FORMAT="2.35"
		 echo -e "\\n${green}Format: $DETECTED_FORMAT${NC}"

	      
	      # padding
		 
		 PAD=`echo "scale=3;(($WIDTH / 1.777) - $HEIGHT) / 2"|bc`
	      PAD=`round2 $PAD`
		 PADTOP=$PAD
		 PADBOTTOM=$PAD
	      FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
		 echo -e "${cyan}Padding: $FF_PAD${NC}"
		  

	      # Cropping: no
		 
	      echo -e "${cyan}Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""

		# get new sizes
		 calc_new_sizes
	      fi
	      
	      
	      
}
	    

encode(){
	    
	   FF_WIDTH=320
	   FF_HEIGHT=180
	   
	   if [[ $PAD != 0 ]]
	   then
	   FF_HEIGHT=`echo "$FF_WIDTH / $RATIO"|bc`
	   FF_HEIGHT=`round2 $FF_HEIGHT `
	   PAD=`echo "scale=3;(($FF_WIDTH / 1.777 ) - ($FF_WIDTH / $RATIO )) / 2"|bc`
	   PAD=`round2 $PAD`
	   FF_PAD=" -padtop $PAD -padbottom $PAD "
	   fi   
	      
	      

	      
	      
	  ### transcode the video
	  
	  
	  
		COMMAND=""
		COMMAND_DISPLAY=""
		
	  	case "$OUTPUT_FORMAT" in
		jpeg)	  

		COMMAND="ffmpeg $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24   $VHOOK -an -ss $(echo "$SS + 10 "|bc)  -vframes 1 -y ${DIRECTORY}/${OUTPUT}.jpg;"
	     #COMMAND="${COMMAND}display  ${DIRECTORY}/${OUTPUT}.jpg & "
		;;
		montage)	
		
		FF_FPS=`scale=2;echo  "9\${DURATION_S}"|bc`
		FF_FPS="0.0$FF_FPS"
		COMMAND="ffmpeg $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r $FF_FPS  $VHOOK -an -ss $(echo "$SS + 2 "|bc)  -vframes 9 -y ${DIRECTORY}/${OUTPUT}_%d.jpg;"
		COMMAND="${COMMAND}montage  ${DIRECTORY}/${OUTPUT}_[0-9].jpg -geometry 160x90+1+1 ${DIRECTORY}/${OUTPUT}_montage.png;"
	     COMMAND_DISPLAY="display  ${DIRECTORY}/${OUTPUT}_montage.png & "
		
		;;
		sample)  
		# transform to pcm
		COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -vc null -vo null   ${INPUT} > /dev/null;###"
		
		
		if [[ $CHANNELS == 6 ]]
		then
		COMMAND="${COMMAND}mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav -channels 6 -vc null -vo null   ${INPUT} > /dev/null;###"
		
		# dump the audia !!! use mp4creator
		#COMMAND="${COMMAND}mplayer -dumpaudio -dumpfile ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.aac ${INPUT} > /dev/null;###"
		
		#faac -X  -P  -q 100 -c 44100 -b 128 --mpeg-vers 4 -o ../exemple/apple/h720/h720_ch6.aac -C 6 -R 48000 -B 16
		#COMMAND="${COMMAND}faac -X -q 100 -c 44100 -b 128   --mpeg-vers 4 -o a${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.aac  ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav > /dev/null;###"
		
# 		COMMAND="${COMMAND}ffmpeg  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav -ss  $(echo "$SS  + 10 "|bc) -t 20 -r 24 -ar 48000 -ab 128000 -ac 6  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_ch6.aac;###"
		fi
		
		# check if resample 8bit to 16 is needed  (sox)
		resample_audio
		
		# make a sample audio
		COMMAND="${COMMAND}ffmpeg  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -ss  $(echo "$SS  + 10 "|bc) -t 20 -r 24 -ar 44100 -ab 128000 -ac 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3;###"
		


		if [[ -z $FFMPEG_VIDEO_YES ]]
		then
		# pipe mplayer rawvideo to ffmpeg
		COMMAND="${COMMAND}resample_video;###"
		COMMAND="${COMMAND}ffmpeg  $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;###"
		else
		# make a sample video
		
		# flv
		COMMAND="${COMMAND}ffmpeg -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20   -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;###"
		
		# mp4 !!!
# 		COMMAND="${COMMAND}ffmpeg -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20 -f mp4  -vcodec libx264 -vpre default -vpre main -level 30 -refs 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.m4v;###"
# 		COMMAND="${COMMAND}mp4creator -create=${DIRECTORY}/${SUBDIR}/${OUTPUT}_ch6.aac ${DIRECTORY}/${SUBDIR}/${OUTPUT}_test.mp4 ;###"
# 		COMMAND="${COMMAND}mp4creator -create=${DIRECTORY}/${SUBDIR}/${OUTPUT}.m4v -rate=24 ${DIRECTORY}/${SUBDIR}/${OUTPUT}_test.mp4 ;###"
# 
# 		COMMAND="${COMMAND}mp4creator -hint=1 ${DIRECTORY}/${SUBDIR}/${OUTPUT}_test.mp4 ;###"
# 		COMMAND="${COMMAND}mp4creator -hint=2 ${DIRECTORY}/${SUBDIR}/${OUTPUT}_test.mp4 ;###"
# 		COMMAND="${COMMAND}mp4creator -optimize ${DIRECTORY}/${SUBDIR}/${OUTPUT}_test.mp4 ;###"
		#mv ${output}.mp4 creator.mp4
		
		
		
		fi
		
		 
		### remux
		
		# flv
		COMMAND="${COMMAND}ffmpeg  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.flv -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.mp3 -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.flv;"
		
		# mp4 !!!
		#COMMAND="${COMMAND}ffmpeg -vtag mp4v -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.m4v -i ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.aac -acodec copy -vcodec copy -ac 6 -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp_1.mp4;###"
		
		#COMMAND="${COMMAND}qt-faststart ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp_1.mp4 ${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.mp4;###"
		
		
		
		
		COMMAND_DISPLAY="${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.flv;###"
		
		;;
		
		normal) 
		
		COMMAND="ffmpeg $DEINTERLACE -i ${INPUT}  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  -b 700000 -aspect 1.77  $VHOOK  -ss $SS  -ar 48000 -ab 128000 -ac 2 -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp4"
		
		;;
		esac

	      
	      echo -e "`echo $COMMAND| sed "s/###/\\n/g" `" > ${DIRECTORY}/${SUBDIR}/code.txt
	      echo -e "\\n`echo $COMMAND| sed "s/###/\\n/g" `\\n" 

	      if [[ $DEBUG -eq 1 ]]
	      then
	      [[ $OVERWRITE != 1 ]] && eval  `echo $COMMAND| sed "s/###//g"` 
	      else
	      [[ $OVERWRITE != 1 ]] && eval `echo $COMMAND| sed s"/###//g"` > /tmp/mencoder.log 2>&1
	      fi
		 
		 # Display

		  if [[ $DISPLAY == 1 ]]
		  then
		  echo "$COMMAND_DISPLAY"
		  fi
		 
		 

		 
		 
    
    }
  
  
  #############################  

tr-encoder(){

		# analyse the video
		get_infos $1
	    
		if [[ -z $DETECTED_FORMAT || $MPLAYER_VIDEO_TEST == 0 || $MPLAYER_AUDIO_TEST == 0 ]] 
		then
		ERROR="ERROR: This video ($1) is not supported!"
		echo -e "\\n${RED}${ERROR}${NC}\\n"
		echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err
    
		else
			   
			   
			   ### create the logo
			   
			   
			   if [[ ! -z $LOGO_ADD ]]
			   then
			   
			   LOGO_RESIZED=${DIRECTORY}/${SUBDIR}/${OUTPUT}.png  
			   LOGO_DIR="$APP_DIR/logos"	    
			   
				# get the preset from LOGOS file 


				LOGOS_PRESET=`grep  "^$LOGO_ADD|.*" ./config/LOGOS `
				#echo "$LOGOS_PRESET $LOGO_ADD"
						
						if [[ ! -z $LOGOS_PRESET ]]
						then
						# load the values
						
						eval "${LOGOS_PRESET#${LOGO_ADD}|}"
						else
						# load default values
						
						# png or gif 
						LOGO_FILE="test.png" 
						# the width of the logo in %:example 10  (base on the Width of the video after cropping ) 
						LOGO_PC_W=10
						# the position X of the logo in %:example 10  (base on the Width of the video after cropping ) 
						LOGO_PC_X=10
						# the possition Y of the logo in %:example 30  (base on the Width of the video after cropping ) 
						LOGO_PC_Y=25
						
						LOGO_MODE="-m 1"
						LOGO_TRESHOLD="-t 000000"
						LOGO_DURATION=15
										
						fi
						
			   # run the function
			   add_logo
			   
			   
			   fi	
			 # start the encoding   
			 encode   
			 
	 fi   
	 
# promt for removing of the file

REMOVE_FILE_CONFIRM="n"
echo "Do you whant to remove this video? [y/N]"

read -t 30 REMOVE_FILE_CONFIRM

if [[ $REMOVE_FILE_CONFIRM = 'y' ]] || [[ $REMOVE_FILE_CONFIRM = 'Y' ]]
then
rm ${DIRECTORY}/${OUTPUT}.${EXTENTION}
echo "The video ${DIRECTORY}/${OUTPUT}.${EXTENTION} is remove"
fi
}


# $1 is a file
if [[ -f "${1}" ]] ; then


tr-encoder $1 


# $1 is a folder
else

    DIRECTORY=$1

    
    for VIDEO  in `find ${DIRECTORY}  -name "*.${EXTENTION}"`
    do

    SUBDIR=`basename "$VIDEO"`
    SUBDIR=${SUBDIR%%.${EXTENTION}}


      if [[ ! -d ${DIRECTORY}/${SUBDIR} || $OVERWRITE  !=  0 ]]
      then
      tr-encoder $VIDEO 
      fi
    done
fi
exit 0
