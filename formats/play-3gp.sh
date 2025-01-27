#!/usr/local/bin/bash

	### display the format ### 

	echo -e "\\n${BLUE}$(box "format: $PREFIX-$FF_FORMAT-$PLAY_SIZE")${NC}"
	
	
	### Start timer ###

	TIME_START=$(date +%s)


	### Create the logo or logos ###

    add_logo 
    

	### Check the sub ###
        
    check_sub


	### Calculate the padding for ffmpeg ###
	
	calculate_padding

	### Change to the video directory  ( to avoid the pass.log issue ) ###

	cd ${DIRECTORY}/${SUBDIR}/


  ### create audio ###

		if [[  $FF_AC == 1 && $CHANNELS == 6 ]]
		then

        ### 6 to 1 resample not suported by ffmpeg

        ### create audio_2.aac

        echo -e "${yellow}# Create audio_2.aac (6 to 1 resample is not suported by ffmpeg) ${NC}"
        COMMAND="${FFMPEG_WEBM} -y -threads $THREADS  -i ${INPUT} -vn  -ss  $SS   -ar ${FF_AR} -ab ${FF_AB}k -ac 2   ${DIRECTORY}/${SUBDIR}/audio_2.aac"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||   fatal_error


        ### create audio_${FF_AB}_${FF_AC}_$FF_AR.amr
        echo -e "${yellow}#Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"
        COMMAND="${FFMPEG_WEBM} -threads $THREADS -i ${DIRECTORY}/${SUBDIR}/audio_2.aac  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libopencore_amrnb  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||   fatal_error

    else

        ### create audio_${FF_AB}_${FF_AC}_$FF_AR.amr
        echo -e "${yellow}#Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"
        COMMAND="${FFMPEG_WEBM} -threads $THREADS   -i ${INPUT}  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libopencore_amrnb  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||   fatal_error

    fi




  ### create the video

  ### create video_.h263

  echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 ${NC}"


  PADTOP=$(echo "$PADTOP + 22"|bc)
  PADBOTTOM=$(echo "$PADBOTTOM + 22"|bc)
  FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
  echo -e "${yellow}# Adding 2*22 px to the video: $FF_PAD ${NC}"


  echo -e "${yellow}# pass 1 ${NC}"


  [[ ! -z $SUB_FILE ]] && burn_subtitle


  COMMAND="${FFMPEG_WEBM} -threads $THREADS $DEINTERLACE -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile  ${OUTPUT} -pass 1  -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT_3G}:0:${PADBOTTOM} $VF_MOVIE ' -aspect 176:144  -r $FF_FPS  -f $FF_FORMAT -y /dev/null "
  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error


  echo -e "${yellow}# pass 2 ${NC}"

  [[ ! -z $SUB_FILE ]] && burn_subtitle

  COMMAND="${FFMPEG_WEBM} -threads $THREADS $DEINTERLACE -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile ${OUTPUT} -pass 2 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT_3G}:0:${PADBOTTOM} $VF_MOVIE ' -aspect 176:144  -r $FF_FPS   -f $FF_FORMAT -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error


	
	


	

	### Remux the sound and the video
	
	echo -e "${yellow}# Remux sound and video${NC}"

	COMMAND="${FFMPEG_WEBM} -threads $THREADS  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr  -ss  $SS  -r ${FF_FPS}   -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
	[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
	eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error

	
	### clean up
	
	[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
	[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
	[[ ! -z $SUB_FILE && -f "$FIFO" ]] && rm  "$FIFO"
		      
	  
		 
	### check the file 
	[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
	FILE_INFOS=""
	get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"

	if [[  $? == 0 ]]
	then 
	echo -e "${GREEN}#${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
	[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >> "${DIRECTORY}/$SUBDIR/sample.up"

	### stop timer

	TIME_END=$(date +%s)

	### calculate duration

	let "ENCODING_DURATION=$TIME_END - $TIME_START"

	### quit timer infos to log files (for evaluation)

	logTimer

	else
	echo -e "${RED}$FILE_INFOS${NC}"		
	fi