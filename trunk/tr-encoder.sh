#!/usr/local/bin/bash

SYSTEM=$(uname)

APP_NAME=`basename "$0"`
CONF_NAME=."$APP_NAME"rc
#APP_DIR=`dirname "$0"`

[[ SYSTEM == "Linux" ]] && APP_DIR=$(readlink -f $0 | xargs dirname) || APP_DIR=$(readlink -n $0 | xargs dirname)
 

# Import configuration file, possibly overriding defaults.
[ -r ~/"$CONF_NAME" ] && . ~/"$CONF_NAME"

# Include all funtions
. "$APP_DIR/lib/MAIN"

DEBUG=0
DISPLAY=0
OVERWRITE=0
CLEAN=0
CROPDETECTION=1 #???
TRY=""
LOGOS_ADD=""
FF_SIZE=""
SS=0


### Path to ffmpeg

FFMPEG="ffmpeg"

### Path to mp4box 

if [[ $SYSTEM == "FreeBSD" ]]
then
MP4BOX=mp4box
elif  [[ $SYSTEM == "Linux" ]]
then
MP4BOX=MP4Box
fi


EXTENTION=".org"
#EXTENTION=".VOB"





# Set up reasonable defaults.


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


    while getopts "f:T:l:o:e:c:s:b:DydY" option
    do
	case "$option" in
	c)	CLEAN=1;;	
	s)	SS="$OPTARG";;
	d)	DEBUG=1;;	
	D)	DEBUG=2;;
	e)	EXTENTION="$OPTARG";;		
	f)	OUTPUT_FORMAT="$OPTARG";;	
	l)	LOGOS_ADD="$OPTARG";;
	o)	OPERATION="$OPTARG";;	
	#s)	FF_SIZE="$OPTARG";;	
	T)	TRY="${OPTARG}-";;	
	y)      OVERWRITE=1;;
	Y)      OVERWRITE=2;;
	[?])    usage
		exit 1;;
	esac
    done
    shift $(($OPTIND - 1))







add_logo(){
				    
	   LOGO="${LOGO_DIR}/${LOGO_FILE}"

	    
	   [[ $DEBUG -gt 0 ]] && echo -e "\\n${cyan}$(box "Logo informations")${NC}\\n"
	    

	   [[ $DEBUG -gt 0 ]] && echo -e "LOGO_FILE=$LOGO_FILE\\nLOGO_PC_W=$LOGO_PC_W\\nLOGO_PC_X=$LOGO_PC_X\\nLOGO_PC_Y=$LOGO_PC_Y\\nLOGO_MODE=$LOGO_MODE\\nLOGO_TRESHOLD=$LOGO_TRESHOLD\\nLOGO_START=$LOGO_START\\nLOGO_DURATION=$LOGO_DURATION\\n"
	    

	    # get the logo size
	    LOGO_W=$(identify -format %w $LOGO )
	    LOGO_H=$(identify -format %h $LOGO ) 
	    
	    # find the new size for the logo exemple 10% of the new size 
	    
	    LOGO_RESIZED_W=$(echo "($NEW_WIDTH) * $LOGO_PC_W / 100 "|bc)
	    LOGO_RATIO=$(echo "scale=2;$LOGO_W / $LOGO_RESIZED_W" |bc) 
	    LOGO_RESIZED_H=$(echo "$LOGO_H / $LOGO_RATIO "|bc)
	    [[ $DEBUG -gt 0 ]] && echo -e "# Resize the logo to 10% (base on the new Width $NEW_WIDTH):\\t${LOGO_W}x${LOGO_H} -> ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
	  
	    # if the video is anamorphe -> the logo need a distortion to fit
	    
	    if [[  $DISTORTION != "1" ]]
	    then
	    LOGO_RESIZED_W=$(echo "$LOGO_RESIZED_W / $DISTORTION "|bc)
	    [[ $DEBUG -gt 0 ]] && echo -e "# Add the Distortion ($DISTORTION):\\t ${LOGO_W}x${LOGO_H} -> ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
	    fi
	    
	    # create the resized logo
	    
	    COMMAND="convert "${LOGO}" -resize ${LOGO_RESIZED_W}x${LOGO_RESIZED_H}\! -depth 8 $LOGO_RESIZED" 

	    eval "$COMMAND " && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
	    
	    # get the exact size of the resized logo (imagemagick do not respect the exactly thr -resize parameter)
	    LOGO_RESIZED_W=$(identify -format %w $LOGO_RESIZED )
	    LOGO_RESIZED_H=$(identify -format %h $LOGO_RESIZED )

	    [[ $DEBUG -gt 0 ]] && echo -e "# The final size of the logo:\\t${LOGO_RESIZED_W}x${LOGO_RESIZED_H}" 
 
	   
	    ### find the logo position 
	    
		# the position of the logo is base on the original size of the video
		
		if [[ $PAD -ne 0 ]]
		then
		[[ $DEBUG -gt 0 ]] && echo "# The logo can not be on the paddind area"
		LOGO_X=$(echo "(($NEW_WIDTH * $LOGO_PC_X ) / 100) "|bc)
		LOGO_Y=$(echo "scale=3;(($NEW_HEIGHT * $LOGO_PC_Y) / 100  )  - $PADTOP "|bc)

		else
		# no padding 
		#echo "scale=3;(($NEW_HEIGHT / 100 ) * $LOGO_PC_Y ) + $CROPTOP"
		LOGO_X=$(echo "scale=3;(($NEW_WIDTH *  $LOGO_PC_X )/ 100 ) + $CROPLEFT"|bc)
		LOGO_Y=$(echo "scale=3;(($NEW_HEIGHT * $LOGO_PC_Y ) / 100 ) + $CROPTOP"|bc)
		fi
    

	    # if the video is anamorphe -> the position need a ajustment base on the distortion
	    
	    if [[ $DISTORTION != "1" ]]
	    then
	    LOGO_X=$(echo "$LOGO_X  / $DISTORTION "|bc)
	    fi
	    
	    
	    LOGO_X=${LOGO_X%.???}
	    LOGO_Y=${LOGO_Y%.???}
	    [[ $DEBUG -gt 0 ]] && echo -e "# Position of the logo:\\tx = $LOGO_X Y = $LOGO_Y"
	    VHOOK=$VHOOK" -vhook \"/usr/local/lib/vhook/pip.so -f  $LOGO_RESIZED -x $LOGO_X -y $LOGO_Y  -w $LOGO_RESIZED_W -h $LOGO_RESIZED_H  $LOGO_MODE   $LOGO_TRESHOLD -s $(echo "$SS + $LOGO_START  * $FPS "|bc) -e $(echo "($SS + $LOGO_START + $LOGO_DURATION) * $FPS "|bc) \" "
 	    #echo $VHOOK
}

dump_audio(){

		if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio.wav" ]]
		then
		
		echo -e "${yellow}# Create audio.wav ${NC}"		
		echo -e "${green}# This file (audio.wav) already exit.We going to use it${NC}"
		
		else

		echo -e "${yellow}# create audio.wav ${NC}"		
		COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/audio.wav -vc null -vo null ${INPUT}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" > /dev/null  2>&1"
		eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 

			  ### check the size audio.wav

			  if [[ -f "${DIRECTORY}/$SUBDIR/audio.wav" &&  $SYSTEM == "Linux" ]]
			  then
			  RESULTS_SIZE=`stat -c '%s' "${DIRECTORY}/$SUBDIR/audio.wav"` 
			  elif [[ -f "${DIRECTORY}/$SUBDIR/audio.wav" && $SYSTEM == "FreeBSD" ]] 
			  then
			  RESULTS_SIZE=`stat -f '%z' "${DIRECTORY}/$SUBDIR/audio.wav"`
			  fi

			  ### try one more time if failed

			  if [ "$RESULTS_SIZE" -lt 1014000 ]
			  then
			  echo -e "${yellow}# create audio.wav ${NC}"		
			  COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/audio.wav -vc dummy -vo null ${INPUT}"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" > /dev/null  2>&1"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
			  fi

		fi

}

