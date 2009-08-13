#!/usr/local/bin/bash
	   
	      pal-dar133(){
	
				### try to get a preset   
                                                                      
				CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.33|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
				[[ $DEBUG -gt 1 ]] && echo $CROP_PRESET                                                                                        
																									 
                                                                                                                               
                                                                                                                                        
                                                                                                                                        
				### for the Width                                                                                                  
                                                                                                                                        
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`                                         
				if [[ ! -z $CROP_PRESET_WIDTH ]] 
				then
				
				### change to the preset values

				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"	
			
				else
				
					#### keep the cropping detected values for the width (if not to big)

					if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
					then

					FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "

					else

					FF_CROP_WIDTH="-cropleft 0 -cropright 0 "	
				
					fi
				
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				### for the Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
				###  change to the preset values

				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc ` 
				CUT=$(floor2 $CUT)
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# DISTORTION
				
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
				# stantart    
				
				DISTORTION="$PAR" # PAR 16:15 = 1.0666666
				[[ $PAR == 0 ]] && DISTORTION="1"
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}\\t(standart)"				
				
				fi
				
				
	      # no padding
		 [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes
	
	
	
	}
	
pal-dar177(){
	 
		 
		CROP_PRESET=`grep  "^${TRY}1.25|${WIDTH}x${HEIGHT}|1.77|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/config/CROPS `
		[[ $DEBUG -gt 1 ]] && echo $CROP_PRESET
				
				
		 
				# Width
				
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`
				if [[ ! -z $CROP_PRESET_WIDTH ]]
				then
				
				# change to the preset values
				eval "$CROP_PRESET_WIDTH"

				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(preset)"				
				else
				
				# keep the cropping detected values for the width (if not to big)
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				else
				FF_CROP_WIDTH="-cropleft 0 -cropright 0 "				
				fi
				
				
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: $FF_CROP_WIDTH ${NC}\\t(crop detection)"
				
				fi
				
				
				# Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
				# change to the preset values
				
				eval "$CROP_PRESET_HEIGHT"
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT ${NC}\\t(preset)"
				
				else
				
				# change to the standart values
				CUT=`echo " $HEIGHT / 8 "|bc `
				CUT=$(floor2 $CUT) 
				CROPTOP=$CUT
				CROPBOTTOM=$CUT
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H: $FF_CROP_HEIGHT${NC}\\t(standart)"
				
				fi
				
				
				
				# Distortion
			
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
				# change to the preset values
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION ${NC}\\t(preset)"
				
				else
				
				# stantart    

				DISTORTION="$PAR " 
				[[ $PAR == 0 ]] && DISTORTION="1"
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}\\t(standart)"				
				
				 fi
		 
	 
		 #no  padding
	      [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 # get new sizes
		 calc_new_sizes

	 
	 }
	      
	      
	      
	      
	      
	      
	      ### pal DAR 1.25
		 

if [[ ( $RATIO_I  -ge 122 && $RATIO_I -le 128 ) && ( $DAR == 0 || $DAR  == 1.25 ) ]]
	      then
		 
		 DETECTED_FORMAT="1.25 - pal reencoded !"
		 echo -e "${pink}# Format: $DETECTED_FORMAT ${NC}"
	      
	      # get a new cropdetection 
	      cropdetection $CROP_FRAMES_L


		 
		 
				# small black border 
				
				if [[  $CROPTOP -lt `echo $HEIGHT / 16 |bc`    &&  $CROPBOTTOM  -lt `echo $HEIGHT / 16 |bc` ]]
				then
				
				echo -e "\\nSmall black border less than `echo $HEIGHT / 16 |bc`" 
				echo    "1/  pal DAR 1.77" 
				echo    "2/  pal DAR 1.33 (if the  crop detection didn't work)"
				

				
				# remove very small black border on the top and bottom (optional)
				
				if [[ $CROPHEIGHT_AV  -lt `echo "$HEIGHT * 0.3 * 2 / 2" |bc` ]]
				then
				FF_CROP_HEIGHT="-croptop $CROPTOP -cropbottom $CROPBOTTOM "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:\\t$FF_CROP_HEIGHT${NC}"
				else
				CROPTOP=0
				CROPBOTTOM=0
				FF_CROP_HEIGHT="" 
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping H:\\t no${NC}"
				fi
				
				# remove very small black border on the left and right (optional)
							   
				if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 / 1" |bc` ]]
				then
				FF_CROP_WIDTH="-cropleft $CROPLEFT -cropright $CROPRIGHT "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W:\\t$FF_CROP_WIDTH${NC}"
				else
				CROPLEFT=0
				CROPRIGHT=0
				FF_CROP_WIDTH="" 
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Cropping W: no${NC}"
				fi
				
				
				# distortion 
				DISTORTION="1.422 "
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
		 
				# Padding: no
				[[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
				
				# get new sizes
				calc_new_sizes
				
				
				
				
				# medium black boder 

				
				elif [[ $CROPHEIGHT_AV -ge `echo "$HEIGHT * 0.111 / 1" |bc` && $CROPHEIGHT_AV  -le `echo "$HEIGHT * 0.155 / 1"|bc`   ]]
				then
				
				echo -e "\\nMedium black border less than `echo "$HEIGHT * 0.155 / 1"|bc` AND more than `echo "$HEIGHT * 0.111 / 1"|bc` "
				echo    "1/ pal DAR 1.33 with a image 1.77 "
				echo    "2/ pal DAR 1.77 with a image 2.35 "
				
				
				CHOICE=0
				read -t 5 CHOICE
				echo $CHOICE
				
				case $CHOICE in
				1)pal-dar133;;
				2)pal-dar177;;
				*)pal-dar133;;
				esac
				

				
				
				
				
				
				
				# large black border cinemascope = 136 | 16/9=  |pal DAR 1.77 = 80 -> dont cut just strech the image
				else
				
				echo -e "\\nLarge Black border more than `echo "$HEIGHT * 0.155 / 1"|bc` "
				echo    "1/  pal DAR 1.33"
				echo    "2/  pal DAR 1.77"				
				
				CHOICE=0
				read -t 5 CHOICE
				echo $CHOICE
				
				case $CHOICE in
				1)pal-dar133;;
				2)pal-dar177;;
				*)pal-dar133;;
				esac
		
				
				fi
				
				
				


	      fi


	      # PAL DAR 1.33
	  

	      if [[ ($RATIO_I -eq 125 || $RATIO_I -eq 122 ) && ( $DAR_I  -lt 136  ||  $DAR_I -gt 130 ) ]]
	      then
	      # get a  cropdetection 
	      cropdetection $CROP_FRAMES_L
		 
		 DETECTED_FORMAT="PAL DAR 1.33"
		 echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"
		
		 pal-dar133
	      fi


	      # 1.25 DAR 1.77
		 
	      if [[ ($RATIO_I -eq 125 || $RATIO_I -eq 122 ) && $DAR == 1.77 ]]
	      then
	 
		 # get a  cropdetection
	      cropdetection $CROP_FRAMES_S
		 
		 DETECTED_FORMAT="PAL DAR 1.77"
		 echo -e "${pink}# Format: $DETECTED_FORMAT${NC}"

		 pal-dar177	      
	      fi
		 
	      # 1.25 DAR 2.21 !!!
		 
	      if [[ $RATIO_I -eq 125 && $DAR == 2.21 ]]
	      then

		 DETECTED_FORMAT="PAL DAR 2.21"
		 echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 

	      # padding
		 
		 PAD=`echo "scale=3;( ( $WIDTH / 1.777)  - ( $WIDTH / 2.21)  / 2)"|bc`
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
				
		  # distortion 1.768
		  DISTORTION="1.768 "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    

		  
		  # get new sizes
		  calc_new_sizes				 
		
		 DETECTED_FORMAT=""
				 
	      fi      	 
		 
	      # 1.50 ntsc reencoded !
		 
	      if [[ $RATIO_I == 150  && ( $DAR == 0 || $DAR  == 1.50 ) ]]
	      then 
		 DETECTED_FORMAT="1.50 - ntsc reencoded !"
		 echo -e "${red}# Format: $DETECTED_FORMAT${NC}"
		 # get a new cropdetection 
	      cropdetection $CROP_FRAMES_L
		 

	      # Cropping: no
		 
	      [[ $DEBUG -gt 0 ]] &&echo -e "${cyan}# Cropping: no${NC}"		 
	      CROPLEFT=0              
	      CROPRIGHT=0
	      FF_CROP_WIDTH=""
	      CROPTOP=0
	      CROPBOTTOM=0
	      FF_CROP_HEIGHT=""
		 
		  # distortion 1.768
		  DISTORTION="`echo "scale=3; 1.777 / $RATIO "|bc` "
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Distortion: $DISTORTION${NC}"				
    
		  # Padding: no
		  [[ $DEBUG -gt 0 ]] && echo -e "${cyan}# Padding: no${NC}"
		 
		 
		 # get new sizes
		 calc_new_sizes

	      fi	