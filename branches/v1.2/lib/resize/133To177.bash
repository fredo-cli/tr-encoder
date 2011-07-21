		 
	    ### 1.33 ###
 
      if [[ ( $RATIO_I  -gt 127 && $RATIO_I -lt 160  && $RATIO_I != 150 ) && ($DAR == 0 || $DAR == 1.33 ) ]]
      then

          DETECTED_FORMAT="1.33"
          [[ $DEBUG -gt 0 ]] && echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"

          #### Cut the top and the bottom

          CUT=`echo "scale=3;( $HEIGHT - ( $WIDTH / 1.777 )) / 2"|bc `
          CUT=$(floor2 $CUT)
          CROPTOP=$CUT
          CROPBOTTOM=$CUT
          [[ $DEBUG -gt 1 ]] && echo -e "${green}# Cutting: CROPTOP=$CROPTOP CROPBOTTOM=$CROPBOTTOM ${NC}"

          ### Get the new sizes

          calc_new_sizes

      fi


 
		 ### 1.33 DAR 16/9 !!! ###
		 
		 if [[ ( $RATIO_I  -ge 127 && $RATIO_I -lt 160 && $RATIO_I != 150 ) && ( $DAR  == 1.77 ) ]]
		 then

        DETECTED_FORMAT="4/3 DAR 16/9"
        NOTICE="${NOTICE}This format($DETECTED_FORMAT) is not a video standart, please follow your recommendation."
        [[ $DEBUG -gt 0 ]] && echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 
        ### Cropping: no

        [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"
        CROPLEFT=0
        CROPRIGHT=0
        CROPTOP=0
        CROPBOTTOM=0

		 				
        ### Distortion

        DISTORTION="1.333 "
        [[ $DEBUG -gt 0 ]] && echo -e "${green}# Distortion: $DISTORTION${NC}"

        ### Padding: no

        [[ $DEBUG -gt 0 ]] && echo -e "${green}# Padding: No${NC}"

        ### Get the new sizes

        calc_new_sizes
	      
	      fi