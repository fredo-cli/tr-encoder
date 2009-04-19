#!/usr/bin/bash		

  	
	
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
				[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" > /dev/null  2>&1"
				eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 

		fi

	
		
		
		
		### create audio_96ch2.mp3
		if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3" ]]
		then
		
				echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 ${NC}"		
				echo -e "${green}# This file (audio_${FF_AB}_${FF_AC}_$FF_AR.mp3) already exit. We going to use it${NC}"		

		else
		
				  ### check if resample 8bit to 16 is needed  (sox)
				  resample_audio
				  
				  ### create audio_96ch2.mp3
				  echo -e "${yellow}#Create audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 ${NC}"
				  #COMMAND="lame -h --abr 48  ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav  ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3"
				  COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/audio.wav -v 0 -ss  $SS   -ar ${FF_AR} -ab ${FF_AB}k -ac ${FF_AC}  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3"
				  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
				  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		

		fi
		
		
		
		


		if [[  $FFMPEG_VIDEO == 0 ]]
		then
		
			  ### pipe mplayer rawvideo to ffmpeg
			  echo -e "${yellow}# Resample video${NC}"
			  COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.${FF_FORMAT}"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		
		else
			  
			  # create video
			  echo -e "${yellow}# Create the video h.263 ${NC}"

			  echo -e "${yellow}# pass 1 ${NC}"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
			  COMMAND="${FFMPEG} -an $DEINTERLACE -i ${INPUT} -passlogfile /tmp/${OUTPUT}.log  -pass 1  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.71  -g 500     $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS -f $FF_FORMAT -y /dev/null"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}

			  COMMAND="${FFMPEG} -an $DEINTERLACE -i ${INPUT} -passlogfile /tmp/${OUTPUT}.log   -pass 2  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.71  -g 500     $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS  -f $FF_FORMAT -y ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
			  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
			  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		
		fi

	
		 
		### remux the sound and the video
		echo -e "${yellow}# Remux sound and video${NC}"
		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 -acodec copy -vcodec copy -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
		eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		### use flvtool2
		
		COMMAND="flvtool2 -U  -comment:\"Encoded and delivered by previewnetworks.com\"  -metadatacreator:\"Previewnetworks Encoding System\"  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT} ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
		eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		### clean up
		
		[[ -f  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT} ]] && rm  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT}
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
			      
		 
		### check the file 
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
		FILE_INFOS=""
		get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi