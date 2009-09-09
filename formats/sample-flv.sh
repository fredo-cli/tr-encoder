#!/usr/bin/bash		

		# transform to pcm
		COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -vc dummy -vo null   ${INPUT} > /dev/null;\\n"
		
		
		if [[ $CHANNELS == 6 ]]
		then
		COMMAND="${COMMAND}mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/${OUTPUT}_ch6.wav -channels 6 -vc null -vo null   ${INPUT} > /dev/null;\\n"
		fi
		
		# check if resample 8bit to 16 is needed  (sox)
		# resample_audio
		
		# make a sample audio
		COMMAND="${COMMAND}${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav -ss $SS -t 20 -r 24 -ar 44100 -ab 128000 -ac 2  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3;\\n"
		


		if [[ $FFMPEG == 0 ]]
		then
		# pipe mplayer rawvideo to ffmpeg
		COMMAND="${COMMAND}resample_video;\\n"
		COMMAND="${COMMAND}${FFMPEG}  $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS -t 20  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;\\n"
		else
		# make a sample video flv
		COMMAND="${COMMAND}${FFMPEG} -an $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS -t 20   -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv;\\n"
		fi
		
		 
		# remux the sound and the video
		COMMAND="${COMMAND}${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.flv -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.mp3 -acodec copy -vcodec copy  -y ${DIRECTORY}/${SUBDIR}/sample.flv;"
		

			      
		 # write the code
	      [[ $DEBUG -gt 1 ]] && echo -e "\\n$COMMAND\\n" || echo -e "$COMMAND" > ${DIRECTORY}/${SUBDIR}/code.txt

	      if [[ $DEBUG -gt 1 ]]
	      then
			   [[ $OVERWRITE != 1 ]] && eval  `echo -e "$COMMAND"` 
	      else
			   [[ $OVERWRITE != 1 ]] && eval `echo -e "$COMMAND"` > /tmp/mencoder.log 2>&1
	      fi
		 
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