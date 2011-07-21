				
	      ### 2.35 ###
		 
	      if [[ $RATIO_I -ge  199  ]] && [[ $RATIO_I -le 255 ]]
	      then

            DETECTED_FORMAT="2.35"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${green}$DETECTED_FORMAT${NC}"

            ### Cropping: no

            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Cropping: No${NC}"
            CROPLEFT=0
            CROPRIGHT=0
            CROPTOP=0
            CROPBOTTOM=0

            ### Padding

            PAD=`echo "scale=3;(($WIDTH / 1.777) - $HEIGHT) / 2"|bc`
            PAD=`round2 $PAD`
            PADTOP=$PAD
            PADBOTTOM=$PAD
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Padding: PADTOP=$PADTOP PADBOTTOM=$PADBOTTOM ${NC}"



            ### Get the new sizes

            calc_new_sizes

	      fi