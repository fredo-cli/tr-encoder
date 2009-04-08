#!/usr/bin/bash		

	    echo -e "\\n${BLUE}$(box "format: play-flv")${NC}"
	   
	    



		# transform to pcm
		echo -e "${yellow}# create wav${NC}"		
		COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -vc null -vo null ${INPUT}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" > /dev/null  2>&1"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 

		if [[ $CHANNELS == 6 ]]
		then
		echo -e "${yellow}# create ch6${NC}"
		COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav -channels 6 -vc null -vo null  ${INPUT}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" >/dev/null  2>&1"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		fi
		
		# check if resample 8bit to 16 is needed  (sox)
		resample_audio
		
		# create audio
		echo -e "${yellow}# Create mp3${NC}"
		#COMMAND="lame -h --abr 128  ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav  ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3"
		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -v 0 -ss  $SS  -r 24 -ar 44100 -ab 128000 -ac 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 


		if [[ -z $FFMPEG_VIDEO_YES ]]
		then
		# pipe mplayer rawvideo to ffmpeg
		echo -e "${yellow}# Resample video${NC}"
		COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		else
		# create video
		echo -e "${yellow}# Create flv${NC}"
		COMMAND="${FFMPEG} -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		fi
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} } 
		
		 
		# remux the sound and the video
		echo -e "${yellow}# Remux sound and video${NC}"
		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.flv -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.mp3 -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/sample.flv"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		

			      
		 
		# check the file 
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
		FILE_INFOS=""
		get_file_infos "${DIRECTORY}/$SUBDIR/sample.flv"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/sample.flv${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi