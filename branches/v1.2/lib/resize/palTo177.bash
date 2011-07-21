#!/usr/local/bin/bash

#########################
function pal-dar133(){
#########################

				### try to get a preset                                                                    
				CROP_PRESET=`grep  "^1.25|${WIDTH}x${HEIGHT}|1.33|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/conf/CROPS `
				[[ $DEBUG -gt 1 ]] && echo $CROP_PRESET                                                                                        
																									 
                                                                                                                               
                                                                                                                                        
                                                                                                                                        
				### Crop Width
                                                                                                                                                                                                                                
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`                                         
				if [[ ! -z $CROP_PRESET_WIDTH ]] 
				then
				
            ### Change to the preset values

            eval "$CROP_PRESET_WIDTH"

            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Change to the preset values ${NC}"
			
				else
				
              #### keep the cropping detected values for the width (if not to big)

              if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
              then

                  [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Cropdetect ${NC}"

              ### reset to 0 CROPLEFT and CROPRIGHT

              else

                  CROPLEFT=0
                  CROPRIGHT=0
                  [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Reset to null ${NC}"

              fi
				

				
				fi
				
				
				### for the Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
            ###  Change to the preset values

            eval "$CROP_PRESET_HEIGHT"
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Change to the preset values ${NC}"
				
				else
				
            ### Change to the standart values
            CUT=`echo " $HEIGHT / 8 "|bc `
            CUT=$(floor2 $CUT)
            CROPTOP=$CUT
            CROPBOTTOM=$CUT
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Change to the standart values ${NC}"
				
				fi
				
				
				
				### DISTORTION
				
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	
				
            ### Change to the preset values
            DISTORTION=$DISTORTION_PRESET
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Distortion: Change to the preset values ($DISTORTION) ${NC}"
				
				else
				
            ### Change to the standart value

            DISTORTION="$PAR" # PAR 16:15 = 1.0666666
            [[ $PAR == 0 ]] && DISTORTION="1"
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Distortion: Change to the standart value ($DISTORTION) ${NC}"
				
				fi
				
				
	      ### Padding: no
        [[ $DEBUG -gt 1 ]] && echo -e "${yelow}# Padding: No ${NC}"
		 
        ### Get the new sizes
        calc_new_sizes
	
	}

#########################
function pal-dar177(){
#########################
		 
        CROP_PRESET=`grep  "^1.25|${WIDTH}x${HEIGHT}|1.77|$CROPWIDTH_AV|$CROPHEIGHT_AV|.*" ${APP_DIR}/conf/CROPS `
        [[ $DEBUG -gt 1 ]] && echo $CROP_PRESET
				
	 
				### Crop Width
				
				CROP_PRESET_WIDTH=`echo $CROP_PRESET |awk -F "|" '{ print $7 }'`
				if [[ ! -z $CROP_PRESET_WIDTH ]]
				then
				
            ### Change to the preset values
            eval "$CROP_PRESET_WIDTH"

            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Change to the preset values ${NC}"

				else
				
            ### keep the cropping detected values for the width (if not to big)

            if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 * 2 / 2" |bc` ]]
            then

                  [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Cropdetect values ${NC}"


              ### reset to 0 CROPLEFT and CROPRIGHT

              else

                  CROPLEFT=0
                  CROPRIGHT=0
                  [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping W: Reset to null ${NC}"

              fi
				
				
				
				fi
				
				
				### Crop Height
				
				CROP_PRESET_HEIGHT=`echo $CROP_PRESET |awk -F "|" '{ print $6 }'`
				if [[ ! -z $CROP_PRESET_HEIGHT ]]
				then
				
            ### Change to the preset values

            eval "$CROP_PRESET_HEIGHT"
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Change to the preset values (CROPTOP=$CROPTOP CROPBOTTOM=$CROPBOTTOM ) ${NC}"
				
				else
				
            ### Change to the standart values
            CUT=`echo " $HEIGHT / 8 "|bc `
            CUT=$(floor2 $CUT)
            CROPTOP=$CUT
            CROPBOTTOM=$CUT
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Change to the standart values (CROPTOP=$CROPTOP CROPBOTTOM=$CROPBOTTOM ) ${NC}"
				
				fi
				
				
				
				### Distortion
			
				DISTORTION_PRESET=`echo $CROP_PRESET |awk -F "|" '{ print $8 }'`
				if [[ ! -z $DISTORTION_PRESET ]]
				then	

            ### Change to the preset values
            DISTORTION=$DISTORTION_PRESET
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Distortion: Change to the preset values ($DISTORTION) ${NC}"
				
				else
				
            # stantart
            DISTORTION="$PAR "
            [[ $PAR == 0 ]] && DISTORTION="1"
            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Distortion: Change to the standart values ($DISTORTION) ${NC}"
				
				 fi
		 
	 
        ### No  padding
	      [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Padding: No${NC}"
		 
       ### Get the new sizes
       calc_new_sizes
	 
	 }
	      
	      
	      
	      
	      
	      
	      ### RATIO 1.25 DAR 1.25

        if [[ $RATIO_I  -ge 122 && $RATIO_I -le 128 ]] && [[ $DAR == 0 || $DAR  == 1.25 ]]
	      then
		 
            DETECTED_FORMAT="1.25 - pal reencoded !"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${red}$DETECTED_FORMAT${NC}"

            ### get a new cropdetection
            cropdetection 500

                ### small black border

                if [[  $CROPTOP -lt `echo $HEIGHT / 16 |bc`    &&  $CROPBOTTOM  -lt `echo $HEIGHT / 16 |bc` ]]
                then

                    echo -e "\\nSmall black border less than `echo $HEIGHT / 16 |bc`"
                    echo    "1/  pal DAR 1.77"
                    echo    "2/  pal DAR 1.33 (if the  crop detection didn't work)"



                        ### Remove the very small black border on the top and bottom (optional)

                        if [[ $CROPHEIGHT_AV  -lt `echo "$HEIGHT * 0.3 * 2 / 2" |bc` ]]
                        then

                            ### keep cropdetect values

                            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Cropdetect values ${NC}"

                        else

                            ### Reset to null

                            CROPTOP=0
                            CROPBOTTOM=0
                            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Reset to null ${NC}"

                        fi



                        ### remove the very small black border on the left and right (optional)

                        if [[ $CROPWIDTH_AV  -lt `echo "$WIDTH * 0.03 / 1" |bc` ]]
                        then

                            ### keep cropdetect values

                            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Cropdetect values ${NC}"

                        else

                            ### Reset to null

                            CROPLEFT=0
                            CROPRIGHT=0
                            [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Cropping H: Reset to null ${NC}"

                        fi


                    ### distortion 1.422

                    DISTORTION="1.422 "
                    [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Distortion: $DISTORTION${NC}"

                    ### Padding: no

                    [[ $DEBUG -gt 1 ]] && echo -e "${yellow}# Padding: No${NC}"

                    ### Get the new sizes
                    calc_new_sizes




                ### Medium black boder ###

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








                ### Large black border (cinemascope = 136 | 16/9=  |pal DAR 1.77 = 80 -> dont cut just strech the image)
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




	      ### RATIO 1.25 and DAR 1.33

	      if [[ $RATIO_I -eq 125 || $RATIO_I -eq 122 ]] && [[ $DAR_I  -gt 130 &&  $DAR_I -lt 136  ]]
	      then

            # get a  cropdetection
            cropdetection 500

            DETECTED_FORMAT="PAL DAR 1.33"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${YELLOW}$DETECTED_FORMAT${NC}"

            pal-dar133

	      fi




	      ### ratio 1.25 and DAR 1.77
		 
	      if [[ $RATIO_I -eq 125 || $RATIO_I -eq 122 ]] && [[ $DAR == 1.77 ]]
	      then

            # get a  cropdetection
            cropdetection 200

            DETECTED_FORMAT="PAL DAR 1.77"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${YELLOW}$DETECTED_FORMAT${NC}"

            pal-dar177
  
	      fi




	      # 1.25 DAR 2.21 !!!
		 
	      if [[ $RATIO_I -eq 125 && $DAR == 2.21 ]]
	      then

            DETECTED_FORMAT="PAL DAR 2.21"
            [[ $DEBUG -gt 0 ]] && echo -e "DETECTED_FORMAT=${YELLOW}$DETECTED_FORMAT${NC}"
		 

           # padding
		 
            PAD=`echo "scale=3;( ( $WIDTH / 1.777)  - ( $WIDTH / 2.21)  / 2)"|bc`
            PAD=`round2 $PAD`
            PADTOP=$PAD
            PADBOTTOM=$PAD
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Padding: PADTOP=$PADTOP PADBOTTOM=$PADBOTTOM ${NC}"


            # Cropping: no

            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Cropping: No${NC}"
            CROPLEFT=0
            CROPRIGHT=0
            CROPTOP=0
            CROPBOTTOM=0

            # distortion 1.768
            DISTORTION="1.768 "
            [[ $DEBUG -gt 1 ]] && echo -e "${green}# Distortion: $DISTORTION${NC}"



            # get new sizes
            calc_new_sizes


				 
	      fi      	 
