
        ### 1.77 ###
		 
	      if [[ $RATIO_I -ge 160 ]] && [[ $RATIO_I -lt 199 ]]
	      then
	      
            DETECTED_FORMAT="16:9"
            [[ $DEBUG -gt 0 ]] && 	echo -e "DETECTED_FORMAT=${green}$DETECTED_FORMAT${NC}"
            save_info "DETECTED_FORMAT=$DETECTED_FORMAT"


			
            # Cropping H: no
            [[ $DEBUG -gt 1 ]] && echo -e "${cyan}# Cropping W: no${NC}"
            CROPLEFT=0
            CROPRIGHT=0


            # Cropping H: no
            [[ $DEBUG -gt 1 ]] && echo -e "${cyan}# Cropping H: no${NC}"
            CROPTOP=0
            CROPBOTTOM=0

			
            # Padding: no
            [[ $DEBUG -gt 1 ]] && echo -e "${cyan}# Padding: no${NC}"
		
            # get new sizes
            calc_new_sizes

      fi