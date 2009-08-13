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
		
		
		
		
	### create audio_${FF_AB}_${FF_AC}_$FF_AR.wma
	
	echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.wma ${NC}"
	if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.wma" ]]
	then
	
		echo -e "${green}# This file already exit. We going to use it${NC}"		

	else
	
		### check if resample 8bit to 16 is needed  (sox)

		resample_audio
		

		### create Audio

		#COMMAND="faac -q 500 -c $FF_AR -b $FF_AB --mpeg-vers 4 -o ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.aac ${DIRECTORY}/$SUBDIR/audio.wav"
		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/audio.wav -v 0 -ss  $SS  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec wmav2 -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.wma"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
	

	fi
	
	
	
	### create the video
	
	if [[  $FFMPEG_VIDEO == 0 ]]
	then
		### pipe mplayer rawvideo to ffmpeg
		
		echo -e "${yellow}# Resample video${NC}"
		COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
	else
	
		### create video_.h264 pass1
		
		echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.asf ${NC}"
		
		echo -e "${yellow}# pass 1${NC}"
		
		INPUT_VIDEO=$INPUT 
		[[ ! -z $SUB_FILE ]] && burn_subtitle		
		
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT_VIDEO} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS  -f asf -vcodec  msmpeg4 -y /dev/null "
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}

		### create video_.h264 pass2	

		echo -e "${yellow}# pass 2 ${NC}"
		

		[[ ! -z $SUB_FILE ]] && burn_subtitle
					
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT_VIDEO} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 2  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS  -f asf -vcodec  msmpeg4 -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.asf"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
	
	fi


	

	### Remux the sound and the video
	
	echo -e "${yellow}# Remux sound and video${NC}"
	COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.asf -i ${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.wma -acodec copy -vcodec copy -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
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
	[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"

		### stop timer

		TIME_END=$(date +%s)

		### calculate duration

		let "ENCODING_DURATION=$TIME_END - $TIME_START"

		### quit timer infos to log files (for evaluation)

		logTimer

	else
	echo -e "${RED}$FILE_INFOS${NC}"		
	fi