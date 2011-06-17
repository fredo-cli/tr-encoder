#!/usr/bin/bash	

	   # get the time 
		
		FF_FPS=`echo "scale=2 ; 11 / ${DURATION_S} "|bc`
		FF_FPS="0$FF_FPS"
		FF_SS=`echo "$DURATION_S / 11"|bc`
		
		#echo $FF_FPS  ${DURATION_S} $FF_SS
				
		# create a folder montage
		
		[[ ! -d "${DIRECTORY}/$SUBDIR/montage" ]] && mkdir "${DIRECTORY}/$SUBDIR/montage"
		
		# extract the pictures
		COMMAND="${FFMPEG} $DEINTERLACE -i ${INPUT} -ss $FF_SS -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r $FF_FPS  $VHOOK -an -ss $(echo "$SS + 2 "|bc)  -vframes 10 -y ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_%2d.jpg ;\\n"
		COMMAND="${COMMAND}rm -f  ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_01.jpg ;\\n"
		COMMAND="${COMMAND}montage  ${DIRECTORY}/$SUBDIR/montage/${OUTPUT}_[0-9]*.jpg -geometry 160x90+1+1 ${DIRECTORY}/$SUBDIR/montage.png ;\\n"
		
			      
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
		get_file_infos "${DIRECTORY}/$SUBDIR/montage.png"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/montage.png${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >>  "${DIRECTORY}/$SUBDIR/montage.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi