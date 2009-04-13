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
				[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT=" > /dev/null  2>&1"
				eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 

		fi

	
		
		
		
		# create audio_96ch2.mp3
		if [[ $OVERWRITE == 0 && -f "${DIRECTORY}/$SUBDIR/audio_96ch2.mp3" ]]
		then
		
				echo -e "${yellow}# Create audio_96ch2.mp3${NC}"		
				echo -e "${green}# This file (audio_96ch2.mp3) already exit. We going to use it${NC}"		

		else
		
				  # check if resample 8bit to 16 is needed  (sox)
				  resample_audio
				  
				  # create audio_96ch2.mp3
				  echo -e "${yellow}# Create audio_96ch2.mp3 ${NC}"
				  #COMMAND="lame -h --abr 48  ${DIRECTORY}/$SUBDIR/${OUTPUT}.wav  ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp3"
				  COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/audio.wav -v 0 -ss  $SS  -r 24 -ar 44100 -ab 48k -ac 2  -y ${DIRECTORY}/${SUBDIR}/audio_96ch2.mp3"
				  [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
				  eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		

		fi
		
		
		
		


		if [[  $FFMPEG_VIDEO == 0 ]]
		then
		# pipe mplayer rawvideo to ffmpeg
		echo -e "${yellow}# Resample video${NC}"
		COMMAND="${FFMPEG} -v 0 $DEINTERLACE -r   $FPS -f yuv4mpegpipe -i ${DIRECTORY}/$SUBDIR/${OUTPUT}.yuv -b 900k $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}.flv"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		else
		# create video
		echo -e "${yellow}# Create flv${NC}"
		
		echo -e "${yellow}# pass 1 ${NC}"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
		COMMAND="${FFMPEG} -an $DEINTERLACE -i ${INPUT} -passlogfile /tmp/${OUTPUT}.log  -pass 1  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.71  -g 500     $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r 24  $VHOOK  -ss $SS -f flv -y /dev/null"
		eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		
		COMMAND="${FFMPEG} -an $DEINTERLACE -i ${INPUT} -passlogfile /tmp/${OUTPUT}.log   -pass 2  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.71  -g 500     $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT_BP} -r 24  $VHOOK  -ss $SS  -f flv -y ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}.h263"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		fi
		
		#COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -s 640x368  -passlogfile /tmp/${OUTPUT}.log -pass 1 -vcodec libx264 -vpre default -vpre main -level 30 -refs 2 $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -f mp4 -y /dev/null "
		#[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     #eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
 
		#COMMAND="${FFMPEG} -threads 1 -i  ${INPUT} -an -b ${FF_VBITRATE}k -s 640x368  -passlogfile /tmp/${OUTPUT}.log -pass 2 -vcodec libx264 -vpre default -vpre main -level 30 -refs 2 $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24  $VHOOK  -ss $SS  -f mp4 -y  ${DIRECTORY}/${SUBDIR}/${OUTPUT}.mp4"
# 		#[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     #eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC}
		
		#ffmpeg  -i video/video1.org -acodec libmp3lame -an-b 1600k -s 640x360 -r 24 -y video/video1/test.flv


		#ffmpeg -i in.mov 
		#-ab 48k -ac 2 -ar 44100 -f flv 
		#-deinterlace -nr 500 
		#-s 640x420 -r 30 
		# -bufsize 4096

		# 320

		#pb r 23 !
		
		# 270*1024*117 = 32348160/8  4043520
		
		# -b 270k  
		# 263672*8

		#-b 270k  -bt 270k 
		# 263672
	
		# -b 270k  -bt 270k -qmin 2 -qmax 8 
		# 263672
		 

		
		# -b 270k -minrate 270k -maxrate 270k -bufsize 1835k
		

		# -b 270k -me_range 25 -i_qfactor 0.71 
		# -b 270k -me_range 25 -i_qfactor 0.9 -qmin 1 -qmax 1 
		# -b 270k -me_range 25 -i_qfactor 0.90 -qmin 8  -qmax 8
		
		
		
		#640
		#-b 650k -me_range 25 -i_qfactor 0.71 -g 500 high.fl
		
	
		 
		# remux the sound and the video
		echo -e "${yellow}# Remux sound and video${NC}"
		COMMAND="${FFMPEG}  -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}.h263 -i ${DIRECTORY}/$SUBDIR/audio_96ch2.mp3 -acodec copy -vcodec copy -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.flv"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		# use flvtool2
		
		COMMAND="flvtool2 -U ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.flv ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.flv"
		[[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
	     eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  echo -e ${red}$COMMAND${NC} 
		
		
		# clean up
		
		[[ -f  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.flv ]] && rm  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.flv
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
			      
		 
		# check the file 
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
		FILE_INFOS=""
		get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.flv"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.flv${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/sample.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi