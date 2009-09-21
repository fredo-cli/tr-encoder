#!/usr/local/bin/bash	
	 
	      # 1.50 ntsc DAR 1.77
		 
	      if [[ $RATIO_I == 150  &&   ( $DAR_I  -lt 170  ||  $DAR_I -gt 185 )]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc DAR 1.77"
		 echo -e "${green}# Format: $DETECTED_FORMAT${NC}"

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="`echo "scale=3; $ID_VIDEO_ASPECT  / $RATIO "|bc` "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi	

	      # 1.50 ntsc DAR 1.33
		 
	      if [[ $RATIO_I == 150  &&  $DAR == 1.33 ]]
	      then 

		  DETECTED_FORMAT="1.50 - ntsc DAR 1.33"
		  echo -e "${green}# Format: $DETECTED_FORMAT${NC}"


		  CROPLEFT=0              
		  CROPRIGHT=0
		  FF_CROP_WIDTH=""
		  CROPTOP=66
		  CROPBOTTOM=66
		  FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "

		  # Cropping: yes
		 
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: FF_CROP_HEIGHT${NC}"
		 
		  # distortion 0.888
		  DISTORTION="`echo "scale=3; $ID_VIDEO_ASPECT  / $RATIO "|bc` "

		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi