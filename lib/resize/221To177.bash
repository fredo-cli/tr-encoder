				
	      # 2.35
		 
	      if [[ $RATIO_I -ge  199 && $RATIO_I -le 255 ]]
	      then
		 DETECTED_FORMAT="2.35"
		 [[ $DEBUG -gt 0 ]] && echo -e "${green}# Format: $DETECTED_FORMAT${NC}"

	      
	      # padding
		 
	      PAD=`echo "scale=3;(($WIDTH / 1.777) - $HEIGHT) / 2"|bc`
	      PAD=`round2 $PAD`
	      PADTOP=$PAD
	      PADBOTTOM=$PAD
	      FF_PAD="-padtop $PADTOP -padbottom $PADBOTTOM "
	     [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: $FF_PAD${NC}"
		  

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""

	      # get new sizes
	      calc_new_sizes
	      fi