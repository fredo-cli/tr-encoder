#!/usr/local/bin/bash

	### display the format ### 

	echo -e "\\n${BLUE}$(box "format: $PREFIX-$FF_FORMAT-$PLAY_SIZE")${NC}"
	
	
	### start timer ###

	TIME_START=$(date +%s)


	### create the logo or logos ###

    add_logo 
    

	### check the sub ###
        
    check_sub


	### Calculate the padding for ffmpeg ###
	
	calculate_padding    
	   
  ### check if 6 or 2 audio channels ###

  if [[ $CHANNELS == 6 && $FF_AC == 6 ]]
  then

  # keep the values
  echo -e "${yellow}# 6 audio channels${NC}"

  else

  echo -e "${yellow}# 2 audio channels${NC}"
  # change some values if the input video is not 6 channels
  [[ $FF_AC == 6 ]] &&  FF_AC=2 && FF_AB=$(echo "$FF_AB / 3" |bc)

  fi

### Change to the video directory  ( to avoid the pass.log issue ) ###

cd ${DIRECTORY}/${SUBDIR}/
		   
		

  ### Create Audio ###

  ### create audio_${FF_AB}_${FF_AC}_$FF_AR.aac

  echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.aac ${NC}"
  COMMAND="${FFMPEG_WEBM} -threads $THREADS   -i ${INPUT} -vn -ss  $SS  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.aac"
  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND $QUIET${NC} ||   fatal_error


	

	
		
	
	### Create the video ###
	

  ### create video_${FF_WIDTH}x${FF_HEIGHT}.h264

  echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h264 ${NC}"

  echo -e "${yellow}# pass 1 ${NC}"



  [[ ! -z $SUB_FILE ]] && burn_subtitle

  COMMAND="${FFMPEG_WEBM} -threads $THREADS -i  ${INPUT} -an $DEINTERLACE  -b ${FF_VBITRATE}k -passlogfile ${OUTPUT} -pass 1 -vcodec libx264 $FF_PRESET1 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT}:0:${PADBOTTOM} $VF_MOVIE '   -r $FF_FPS -ss $SS  -f $FF_FORMAT -aspect 16:9  -y /dev/null "
  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error

  echo -e "${yellow}# pass 2 ${NC}"

  [[ ! -z $SUB_FILE ]] && burn_subtitle

  COMMAND="${FFMPEG_WEBM} -threads $THREADS -i  ${INPUT} -an  $DEINTERLACE -b ${FF_VBITRATE}k -passlogfile ${OUTPUT} -pass 2 -vcodec libx264 $FF_PRESET2 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT}:0:${PADBOTTOM} $VF_MOVIE ' -r $FF_FPS -ss $SS  -f $FF_FORMAT -aspect 16:9  -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h264"
  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error

	

	### Remux the sound and the video MP4Box
	
	echo -e "${yellow}# Remux sound and video with MP4Box${NC}"
	COMMAND="${MP4BOX} -fps $FF_FPS  -add ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h264 -add ${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.aac ${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT}"
	[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  >/dev/null"
	eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||   fatal_error
	
	
	### Use AtomicParsley
	echo -e "${yellow}# add some tags${NC}"
	COMMAND="AtomicParsley \"${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT}\" --metaEnema  --copyright \"\"   --artist \"\"  --title \"\"   --comment \"Encoded and delivered by previewnetworks.com\" -o \"${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}\" --freefree --overWrite"
	[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  >/dev/null"
	eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  fatal_error
	
	
	### clean up
	
	echo -e "${yellow}# clean up${NC}"
	
	[[ -f  ${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT} ]] && rm  ${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT}
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
	[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >>  "${DIRECTORY}/$SUBDIR/sample.up"

		### stop timer

		TIME_END=$(date +%s)

		### calculate duration

		let "ENCODING_DURATION=$TIME_END - $TIME_START"

		### quit timer infos to log files (for evaluation)

		logTimer


	else
	echo -e "${RED}$FILE_INFOS${NC}"		
	fi
	
