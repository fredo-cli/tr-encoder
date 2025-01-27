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

	### Change to the video directory  ( to avoid the pass.log issue ) ###

        cd ${DIRECTORY}/${SUBDIR}/



		if [[  $FF_AC == 1 && $CHANNELS == 6 ]]
		then

        ### 6 to 1 resample not suported by ffmpeg

        ### create audio_2.mp3

        echo -e "${yellow}# Create audio_2.mp3 (6 to 1 resample is not suported by ffmpeg) ${NC}"
        COMMAND="${FFMPEG_WEBM} -y -threads $THREADS  -i ${INPUT} -vn -ss  $SS   -ar ${FF_AR} -ab ${FF_AB}k -ac 2   ${DIRECTORY}/${SUBDIR}/audio_2.mp3"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} || fatal_error

        ### create audio_96ch2.mp3
        echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 ${NC}"
        COMMAND="${FFMPEG_WEBM} -y -threads $THREADS  -i ${DIRECTORY}/${SUBDIR}/audio_2.mp3 -vn -ss  $SS   -ar ${FF_AR} -ab ${FF_AB}k -ac ${FF_AC}  -y ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  fatal_error

    else

        ### create audio_96ch2.mp3
        echo -e "${yellow}# Create audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 ${NC}"
        COMMAND="${FFMPEG_WEBM} -y -threads $THREADS  -i ${INPUT} -vn -ss  $SS   -ar ${FF_AR} -ab ${FF_AB}k -ac ${FF_AC}  ${DIRECTORY}/${SUBDIR}/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3"
        [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
        eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  fatal_error

    fi

	


    ### create video ###

    echo -e "${yellow}# Create the video h.263 ${NC}"
    echo -e "${yellow}# pass 1 ${NC}"


    [[ ! -z $SUB_FILE ]] && burn_subtitle

    [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
    COMMAND="${FFMPEG_WEBM} -threads $THREADS   $DEINTERLACE -i ${INPUT} -passlogfile  ${OUTPUT} -pass 1  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.70  -g 500 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT}:0:${PADBOTTOM} $VF_MOVIE '  -r $FF_FPS   -ss $SS -f $FF_FORMAT -an -y /dev/null"
    eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} || fatal_error




    echo -e "${yellow}# pass 2 ${NC}"

    [[ ! -z $SUB_FILE ]] && burn_subtitle

    [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
    COMMAND="${FFMPEG_WEBM} -threads $THREADS   $DEINTERLACE -i ${INPUT} -passlogfile ${OUTPUT}   -pass 2  -b ${FF_VBITRATE}k  -bt ${FF_VBITRATE}k  -me_range 25 -i_qfactor 0.70  -g 500 -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT}:0:${PADBOTTOM} $VF_MOVIE ' -r $FF_FPS   -ss $SS  -f $FF_FORMAT -an -y ${DIRECTORY}/${SUBDIR}/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263"
    eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} || fatal_error



	

    ### remux the sound and the video

    echo -e "${yellow}# Remux sound and video${NC}"
    COMMAND="${FFMPEG_WEBM} -threads $THREADS   -i ${DIRECTORY}/$SUBDIR/video_${FF_WIDTH}x${FF_HEIGHT}_${FF_FPS}_${FF_VBITRATE}.h263 -i ${DIRECTORY}/$SUBDIR/audio_${FF_AB}_${FF_AC}_$FF_AR.mp3 -acodec copy -vcodec copy  -r $FF_FPS -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT}"
    [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
    eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} ||  fatal_error

		
    ### use flvtool2

    echo -e "${yellow}# flvtool2${NC}"
    COMMAND="flvtool2 -U  -comment:\"Encoded and delivered by previewnetworks.com\"  -metadatacreator:\"Previewnetworks Encoding System\"  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT} ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"
    [[ $DEBUG -gt 1 ]] && QUEIT=""  || QUEIT="  2>/dev/null"
    eval "$COMMAND $QUEIT" && echo -e ${green}$COMMAND$QUEIT${NC} || fatal_error
		
		
		### clean up
		
		[[ -f  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT} ]] && rm  ${DIRECTORY}/${SUBDIR}/${OUTPUT}_tmp.${FF_FORMAT}
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
 		[[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
 		[[ ! -z $SUB_FILE && -f "$FIFO" ]] && rm "$FIFO"
			      
		 
		### check the file 
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
		FILE_INFOS=""
		get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"

		if [[  $? == 0 ]]
		then 
		echo -e "${GREEN}#${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >>  "${DIRECTORY}/$SUBDIR/sample.up"

		### stop timer

		TIME_END=$(date +%s)

		### calculate duration

		let "ENCODING_DURATION=$TIME_END - $TIME_START"

		### quit timer infos to log files (for evaluation)

		logTimer

		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi