#!/usr/local/bin/bash	
	 
	      ### 1.50 ntsc DAR 1.77 ###
		 
	      if [[ $RATIO_I == 150  &&   ( $DAR_I  -gt 170  ||  $DAR_I -lt 185 )]]
	      then

            DETECTED_FORMAT="1.50 - ntsc DAR 1.77"
            [[ $DEBUG -gt 0 ]] && echo -e "${green}# Format: $DETECTED_FORMAT ${NC}"

            ### Cropping: No

            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Cropping: No ${NC}"
            CROPLEFT=0
            CROPRIGHT=0
            CROPTOP=0
            CROPBOTTOM=0


            ### Padding: no

            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Padding: no${NC}"

            ### Distortion 1.768

            DISTORTION=$PAR
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Distortion: $DISTORTION ${NC}"


            ### Get the new sizes

            calc_new_sizes

	      fi	



	      # 1.50 ntsc DAR 1.33
		 
	      if [[ $RATIO_I == 150  &&  $DAR == 1.33 ]]
	      then 

            DETECTED_FORMAT="1.50 - ntsc DAR 1.33"
            [[ $DEBUG -gt 0 ]] && echo -e "${green}# Format: $DETECTED_FORMAT${NC}"

            ### Cropping: yes

            CROPLEFT=0
            CROPRIGHT=0
            CROPTOP=66
            CROPBOTTOM=66
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Cropping: CROPTOP=$CROPTOP CROPBOTTOM=$CROPBOTTOM ${NC}"

            ### Padding: No

            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Padding: No ${NC}"

            ### distortion 0.888

            DISTORTION=$PAR
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Distortion: $DISTORTION${NC}"


            ### Get the new sizes

            calc_new_sizes

	      fi


        ### 1.50 ntsc reencoded ! ###

	      if [[ $RATIO_I == 150  && ( $DAR == 0 || $DAR  == 1.50 ) ]]
	      then

            DETECTED_FORMAT="1.50 - ntsc reencoded !"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${red}$DETECTED_FORMAT${NC}"

            # get a new cropdetection
            cropdetection 500

            # Cropping: No

            [[ $DEBUG -gt 1 ]] &&echo -e "${green}# Cropping: No${NC}"
            CROPLEFT=0
            CROPRIGHT=0
            CROPTOP=0
            CROPBOTTOM=0


            # distortion 1.768
            DISTORTION="`echo "scale=3; 1.777 / $RATIO "|bc` "
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Distortion: $DISTORTION${NC}"

            # Padding: no
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Padding: no${NC}"


            # get new sizes
            calc_new_sizes

	      fi