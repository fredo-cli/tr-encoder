#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="avi"
PLAY_SIZE=""

FF_WIDTH=400
FF_HEIGHT=226 ### we add 2*6+8 just before the video encoding
FF_HEIGHT_3D=240 ### 16/9 + 6+8-> 3D ratio

FF_FPS=24

FF_VBITRATE=1200

FF_AB=128
FF_AC=2
FF_AR=44100

THREADS=1




if [[ $EVALUTE == 1 && $EVALUATION == 0 ]]
then

### evalute only once or encode

evaluation_ini

### check the evolution of the encoding

elif [[ $EVALUTE == 1 && $EVALUATION -gt 0 ]]
then

evaluation_check

else

### encode the video


          ### display the format ###

          echo -e "\\n${BLUE}$(box "Format: 3D $PREFIX-$FF_FORMAT")${NC}"


          ### Start timer ###

          TIME_START=$(date +%s)


          ### Create the logo or logos ###

            #add_logo


          ### Check the sub ###

            #check_sub


          ### Calculate the padding for ffmpeg ###

          calculate_padding


          ### create the video




          ### change the padding values ###

          echo -e "${yellow}# Adding 6px to PADTOP and 8px to PADBOTTOM{NC}"
          PADTOP=$(echo "$PADTOP + 6"|bc)
          PADBOTTOM=$(echo "$PADBOTTOM + 8"|bc)



          ### Extract all the images from the input video ###

          echo -e "${yellow}# Extract all the images from the input video${NC}"
          COMMAND="${FFMPEG_WEBM} -threads $THREADS  -i  ${INPUT} -an -vf 'crop=$(echo "${WIDTH}-${CROPLEFT}"|bc):`echo "${HEIGHT}-${CROPTOP}"|bc`:${CROPRIGHT}:${CROPBOTTOM},scale=${FF_WIDTH}:${FF_HEIGHT_BP},pad=${FF_WIDTH}:${FF_HEIGHT_3D}:0:${PADBOTTOM}'  ${DIRECTORY}/${SUBDIR}/image-%d.png"
          [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
          eval "#$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  fatal_error



          ### Check the number of images  ###

          echo -e "${yellow}# Check the number of images ${NC}"
          IMAGE_NB=$(find ${DIRECTORY}/${SUBDIR}/ -name "image-*.png" |wc -l)
          echo -e "${green}# IMAGE_NB=${IMAGE_NB}${NC}"
          MONTAGE_NB=$(echo "$IMAGE_NB/2" |bc)
          echo -e "${green}# MONTAGE_NB=${MONTAGE_NB}${NC}"



          ### Create montage with left and right images  and change the colorspace###

          echo -e "${yellow}# Create montage with left and right images${NC}"
          A=1
          while [ $A -lt $MONTAGE_NB ]
          do

            LEFT=$(echo "($A*2)-1" |bc)
            RIGHT=$(echo "$A*2" |bc)

            ###  Create montage with left and right images
            COMMAND="montage $COLOR  ${DIRECTORY}/${SUBDIR}/image-$LEFT.png  ${DIRECTORY}/${SUBDIR}/image-$RIGHT.png -geometry 400x240+0+0 ${DIRECTORY}/${SUBDIR}/montage-${A}.jpg"
            [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
            eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  fatal_error



            ### Change the colorspace
            COMMAND="convert -alpha on -depth 8 -gamma 0.454545  -recolor '3.2404542 -1.5371385 -0.4985314 -0.9692660  1.8760108  0.0415560  0.0556434 -0.2040259  1.0572252' -gamma 2 -type truecolor ${DIRECTORY}/${SUBDIR}/montage-${A}.jpg ${DIRECTORY}/${SUBDIR}/frame-${A}.jpg "
            [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
            eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  fatal_error

            let A++

          done


          ### Create a avi video from all the montage  files ###

          echo -e "${yellow}# Create a avi video from all the montage  files${NC}"
          COMMAND="${FFMPEG_WEBM} -y -threads $THREADS  -i ${DIRECTORY}/audio.mxf   -r 24 -i  ${DIRECTORY}/${SUBDIR}/frame-%d.jpg   -b 1200k -y -vcodec libx264  -acodec libmp3lame -ar 44100 -ac 2 -ab  128k -r 24  ${DIRECTORY}/${SUBDIR}/video.avi"
          [[ $DEBUG -gt 1 ]] && QUIET=""  || QUIET="  2>/dev/null"
          eval "$COMMAND $QUIET" && echo -e ${green}$COMMAND$QUIET${NC} ||  echo -e ${red}$COMMAND${NC}







          ### check the file
          [[ $DEBUG -gt 0 ]] && echo -e "${cyan}`box "Control output file"`${NC}"
          FILE_INFOS=""
          get_file_infos "${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT}"

          if [[  $? == 0 ]]
          then
          echo -e "${GREEN}#${DIRECTORY}/$SUBDIR/${OUTPUT}${PLAY_SIZE}.${FF_FORMAT} ${NC}"
          [[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >> "${DIRECTORY}/$SUBDIR/sample.up"

          ### stop timer

          TIME_END=$(date +%s)

          ### calculate duration

          let "ENCODING_DURATION=$TIME_END - $TIME_START"

          ### quit timer infos to log files (for evaluation)

          logTimer

          else
          echo -e "${RED}$FILE_INFOS${NC}"
          fi







fi




