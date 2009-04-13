#!/usr/bin/bash		


  	FF_FORMAT=mp4
	
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
		

          # Create audio.wav
		
		if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio.wav" ]]
		then
		
				echo -e "${yellow}# Create audio.wav ${NC}"		
				echo -e "${green}# This file (audio.wav) already exit.We going to use it${NC}"
		
		else
				echo -e "${yellow}# create audio.wav ${NC}"		
				COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/audio.wav -vc null -vo null ${INPUT}"
				[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET=" > /dev/null  2>&1"
				eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 

		fi
		
		
		
		
		
		# Create audio_ch6.wav
		if [[ $CHANNELS == 999 ]]
		then
				  echo -e "${yellow}# create audio_ch6.wav ${NC}"
				  COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/audio_ch6.wav -channels 6 -vc null -vo null  ${INPUT}"
				  [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET=" >/dev/null  2>&1"
				  eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
		fi
		
		
		
		
		
		# create audio_96ch2.aac
		if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_96ch2.aac" ]]
		then
		
				echo -e "${yellow}# Create audio_96ch2.aac ${NC}"		
				echo -e "${green}# This file (audio_96ch2.aac) already exit. We going to use it${NC}"		

		else
		
				# check if resample 8bit to 16 is needed  (sox)
				resample_audio
				
				# create audio_96ch2.aac
				echo -e "${yellow}# Create audio_96ch2.aac ${NC}"
				COMMAND="faac -q 100 -c 44100 -b 128 --mpeg-vers 4 -o ${DIRECTORY}/${SUBDIR}/audio_96ch2.aac ${DIRECTORY}/$SUBDIR/audio.wav"
				#COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -v 0 -ss  $SS  -r 24 -ar 44100 -ab 48k -ac 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3"
				[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
				eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
		

		fi
		
		
		
		


		if [[  $FFMPEG_VIDEO == 0 ]]
		then
				# pipe mplayer rawvideo to ffmpeg
				echo -e "${yellow}# Resample video${NC}"
				COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
				[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
				eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
		else
		
				# create video_${FF_WIDTH}x${FF_HEIGHT}.h264
				echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}.h264 ${NC}"
				
				echo -e "${yellow}# pass 1 ${NC}"
				COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1 -vcodec libx264 $FF_PRESET1  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r 24  $VHOOK  -ss $SS  -f $FF_FORMAT -y /dev/null "
				[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
				eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
				
				echo -e "${yellow}# pass 2 ${NC}"
				COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 2 -vcodec libx264 $FF_PRESET2 $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r 24  $VHOOK  -ss $SS  -f $FF_FORMAT -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}.h264"
				[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
				eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
		
		fi


	
		 
		# remux the sound and the video
		echo -e "${yellow}# Remux sound and video${NC}"
		COMMAND="MP4Box -fps 24  -add ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}.h264 -add ${DIRECTORY}/$SUBDIR/audio_96ch2.aac ${DIRECTORY}/${SUBDIR}/video_tmp.mp4"
		#COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}.h264 -i ${DIRECTORY}/$SUBDIR/audio_ch6.aac -acodec copy -vcodec copy -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.mp4"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  >/dev/null"
	     eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		# Use AtomicParsley
		
		COMMAND="AtomicParsley \"${DIRECTORY}/${SUBDIR}/video_tmp.mp4\" --metaEnema  --copyright \"Fredo-cli\"   --artist \"Fredo :-)\"  --title \"The art of encoding\"   --comment \"Made by Fredo\" -o \"${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.mp4\" --freefree --overWrite"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
	     eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		# clean up
		
		[[ -f  ${DIRECTORY}/${SUBDIR}/video_tmp.mp4 ]] && rm  ${DIRECTORY}/${SUBDIR}/video_tmp.mp4
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
			      
		 
		# check the file 
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
		FILE_INFOS=""
		get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.mp4"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.mp4${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi