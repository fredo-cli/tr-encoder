#!/usr/local/bin/bash

	### start timer

	TIME_START=$(date +%s)

	### display the format 

	echo -e "\\n${BLUE}$(box "format: $PREFIX-$FF_FORMAT-$PLAY_SIZE")${NC}"


	### create the logo or logos 

        add_logo 
	
	### Recalculate the padding
	
       if [[ ! -z $FF_PAD ]]
           then

           PAD=`echo "scale=3;(($FF_WIDTH / 1.777 ) - ($FF_WIDTH / $RATIO )) / 2"|bc`
		 

		 
           PAD=`round2 $PAD`
           FF_PAD=" -padtop $PAD -padbottom $PAD "
		 echo -e "${yellow}# Recalculate the padding  ${NC}"	
		 echo -e "${green}# $FF_PAD ${NC}"

        fi   
	
	
	### Recalculate the FF_HEIGHT_BP 
	FF_HEIGHT_BP=$( echo "${FF_HEIGHT} - ( 2*${PAD} )"|bc)
	echo -e "${yellow}# Recalculate the FF_HEIGHT_BP  ${NC}"	
	echo -e "${green}# FF_HEIGHT_BP=$FF_HEIGHT_BP ${NC}"

	### add 22 pad

	echo -e "${yellow}# add 22 to the paddding${NC}"	
	PAD=`echo "$PAD + 22"|bc`
	PAD=`round2 $PAD`
	FF_PAD=" -padtop $PAD -padbottom $PAD "
	echo -e "${green}# $FF_PAD ${NC}"
	
	
	
	# Create audio.wav
	dump_audio

	
	### create audio
	
	if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.amr" ]]
	then
			echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"		
			echo -e "${green}# This file (audio_${FF_AB}_${FF_AC}_$FF_AR.amr) already exit. We going to use it${NC}"	

	else



			  ### check if resample 8bit to 16 is needed  (sox)
			  resample_audio
			  
			  ### create audio_${FF_AB}_${FF_AC}_$FF_AR.amr

			  echo -e "${yellow}#Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"

			  COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/audio.wav  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libamr_nb  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}

	fi

	
	
	
	### create the video
	
	if [[  $FFMPEG_VIDEO == 0 ]]
	then
		### pipe mplayer rawvideo to ffmpeg
		
		echo -e "${red}# Resample video${NC}"
		#COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK    -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		#[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
 		#eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
	else
	
		### create video_.h263
		
		echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 ${NC}"
		
		if [[ $FF_PASS == 2 ]]
		then
		
		echo -e "${yellow}# pass 1 ${NC}"
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK -f $FF_FORMAT -y /dev/null "
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
		
		echo -e "${yellow}# pass 2 ${NC}"
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 2  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK -f $FF_FORMAT -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}

		else 
		
		echo -e "${yellow}# only 1 pass  ${NC}"
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k   $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK -f $FF_FORMAT  -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
		fi
	
	fi


	

	### Remux the sound and the video
	
	echo -e "${yellow}# Remux sound and video${NC}"

	# not working!  "Could not write header for output file"
	# COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr -ss $SS  -r ${FF_FPS}  -vcodec copy  -acodec copy -f 3gp -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
	COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/$SUBDIR/audio.wav  -ss  $SS  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libamr_nb -r ${FF_FPS}    -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
	[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
	eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 

	
	### clean up
	
	[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
	[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
		      
	  
		 
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