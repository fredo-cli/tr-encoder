		       
		       
	      ### 1.77 ###
		 
	      if [[ $RATIO_I -ge 160 && $RATIO_I -lt 199 ]]
	      then
	      
		 	DETECTED_FORMAT="16/9"
      [[ $DEBUG -gt 0 ]] && 	echo -e "${green}# Format:$DETECTED_FORMAT ${NC}"


		 
				# cropping
		 
		 
				# normal (no detection)
				if [[ $CROPDETECTION  == 1 ]]
				then
				
				# Cropping H: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
				CROPLEFT=0              
				CROPRIGHT=0
			 	FF_CROP_WIDTH=""
				
				# Cropping H: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: no${NC}"
				CROPTOP=0
				CROPBOTTOM=0
				FF_CROP_HEIGHT=""
				
				else 
				
						# make a crop detection 
						cropdetection $CROP_FRAMES_S
						
						# detection H (level detection 2)

						if [[ $CROPDETECTION  -gt 1 && $CROPHEIGHT_AV  -lt `echo "$HEIGHT * 0.03 * 2 / 2" |bc` ]]
						then
						FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:$FF_CROP_HEIGHT${NC}"
						else
						CROPTOP=0
						CROPBOTTOM=0
						FF_CROP_HEIGHT="" 
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: no${NC}"
						fi

		  
				
						# detection W (level detection 2 and 3)
						   
						if [[  $CROPDETECTION  -gt 2 && $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
						then
						FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W:$FF_CROP_WIDTH${NC}"
						else
						CROPLEFT=0
						CROPRIGHT=0
						FF_CROP_WIDTH="" 
						[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
						fi

							
			   fi

				
				
		# Padding: no
		[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		
		# get new sizes
		 calc_new_sizes

		fi	