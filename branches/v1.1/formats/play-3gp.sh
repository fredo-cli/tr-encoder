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

	
	### Create audio.wav ###
	
	dump_audio

	
	### create audio
	
	if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.amr" ]]
	then
			echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"		
			echo -e "${green}# This file (audio_${FF_AB}_${FF_AC}_$FF_AR.amr) already exit. We going to use it${NC}"	

	else



			  ### check if resample 8bit to 16 is needed  (sox)
			  # resample_audio
			  
			  ### create audio_${FF_AB}_${FF_AC}_$FF_AR.amr

			  echo -e "${yellow}#Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"

			  COMMAND="${FFMPEG_WEBM}  -i ${DIRECTORY}/$SUBDIR/audio.wav  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libopencore_amrnb  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}

	fi

	
	
	
	### create the video
	

	
		### create video_.h263
		
		echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 ${NC}"
		

		 PADTOP=$(echo "$PADTOP + 22"|bc)
		 PADBOTTOM=$(echo "$PADBOTTOM + 22"|bc)
	   FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
		 echo -e "${yellow}# Adding 2*22 px to the video: $FF_PAD ${NC}"
		

		echo -e "${yellow}# pass 1 ${NC}"
		
		INPUT_VIDEO=$INPUT 
		[[ ! -z $SUB_FILE ]] && burn_subtitle	

		
		COMMAND="${FFMPEG_WEBM} -threads 1 -i  ${INPUT_VIDEO} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1  -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT_3G}:0:${PADBOTTOM}'  -r $FF_FPS  -f $FF_FORMAT -y /dev/null "
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
		
				
		echo -e "${yellow}# pass 2 ${NC}"

		[[ ! -z $SUB_FILE ]] && burn_subtitle			
		
		COMMAND="${FFMPEG_WEBM} -threads 1 -i  ${INPUT_VIDEO} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 2 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT_3G}:0:${PADBOTTOM}'  -r $FF_FPS   -f $FF_FORMAT -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}


	
	


	

	### Remux the sound and the video
	
	echo -e "${yellow}# Remux sound and video${NC}"

	COMMAND="${FFMPEG_WEBM}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr  -ss  $SS  -r ${FF_FPS}   -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
	[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
	eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 

	
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
	echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
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