#!/bin/bash

APP_NAME=`basename "$0"`
CONF_NAME=."$APP_NAME"rc
#APP_DIR=`dirname "$0"`
APP_DIR=$(readlink -f $0 | xargs dirname)

# Import configuration file, possibly overriding defaults.
[ -r ~/"$CONF_NAME" ] && . ~/"$CONF_NAME"

# Include all funtions
. "$APP_DIR/lib/MAIN"

DEBUG=0
DISPLAY=0
OVERWRITE=0
CROPDETECTION=1
TRY=""
LOGO_ADD=""

# Path to ffmpeg
#FFMPEG="/home/fredo/ffmpeg/ffmpeg/ffmpeg"
FFMPEG="ffmpeg"


EXTENTION="org"
#EXTENTION="VOB"





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


    while getopts "f:T:l:e:c:DydY" option
    do
	case "$option" in
	c)	   CROPDETECTION=$OPTARG;;	
	d)      DISPLAY=1;;	
	D)      DEBUG=1;;
	e)	   EXTENTION="$OPTARG";;		
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
	
                                                                                                
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.33|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
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
	 
		 
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.77|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
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

		COMMAND="${FFMPEG} $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24   $VHOOK -an -ss $(echo "$SS + 10 "|bc)  -vframes 1 -y ${DIRECTORY}/${OUTPUT}.jpg;"
	     #COMMAND="${COMMAND}display  ${DIRECTORY}/${OUTPUT}.jpg & "
		;;
		montage)	
		
		# get the time 
		
		FF_FPS=`echo "scale=2 ; 11 / ${DURATION_S} "|bc`
		FF_FPS="0$FF_FPS"
		FF_SS=`echo "$DURATION_S / 11"|bc`
		echo $FF_FPS  ${DURATION_S} $FF_SS
				
		# create a folder montage
		
		[[ ! -d "${DIRECTORY}/$SUBDIR/montage" ]] && mkdir "${DIRECTORY}/$SUBDIR/montage"
		
		# extract the pictures
		COMMAND="${FFMPEG} $DEINTERLACE -i ${INPUT} -ss $FF_SS -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r $FF_FPS  $VHOOK -an -ss $(echo "$SS + 2 "|bc)  -vframes 10 -y ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_%2d.jpg;###"
		COMMAND="${COMMAND}rm -f  ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_01.jpg ;###"
		COMMAND="${COMMAND}montage  ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_[0-9]*.jpg -geometry 160x90+1+1 ${DIRECTORY}/$SUBDIR/montage.png;###"
		
		# check the file 

		RESULTS_SIZE=`stat -c %s "${DIRECTORY}/$SUBDIR/montage.png"`
		if [ "$RESULTS_SIZE" -gt 100 ]
		then

		COMMAND_DISPLAY="$COMMAND_DISPLAY<file>\\n"
		COMMAND_DISPLAY="$COMMAND_DISPLAY<path>${DIRECTORY}/$SUBDIR/montage.png</path>\\n"
		COMMAND_DISPLAY="$COMMAND_DISPLAY<format>$(file   video/1483_3164/montage.png |awk -F , '{print $2}'|tr -d " ")</format>\\n"
		COMMAND_DISPLAY="$COMMAND_DISPLAY<md5>$(md5sum -b video/1483_3164/montage.png|grep -o ".* "|tr -d " ")</md5>\\n"
		COMMAND_DISPLAY="$COMMAND_DISPLAY<size>$RESULTS_SIZE</size>\\n"
		COMMAND_DISPLAY="$COMMAND_DISPLAY</file>\\n"
		
		else
		COMMAND_DISPLAY="ERROR:file ${DIRECTORY}/$SUBDIR/montage.png not created"
		fi 

		
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
		
