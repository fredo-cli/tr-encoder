#!/usr/local/bin/bash

      ### display the format ###

      echo -e "\\n${BLUE}$(box "format: $PREFIX-$FF_FORMAT-$PLAY_SIZE")${NC}"

	
      ### create video_${FF_WIDTH}x${FF_HEIGHT}.vp8 ###

      if [[ -f "${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.mp4" ]]
      then

            ### start timer ###

            TIME_START=$(date +%s)





            ### Change to the video directory  ( to avoid the x264_2pass.log issue ) ###

            PWD=$(pwd)
            cd ${DIRECTORY}/${SUBDIR}/

            ### create video_${FF_WIDTH}x${FF_HEIGHT}.vp8 ###
            echo -e "${yellow}# tanscode mp4 to webm ${NC}"
            echo -e "${yellow}# pass 1 ${NC}"

            COMMAND="${FFMPEG_WEBM} -threads $THREADS -i  ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.mp4  $FF_PRESET1  -b ${FF_VBITRATE}k -passlogfile /tmp/${OUTPUT}.log -pass 1  \
            -s ${FF_WIDTH}x${FF_HEIGHT}   -r $FF_FPS -ss $SS -y -f $FF_FORMAT \
            -y  /dev/null "
            [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"

            eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}

            echo -e "${yellow}# pass 2 ${NC}"

            COMMAND="${FFMPEG_WEBM} -threads $THREADS -i  ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.mp4   $FF_PRESET2 -passlogfile /tmp/${OUTPUT}.log -pass 2 \
            -s ${FF_WIDTH}x${FF_HEIGHT} -r $FF_FPS -ss $SS  -y -f $FF_FORMAT \
            -y ${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} "

            [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
            eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}





            ### clean up ###

            echo -e "${yellow}# clean up${NC}"

            [[ -f  ${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT} ]] && rm  ${DIRECTORY}/${SUBDIR}/video_tmp.${FF_FORMAT}
            [[ -f  ${DIRECTORY}/${SUBDIR}/test.jpg ]] && rm  ${DIRECTORY}/${SUBDIR}/test.jpg
            [[ -f  ${DIRECTORY}/${SUBDIR}/test.mp3 ]] && rm  ${DIRECTORY}/${SUBDIR}/test.mp3
            [[ ! -z $SUB_FILE && -f "$FIFO" ]] && rm  "$FIFO"





              ### check the file ###

              [[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
              FILE_INFOS=""
              get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"

              if [[  $? == 0 ]]
              then
              echo -e "${GREEN}${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
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

        ### Go back to the pwd ( to avoid the x264_2pass.log issue ) ###

        cd $PWD

        else

        echo -e ${RED}File missing:"${DIRECTORY}/${SUBDIR}/${OUTPUT}${PLAY_SIZE}.mp4${NC}"

        fi

	
   