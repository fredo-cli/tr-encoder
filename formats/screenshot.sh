#!/usr/bin/bash	
	COMMAND="${FFMPEG} $DEINTERLACE -i ${INPUT} -sameq $FF_CROP_WIDTH $FF_CROP_HEIGHT $FF_PAD -s ${FF_WIDTH}x${FF_HEIGHT} -r 24   $VHOOK -an -ss $(echo "$SS + 10 "|bc)  -vframes 1 -y ${DIRECTORY}/${SUBDIR}/screenshot.jpg ;\\n"
	     			      
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
		get_file_infos "${DIRECTORY}/$SUBDIR/screenshot.jpg"

		if [[  $? == 1 ]]
		then 
		echo -e "${GREEN}${DIRECTORY}/$SUBDIR/screenshot.jpg${NC}"
		[[ $DEBUG -gt 1 ]] && echo -e "$FILE_INFOS" ||echo -e "$FILE_INFOS" >  "${DIRECTORY}/$SUBDIR/screenshot.up"
		else
		echo -e "${RED}$FILE_INFOS${NC}"		
		fi