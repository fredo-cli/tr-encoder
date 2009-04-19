#!/usr/local/bin/bash

FF_FORMAT="3gp"
PLAY_SIZE="_1"

FF_WIDTH=176
FF_HEIGHT=100

FF_FPS=15

FF_VBITRATE=80

FF_AB=12.2
FF_AC=1
FF_AR=8000
echo -e "\\n${BLUE}$(box "format: play-$FF_FORMAT-$PLAY_SIZE")${NC}"



	   ### Recalculate the padding 

	   if [[ ! -z $FF_PAD ]]
		  then

		  PAD=`echo "scale=3;((($FF_WIDTH / 1.777 ) - ($FF_WIDTH / $RATIO )) / 2)"|bc`
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
		
		
		
		

	   ### Create audio.wav

	   echo -e "${yellow}# Create audio.wav ${NC}"
	   if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio.wav" ]]
	   then

		    echo -e "${green}# This file (audio.wav) already exit.We going to use it${NC}"

	   else

		    COMMAND="mplayer -ao pcm:fast:waveheader:file=${DIRECTORY}/$SUBDIR/audio.wav -vc null -vo null ${INPUT}"
		    [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET=" > /dev/null  2>&1"
		    eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 
		    
		    ### check if resample 8bit to 16 is needed  (sox)
		    resample_audio

	   fi




		
		
		
		
	### create audio_${FF_AB}_${FF_AC}_$FF_AR.amr
	
	echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.amr ${NC}"
	if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.amr" ]]
	then
	
		echo -e "${green}# This file already exit. We going to use it${NC}"		

	else

		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/audio.wav  -ss  $SS  -ar $FF_AR -ab ${FF_AB}k -ac $FF_AC -acodec libamr_nb  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.amr"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC} 

	fi
	
	
	
	### create the video
	
	if [[  $FFMPEG_VIDEO == 0 ]]
	then
		### pipe mplayer rawvideo to ffmpeg
		
		echo -e "${yellow}# Resample video${NC}"
		COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK    -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
	else
	
		### create video_.h263
		
		echo -e "${yellow}# Create the video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}. ${NC}"
		
# 		echo -e "${yellow}# pass 1 ${NC}"
# 		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK    -f $FF_FORMAT -y /dev/null "
# 		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
# 		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}
# 		
# 		echo -e "${yellow}# pass 2 ${NC}"
# 		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 2  $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS  -f $FF_FORMAT -aspect 16:9 -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.mpeg4"
# 		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
# 		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}


		echo -e "${yellow}# only 1 pass  ${NC}"
		COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k   $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r $FF_FPS  $VHOOK  -ss $SS  -f $FF_FORMAT  -y  ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
		[[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
		eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}

	
	fi


	

	### Remux the sound and the video
	
	echo -e "${yellow}# Remux sound and video${NC}"
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

	if [[  $? == 1 ]]
	then 
	echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
	[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"
	else
	echo -e "${RED}$FILE_INFOS${NC}"		
	fi