resample_audio(){
file ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav | grep -qs 'PCM, 8 bit'
if [ $? = 0 ]; then
    SOX_B="-b -u"
    SOX_W="-w"
echo -e "${yellow}# Resampling PCM 8 bit to PCM 16 bit${NC}"    
COMMAND="${COMMAND}sox $SOX_B ${DIRECTORY}/${SUBDIR}/${OUTPUT}.wav -r 48000 $SOX_W ${DIRECTORY}/${SUBDIR}/resample.wav resample"
#echo "sox: resampling PCM, 8 bi to PCM, 16 bit" 
[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
fi
}

resample_video(){
echo -e "\\n${CYAN}# pipe mplayer to ffmpeg${NC}\\n"
rm -f ${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv
mkfifo ${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv

mplayer $INPUT -fps 24 -ass -embeddedfonts -sid 0 -aid 1 -vf eq2=0.9:1:0:1.02 -vo yuv4mpeg:file=${DIRECTORY}/${SUBDIR}/${OUTPUT}.yuv   -ao null -quiet < /dev/null & 
}
	
pal-dar133(){
	
                                                                                                
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.33|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
		[[ $DEBUG -gt 1 ]] && echo $CROP_PRESET                                                                                        
																									 
                                                                                                                               
                                                                                                                                        
                                                                                                                                        
				# Width                                                                                                  
                                                                                                                                        
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`                                         
				if [[ ! -z $CROP_PRESET_WIDTH ]] 
				then
				
				# change to the preset values
				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"				
				else
				
				# keep the cropping detected values for the width (if not to big)
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				else
				FF_CROP_WIDTH="-cropleft 0 -cropright 0 "				
				fi
				
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				# Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
				# change to the preset values
				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc ` 
				CUT=$(floor2 $CUT)
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# DISTORTION
				
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
				# stantart    
				
				DISTORTION="$PAR" # PAR 16:15 = 1.0666666
				[[ $PAR == 0 ]] && DISTORTION="1"
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}\\t(standart)"				
				
				fi
				
				
	      # no padding
		 [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes
	
	
	
	}
	
pal-dar177(){
	 
		 
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.77|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
		[[ $DEBUG -gt 1 ]] && echo $CROP_PRESET
				
				
		 
				# Width
				
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`
				if [[ ! -z $CROP_PRESET_WIDTH ]]
				then
				
				# change to the preset values
				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"				
				else
				
				# keep the cropping detected values for the width (if not to big)
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				else
				FF_CROP_WIDTH="-cropleft 0 -cropright 0 "				
				fi
				
				
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				# Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
				# change to the preset values
				
				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc `
				CUT=$(floor2 $CUT) 
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# Distortion
			
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
				# stantart    

				DISTORTION="$PAR " 
				[[ $PAR == 0 ]] && DISTORTION="1"
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}\\t(standart)"				
				
				 fi
		 
	 
		 #no  padding
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes

	 
	 }
      
calc_new_sizes(){




		# new width
		NEW_WIDTH=`echo "($WIDTH -  $CROPLEFT - $CROPRIGHT) *  ${DISTORTION} /1 "|bc`
		# new height before padding
		NEW_HEIGHT_BP=`echo "($HEIGHT -  $CROPTOP - $CROPBOTTOM )  "|bc`
		# new height (after padding)
		NEW_HEIGHT=`echo "( $NEW_HEIGHT_BP +  $PADTOP + $PADBOTTOM ) "|bc`

		NEW_SIZE=${NEW_WIDTH}x${NEW_HEIGHT}

		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Resize: $SIZE -> $NEW_SIZE${NC}"
		


}

get_format() {

		DETECTED_FORMAT=""
		RATIO_I=`echo "($RATIO * 100) /1"|bc `
		
		
		[[ $DEBUG -gt 0 ]] && echo -e "\\n${cyan}$(box "Format detection")${NC}\\n"

		
		
		
	      # pal DAR 1.25
		 

if [[ ( $RATIO_I  -ge 122 && $RATIO_I -le 128 ) && ( $DAR == 0 || $DAR  == 1.25 ) ]]
	      then
		 
		 DETECTED_FORMAT="1.25 - pal reencoded !"
		 echo -e "${pink}# Format: $DETECTED_FORMAT ${NC}"
	      
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
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:\\t$FF_CROP_HEIGHT${NC}"
				else
				CROPTOP=0
				CROPBOTTOM=0
				FF_CROP_HEIGHT="" 
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:\\t no${NC}"
				fi
				
				# remove very small black border on the left and right (optional)
							   
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 / 1" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W:\\t$FF_CROP_WIDTH${NC}"
				else
				CROPLEFT=0
				CROPRIGHT=0
				FF_CROP_WIDTH="" 
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
				fi
				
				
				# distortion 
				DISTORTION="1.422 "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
		 
				# Padding: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
				
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
		 echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"
		
		 pal-dar133
	      fi


	      # 1.25 DAR 1.77
		 
	      if [[ ($RATIO_I -eq 125 || $RATIO_I -eq 122 ) && $DAR == 1.77 ]]
	      then
	 
		 # get a  cropdetection
	      cropdetection $CROP_FRAMES_S
		 
		 DETECTED_FORMAT="PAL DAR 1.77"
		 echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"

		 pal-dar177	      
	      fi
		 
	      # 1.25 DAR 2.21 !!!
		 
	      if [[ $RATIO_I -eq 125 && $DAR == 2.21 ]]
	      then

		 DETECTED_FORMAT="PAL DAR 2.21"
		 echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 

	      # padding
		 
		 PAD=`echo "scale=3;( ( $WIDTH / 1.777)  - ( $WIDTH / 2.21)  / 2)"|bc`
	      PAD=`round2 $PAD`
		 PADTOP=$PAD
		 PADBOTTOM=$PAD
	      FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
		 [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: $FF_PAD${NC}"
		  

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
				
		  # distortion 1.768
		  DISTORTION="1.768 "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    

		  
		  # get new sizes
		  calc_new_sizes				 
		
		 DETECTED_FORMAT=""
				 
	      fi      	 
		 
	      # 1.50 ntsc reencoded !
		 
	      if [[ $RATIO_I == 150  && ( $DAR == 0 || $DAR  == 1.50 ) ]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc reencoded !"
		 echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 # get a new cropdetection 
	      cropdetection $CROP_FRAMES_L
		 

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] &&echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="`echo "scale=3; 1.777 / $RATIO "|bc` "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi	
		 
	      # 1.50 ntsc DAR 1.77
		 
	      if [[ $RATIO_I == 150  &&  $DAR == 1.77 ]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc DAR 1.77"
		 echo -e "${green}# Format: $DETECTED_FORMAT${NC}"

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="`echo "scale=3; $ID_VIDEO_ASPECT  / $RATIO "|bc` "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi		 		 
		 
	      # 1.33
		 
	      if [[ ( $RATIO_I  -gt 127 && $RATIO_I -lt 160  && $RATIO_I != 150 ) && ($DAR == 0 || $DAR == 1.33 ) ]]
	      then
		 DETECTED_FORMAT="1.33"
		 echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"

	      # Cut the top and the bottom 
		 
		  CUT=`echo "scale=3;( $HEIGHT - ( $WIDTH / 1.777 )) / 2"|bc ` 
		  CUT=$(floor2 $CUT) 
		  CROPTOP=$CUT
		  CROPBOTTOM=$CUT
		  FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
		 
		 [[ $DEBUG -gt 0 ]] && echo -e "${cyan}Cutting: $FF_CROP_HEIGHT${NC}"
		 
		 # get new sizes
		 calc_new_sizes

	      fi
 
		 # 1.33 DAR 16/9 !!!
		 
		 if [[ ( $RATIO_I  -ge 127 && $RATIO_I -lt 160 && $RATIO_I != 150 ) && ( $DAR  == 1.77 ) ]]
		 then
		 DETECTED_FORMAT="4/3 DAR 16/9"
		 NOTICE="${NOTICE}This format($DETECTED_FORMAT) is not a video standart, please follow your recommendation."
		 
		 echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 
	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
				
		  # distortion 
		  DISTORTION="1.333 "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		  
		  # get new sizes
		  calc_new_sizes
		
	      
	      fi
		       
	      # 1.77
		 
	      if [[ $RATIO_I -ge 160 && $RATIO_I -lt 199 ]]
	      then
		 DETECTED_FORMAT="16/9"
		 echo -e "${green}# Format:$DETECTED_FORMAT ${NC}"


		 
				# cropping
		 
		 
				# normal (no detection)
				if [[ $CROPDETECTION  == 1 ]]
				then
				
				# Cropping H: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
				CROPLEFT=0              
				CROPRIGHT=0
			 	FF_CROP_WIDTH=""
				
				# Cropping H: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: no${NC}"
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
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:$FF_CROP_HEIGHT${NC}"
						else
						CROPTOP=0
						CROPBOTTOM=0
						FF_CROP_HEIGHT="" 
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: no${NC}"
						fi

		  
				
						# detection W (level detection 2 and 3)
						   
						if [[  $CROPDETECTION  -gt 2 && $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
						then
						FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W:$FF_CROP_WIDTH${NC}"
						else
						CROPLEFT=0
						CROPRIGHT=0
						FF_CROP_WIDTH="" 
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
						fi

							
			   fi

				
				
		# Padding: no
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		
		# get new sizes
		 calc_new_sizes

		fi				
				
	      # 2.35
		 
	      if [[ $RATIO_I -ge  199 && $RATIO_I -le 255 ]]
	      then
		 DETECTED_FORMAT="2.35"
		 echo -e "${green}# Format: $DETECTED_FORMAT${NC}"

	      
	      # padding
		 
		 PAD=`echo "scale=3;(($WIDTH / 1.777) - $HEIGHT) / 2"|bc`
	      PAD=`round2 $PAD`
		 PADTOP=$PAD
		 PADBOTTOM=$PAD
	      FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
		 [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: $FF_PAD${NC}"
		  

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
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

check_ouput_size(){



	   # empty-> take the default size
	   if [[ -z $FF_SIZE  ]]
	   then
	   #
	   FF_WIDTH=320
	   FF_HEIGHT=180
	   
	   # format valide
	   elif [[ ! -z $(echo "$FF_SIZE"|grep -0 [0-9]*x[0-9*])  ]]
	   then
	   
		#parse the format
		FF_SIZE=$(echo "$FF_SIZE"|grep -0 [0-9]*x[0-9*])
		
		TMP_WIDTH=$(echo $FF_SIZE|awk -F 'x' '{print $1}')
		TMP_HEIGHT=$(echo $FF_SIZE|awk -F 'x' '{print $2}')
				echo "$TMP_WIDTH x $TMP_HEIGHT"
		[[ ! -z $TMP_WIDTH && $TMP_WIDTH != 0 ]]
		TMP_WIDTH=$(round8 $TMP_WIDTH )
		TMP_HEIGHT=$(echo "$TMP_WIDTH/1.7777"|bc)
		TMP_HEIGHT=$(round8 $TMP_HEIGHT)
		
		echo "$TMP_WIDTH x $TMP_HEIGHT $(echo "scale=2;$TMP_WIDTH / $TMP_HEIGHT"|bc)"
		exit
	   # other -> take the default size
	   else
	   FF_WIDTH=320
	   FF_HEIGHT=180
	   
	   fi



}

encode(){

	   #check and evaluate the ouput size
	   
	   check_ouput_size "$FF_SIZE"

	   
	   if [[ $PAD != 0 ]]
	   then
	   FF_HEIGHT=`echo "$FF_WIDTH / $RATIO"|bc`
	   FF_HEIGHT=`round2 $FF_HEIGHT `
	   PAD=`echo "scale=3;(($FF_WIDTH / 1.777 ) - ($FF_WIDTH / $RATIO )) / 2"|bc`
	   PAD=`round2 $PAD`
	   FF_PAD=" -padtop $PAD -padbottom $PAD "
	   fi   
	      
	      

	      
	      
	  ### transcode the video to differents formats 
	  
		COMMAND=""
		
		if [[ -f $APP_DIR/formats/$OUTPUT_FORMAT.sh ]]
		then
		. "$APP_DIR/formats/$OUTPUT_FORMAT.sh"
		else
		
	  	case "$OUTPUT_FORMAT" in
		screenshot) . "$APP_DIR/formats/screenshot.sh" ;;
		montage) . "$APP_DIR/formats/montage.sh" ;;
		sample). "$APP_DIR/formats/sample-flv.sh" ;;
		esac
		
		fi
   
    }

execute(){
	      INPUT=$1
		    
	      DIRECTORY=`dirname "$INPUT"`
	      
	      SUBDIR=`basename "$INPUT"`
	      SUBDIR=${SUBDIR%%${EXTENTION}}
	      
	      OUTPUT=` basename $INPUT`
	      OUTPUT=${OUTPUT%%.???}
		 
		 
		 NOTICE=""
	      WARNING=""
	      ERROR=""
	      
	      


	      
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
	      
	      DISTORTION="1"
		 
	      # create the dir
	      [[ ! -d  "${DIRECTORY}/${SUBDIR}" ]] &&   mkdir  "${DIRECTORY}/${SUBDIR}"
	      
	      # clean  info if overwrite  != 1
	      [[ $OVERWRITE == 1 && -f ${DIRECTORY}/${OUTPUT}/info.txt ]] && rm ${DIRECTORY}/${OUTPUT}/info.txt 

		 
		 
		case "$OPERATION" in
		compatible) check_comp
		stop
		;;
		general)    
		  get_general_infos
		  stop
		  ;;
		
		video)	  
		  get_video_infos 
		  stop
		  ;;
		  
		audio)
		  get_audio_infos 
		  stop
		  ;;	
		infos)
		
		  ### check if the video is compatible with ffmpeg or mplayer
		  check_comp 
		  ### General informations 
		  get_general_infos
		  exit
		  ### Video informations 
		  get_video_infos      
		  ### extra informations
		  #get_extra_infos
		  ### Audio Informations
		  get_audio_infos
		  ###
		  get_format
		  
		  
		  stop
		  ;;
		  *)
		  
		### check if the video is compatible with ffmpeg or mplayer
		
		if  [[ $OVERWRITE == 2  || ! -f "${DIRECTORY}/${OUTPUT}/info.txt" ]]
		then
		check_comp 
		else
		[[ $DEBUG -gt 0 ]] && cat "${DIRECTORY}/${OUTPUT}/info.txt"
		eval "$(cat "${DIRECTORY}/${OUTPUT}/info.txt")"
		fi
				
		    
				if [[ $MPLAYER_VIDEO_TEST == 0 || $MPLAYER_AUDIO_TEST == 0 ]] 
				then
				ERROR="# ERROR: This video ($1) is not supported!"
				echo -e "\\n${RED}${ERROR}${NC}\\n"
				echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err
				stop
				else
				
				# try to read from the info file
				if  [[ $OVERWRITE == 2 ||  -z "$FILE_PATH" ]]
				then
			
				### General informations 
				get_general_infos
				### Video informations 
				get_video_infos	      
				### Audio Informations
				get_audio_infos
				
				
			 
				[[ ! -z $ERROR ]] &&  mediainfo ${INPUT} >> ${DIRECTORY}/${OUTPUT}.err

				# Get some infos about the fornat 1.77 pat ntsc ...
				get_format 
				
				save_info "\\n# Format infos\\n"
				save_info "DETECTED_FORMAT=\"$DETECTED_FORMAT\""
				
				save_info "FF_PAD=\"$FF_PAD\""
				save_info "PADTOP=\"$PADTOP\""
				save_info "PADBOTTOM=\"$PADBOTTOM\""	
				
				save_info "CROPTOP=\"$PADTOP\""
				save_info "CROPBOTTOM=\"$PADBOTTOM\""	

				save_info "CROPLEFT=\"$CROPLEFT\""				
				save_info "CROPRIGHT=\"$CROPRIGHT\""	
				
				save_info "FF_CROP_WIDTH=\"$FF_CROP_WIDTH\""
				save_info "FF_CROP_HEIGHT=\"$FF_CROP_HEIGHT\""
				
				save_info "DISTORTION=\"$DISTORTION\""
				

				save_info  "NEW_WIDTH=$NEW_WIDTH"
				save_info  "NEW_HEIGHT=$NEW_HEIGHT"
				save_info  "NEW_SIZE=$NEW_SIZE"
				
				fi
	 
				# check if the format is detected (pal 1.77 2.35 etc)
				
						if [[ -z $DETECTED_FORMAT  ]] 
						then
						ERROR="# ERROR: This video format ($1) is not supported!"
						echo -e "\\n${RED}${ERROR}${NC}\\n"
						echo $ERROR >> ${DIRECTORY}/${OUTPUT}.err
						save_info "${ERROR}"						
						
						else
						

							   
							   
							   ### create the logo or logos
							   VHOOK=""
							   if [[ ! -z $LOGOS_ADD ]]
							   then
							   
						   
								    for LOGO_ADD in $(echo $LOGOS_ADD)
								    do

							   
								    
									      LOGO_RESIZED=${DIRECTORY}/${SUBDIR}/$LOGO_ADD.png
									      LOGO_DIR="$APP_DIR/logos"	    
									      
										    # get the preset from LOGOS file 


										    LOGOS_PRESET=`grep  "^$LOGO_ADD|.*" ${APP_DIR}/config/LOGOS `
										    #echo "$LOGOS_PRESET $LOGOS_ADD"
												    
												    if [[ ! -z $LOGOS_PRESET ]]
												    then
												    # load the values
												    
												    eval "${LOGOS_PRESET#${LOGO_ADD}|}"
												    									      # run the function
												    add_logo 
												    
# 												    else
# 												    # load default values
#											    
# 												    # png or gif 
# 												    LOGO_FILE="test.png" 
# 												    # the width of the logo in %:example 10  (base on the Width of the video after cropping ) 
# 												    LOGO_PC_W=10
# 												    # the position X of the logo in %:example 10  (base on the Width of the video after cropping ) 
# 												    LOGO_PC_X=10
# 												    # the possition Y of the logo in %:example 30  (base on the Width of the video after cropping ) 
# 												    LOGO_PC_Y=25
# 												    
# 												    LOGO_MODE="-m 1"
# 												    LOGO_TRESHOLD="-t 000000"
# 												    LOGO_START=0
# 												    LOGO_DURATION=15
#												    add_logo 
																    
												    fi
												    

								    
								    done
							   
							   
							  fi	
						# start the encoding   
						encode
							 
					 fi			
				fi 				
		  ;;
		esac
	
		[[ $CLEAN == 1 ]] && clean "${DIRECTORY}/${OUTPUT}${EXTENTION}"											


}





	   # TODO
	   # check_ouput_size "$FF_SIZE"
	   




# $1 is a file
if [[ -f $(realpath "${1}") ]]
then

SCAN_TYPE=1
EXTENTION=$(echo $1  |grep -o -e "\..*$")

execute  "$(realpath "${1}")" 


# $1 is a folder
elif [[ -d  $(realpath "${1}") ]]
then


    SCAN_TYPE=2
    DIRECTORY=$(realpath "${1}")

    
    for VIDEO  in `find ${DIRECTORY}  -name "*${EXTENTION}"`
    do

    SUBDIR=`basename "$VIDEO"`
    SUBDIR=${SUBDIR%%${EXTENTION}}


      #if [[ ! -d ${DIRECTORY}/${SUBDIR} || $OVERWRITE  !=  0 ]]
      #then
      execute $VIDEO 
      #fi
    done
else 
usage
fi
exit 0
