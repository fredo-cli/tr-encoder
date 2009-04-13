#!/usr/bin/bash		

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