# 		COMMAND="${COMMAND}${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav -ss  $(echo "$SS  + 10 "|bc) -t 20 -r 24 -ar 48000 -ab 128000 -ac 6  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_ch6.aac;###"
		fi
		
		# check if resample 8bit to 16 is needed  (sox)
		resample_audio
		
		# make a sample audio
		COMMAND="${COMMAND}${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -ss  $(echo "$SS  + 10 "|bc) -t 20 -r 24 -ar 44100 -ab 128000 -ac 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3;###"
		


		if [[ -z $FFMPEG_VIDEO_YES ]]
		then
		# pipe mplayer rawvideo to ffmpeg
		COMMAND="${COMMAND}resample_video;###"
		COMMAND="${COMMAND}${FFMPEG}  $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;###"
		else
		# make a sample video
		
		# flv
		COMMAND="${COMMAND}${FFMPEG} -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20   -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;###"
		
		# mp4 !!!
# 		COMMAND="${COMMAND}${FFMPEG} -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $(echo "$SS  + 10 "|bc) -t 20 -f mp4  -vcodec libx264 -vpre default -vpre main -level 30 -refs 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.m4v;###"
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
		COMMAND="${COMMAND}${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.flv -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.mp3 -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.flv;"
		
		# mp4 !!!
		#COMMAND="${COMMAND}${FFMPEG} -vtag mp4v -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.m4v -i ${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.aac -acodec copy -vcodec copy -ac 6 -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp_1.mp4;###"
		
		#COMMAND="${COMMAND}qt-faststart ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp_1.mp4 ${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.mp4;###"
		
		
		
		
		COMMAND_DISPLAY="${DIRECTORY}/${SUBDIR}/${OUTPUT}_1.flv;###"
		
		;;
		
		normal) 
		
		COMMAND="${FFMPEG} $DEINTERLACE -i ${INPUT}  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  -b 700000 -aspect 1.77  $VHOOK  -ss $SS  -ar 48000 -ab 128000 -ac 2 -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp4"
		
		;;
		esac

	      
	      echo -e "`echo $COMMAND| sed "s/###/\\n/g" `" > ${DIRECTORY}/${SUBDIR}/code.txt
	      echo -e "\\n`echo $COMMAND| sed "s/###/\\n/g" `\\n" 

	      if [[ $DEBUG -eq 1 ]]
	      then
	      [[ $OVERWRITE != 1 ]] && eval  `echo "$COMMAND"| sed "s/###//g"` 
	      else
	      [[ $OVERWRITE != 1 ]] && eval `echo "$COMMAND" | sed s"/###//g"` > /tmp/mencoder.log 2>&1
	      fi
		 
		 # Display

		  if [[ $DISPLAY == 1 ]]
		  then
		  echo -e "$COMMAND_DISPLAY"
		  fi
		 
		 

		 
		 
    
    }
  
  
  #############################  

execute(){

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


				LOGOS_PRESET=`grep  "^$LOGO_ADD|.*" ${APP_DIR}/config/LOGOS `
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
		
		
		if [[ $OVERWRITE -lt 2 ]]
		then
		REMOVE_FILE_CONFIRM="n"
		echo "Do you whant to remove this video? [y/N]"

		read -t 30 REMOVE_FILE_CONFIRM

				if [[ $REMOVE_FILE_CONFIRM = 'y' ]] || [[ $REMOVE_FILE_CONFIRM = 'Y' ]]
				then
				rm ${DIRECTORY}/${OUTPUT}.${EXTENTION}
				echo "The video ${DIRECTORY}/${OUTPUT}.${EXTENTION} is remove"
				fi
		fi											


}


# $1 is a file
if [[ -f "${1}" ]]
then


execute $1 


# $1 is a folder
elif [[ -d "${1}" ]]
then

    DIRECTORY=$1

    
    for VIDEO  in `find ${DIRECTORY}  -name "*.${EXTENTION}"`
    do

    SUBDIR=`basename "$VIDEO"`
    SUBDIR=${SUBDIR%%.${EXTENTION}}


      if [[ ! -d ${DIRECTORY}/${SUBDIR} || $OVERWRITE  !=  0 ]]
      then
      execute $VIDEO 
      fi
    done
else 
usage
fi
exit 0
