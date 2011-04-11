#!/usr/local/bin/bash


SYSTEM=$(uname)

APP_NAME=`basename "$0"`
CONF_NAME=."$APP_NAME"rc
#APP_DIR=`dirname "$0"`



[[ SYSTEM == "Linux" ]] && APP_DIR=$(readlink -f $0 | xargs dirname) || APP_DIR=$(readlink -n $0 | xargs dirname)

SUB_DIRECTORY="$APP_DIR/fonts"


### Import configuration file, possibly overriding defaults.

[ -r ~/"$CONF_NAME" ] && . ~/"$CONF_NAME"

### Include all functions

. "$APP_DIR/lib/MAIN"

DEBUG=0
DISPLAY=0
OVERWRITE=0
CLEAN=0
CROPDETECTION=1
TRY=""
LOGOS_ADD=""
FF_SIZE=""
SS=0
SUB=""
EXTENTION=".org"
EVALUTE=0
EVALUATION=0
NB_FILE_TO_CREATE=0
NB_FILE_CREATED=0



###  local.ini ###
### in  Mhz
CPUS_AVERAGE=12


### defaut.ini ###

### minimum duration of the video 

MINIMUM_DURATION=8

### minimum general biterate accepted 

MINIMUM_BITERATE=500000

### minimum video biterate accepted

MINIMUM_VBITERATE=446000

### minimum Audio biterate accepted

MINIMUM_ABITERATE=64000


### qualite minimun de l'image

MINIMUM_BPF=0.06

### number of frames for the crop detection

CROP_FRAMES_S=250
CROP_FRAMES_L=500


MAXSIZE=480
FPS=12000/1001







		### Path to mp4box  ffmpeg 
		
		if [[ $SYSTEM == "FreeBSD" ]]
		then
		
		MP4BOX=mp4box
		FFMPEG="/usr/local/bin/ffmpip"
		FFMPEG_WEBM="/usr/local/bin/ffmpeg"
		VHOOK_PATH="/home/fred/ffmpip/lib/vhook/pip.so"
		
		elif  [[ $SYSTEM == "Linux" ]]
		then
		
		MP4BOX=MP4Box
		FFMPEG="/usr/bin/ffmpip"
    FFMPEG_WEBM="/usr/bin/ffmpeg-webm"

      # older version
      if [[ -f /home/fred/ffmpip/lib/vhook/pip.so ]]
      then
        VHOOK_PATH=/home/fred/ffmpip/lib/vhook/pip.so

      # newer version
      elif [[ -f /opt/pip/lib/vhook/pip.so ]]
      then

        VHOOK_PATH="/opt/pip/lib/vhook/pip.so"



      else

        echo -e "{RED}Can' find Vhookt{NC}"

      fi
    fi





		while getopts "f:T:l:o:e:c:s:S:b:DydYE" option
		do
		case "$option" in
		c)	CLEAN=1;;	
		d)	DEBUG=1;;	
		D)	DEBUG=2;;
		e)	EXTENTION="$OPTARG";;	
		E)	EVALUTE=1;;	
		f)	OUTPUT_FORMATS="$OPTARG";;	
		l)	LOGOS_ADD="$OPTARG";;
		o)	OPERATION="$OPTARG";;	
		#s)	FF_SIZE="$OPTARG";;
		s)	SS="$OPTARG";;
		S)	SUB="$OPTARG";;
		T)	TRY="${OPTARG}-";;	
		y)      OVERWRITE=1;;
		Y)      OVERWRITE=2;;
		[?])    usage
			exit 1;;
		esac
		done
		shift $(($OPTIND - 1))





		get_format() {
		
		DETECTED_FORMAT=""
		RATIO_I=`echo "($RATIO * 100) /1"|bc `
		DAR_I=$(echo "$DAR*100/1" |bc )
		
		[[ $DEBUG -gt 0 ]] && echo -e "\\n${cyan}$(box "Format detection")${NC}\\n"

		
		. "$APP_DIR/lib/resize/palTo177.bash"		
		. "$APP_DIR/lib/resize/ntscTo177.bash"			
		. "$APP_DIR/lib/resize/133To177.bash"	
		. "$APP_DIR/lib/resize/177To177.bash"	
		. "$APP_DIR/lib/resize/221To177.bash"	
		      
		}  
		
		
		



		encode(){

   		### check and evaluate the ouput size ###
   
   		check_ouput_size "$FF_SIZE"

	   
   		if [[ $PAD != 0 ]]
   		then
   
   		FF_HEIGHT=`echo "$FF_WIDTH / $RATIO"|bc`
   		FF_HEIGHT=`round2 $FF_HEIGHT `
   		PAD=`echo "scale=3;(($FF_WIDTH / 1.777 ) - ($FF_WIDTH / $RATIO )) / 2"|bc`
   		PAD=`round2 $PAD`
   		FF_PAD=" -padtop $PAD -padbottom $PAD "
   
   		fi   
	      
	      

	      
	      
	  	### transcode the video to differents formats 

			for OUTPUT_FORMAT in $(echo $OUTPUT_FORMATS)
			do
		  
			COMMAND=""
			
				if [[ -f $APP_DIR/formats/$OUTPUT_FORMAT.sh ]]
				then
				. "$APP_DIR/formats/$OUTPUT_FORMAT.sh"
				else
				
			  	case "$OUTPUT_FORMAT" in
				screenshot) . "$APP_DIR/formats/screenshot.sh" ;;
				montage) . "$APP_DIR/formats/montage.sh" ;;
				sample). "$APP_DIR/formats/sample-flv.sh" ;;
				esac
				
				fi
	
	
			done


			### output the evaluation (only once)

			if [[ $EVALUTE == 1 && $EVALUATION == 0 ]]
			then  
			
			### lock for evaluation (call only once)
			EVALUATION=1
	
			echo  EVALUATION=$EVALUATION
			save_info "EVALUATION=$EVALUATION"
	
			echo  NB_FILE_TO_CREATE=$NB_FILE_TO_CREATE
			save_info "NB_FILE_TO_CREATE=$NB_FILE_TO_CREATE"
	
	
			echo  TOTAL_TIME_EVALUATION=$TOTAL_TIME_EVALUATION
			save_info "TOTAL_TIME_EVALUATION=$TOTAL_TIME_EVALUATION"
	
			fi




		### Check evolution of the process

		if [[ $EVALUTE == 1 && $EVALUATION == 1 ]]
		then  
				### Working

				if [[  $NB_FILE_CREATED -lt $NB_FILE_TO_CREATE ]]
				then

				[[ -f ${DIRECTORY}/${SUBDIR}/timer.log ]] && TOTAL_TIME_REALISATION=$(cat ${DIRECTORY}/${SUBDIR}/timer.log |awk -F " " '{ n++;  S += $2  } END { print S } ')
				[[ -z $TOTAL_TIME_REALISATION ]] && TOTAL_TIME_REALISATION=0
				let "EVOLUTION_PERCENT=$TOTAL_TIME_REALISATION *100 / $TOTAL_TIME_EVALUATION"	

                ### if TOTAL_TIME_REALISATION gt TOTAL_TIME_EVALUATION --> 99%

				[[ $EVOLUTION_PERCENT -gt 99 ]] && EVOLUTION_PERCENT=99
				[[ $EVOLUTION_PERCENT -eq 0 ]] && EVOLUTION_PERCENT=1

				echo "{'statusID': 5 , 'filesToCreateNB': $NB_FILE_TO_CREATE , 'filesCreatedNB' : $NB_FILE_CREATED , 'evolutionPC' : $EVOLUTION_PERCENT ,'realisationTime' : $TOTAL_TIME_REALISATION , 'evaluationTime' : $TOTAL_TIME_EVALUATION}"




  
 


				### just finish

				elif [[  $NB_FILE_CREATED == $NB_FILE_TO_CREATE &&  $TOTAL_TIME_REALISATION == 0  ]]
				then
				
				
				echo "finish"
				echo  "NB_FILE_CREATED=$NB_FILE_CREATED"
				save_info "NB_FILE_CREATED=$NB_FILE_CREATED"
 

				### calulate te total time of realistion and remove the millisecondes

				### version time
				
				#TOTAL_TIME_REALISATION=$(cat ${DIRECTORY}/${SUBDIR}/timer.txt |awk -F : '{ n++; M += $2*60 ; S += $3  } END { print M+S/1 } ')
				
				#save_info "TOTAL_TIME_REALISATION=${TOTAL_TIME_REALISATION%\.*}"
				
				### new version
				
				TOTAL_TIME_REALISATION=$(cat ${DIRECTORY}/${SUBDIR}/timer.log |awk -F " " '{ n++;  S += $2  } END { print S } ')
				save_info "TOTAL_TIME_REALISATION=${TOTAL_TIME_REALISATION%}"




				### completly done

				else
 
				echo   "done"
				echo    "$NB_FILE_CREATED / $NB_FILE_TO_CREATE"
				echo 100

				fi

	       fi




		### create info.xml 

		echo -e "\\n<TR-ENCODER>\\n"$(sed  -e  s/^#.*// -e /^$/d  "${DIRECTORY}/${SUBDIR}/info.txt" | awk -F "=" '{print "<"$1">"$2"</"$1">\\n" }'|tr -d "\"")"</TR-ENCODER>" > "${DIRECTORY}/${SUBDIR}/info.xml"
 
    	}
    	
    	
    	
    	
    	

		execute(){
	    INPUT=$1
		    
	    DIRECTORY=`dirname "$INPUT"`
	      
	    SUBDIR=`basename "$INPUT"`
	    SUBDIR=${SUBDIR%%${EXTENTION}}
	      
	    OUTPUT=` basename $INPUT`
	    OUTPUT=${OUTPUT%%.???}
		 
		 
	    NOTICE=""
	    WARNING=""
	    ERROR=""
	      
	          
	    PAD=0
	    PADTOP=0
	    PADBOTTOM=0
	    FF_PAD=""


	    CROPDETECTION_2PASS=0
	      
	    FF_CROP_WIDTH=""
	    FF_CROP_HEIGHT=""
	    CROP=""
	    CROPTOP=0
	    CROPRIGHT=0
	    CROPBOTTOM=0
	    CROPLEFT=0
	    
	    DISTORTION="1"
		 
	    ### create the dir
	    [[ ! -d  "${DIRECTORY}/${SUBDIR}" ]] &&   mkdir  "${DIRECTORY}/${SUBDIR}"
	      
	    ### clean  info if overwrite  = Y

	    [[ $OVERWRITE == 2 && -f ${DIRECTORY}/${OUTPUT}/info.txt ]] && rm ${DIRECTORY}/${OUTPUT}/info.txt 

		 
		 
		case "$OPERATION" in

		compatible) check_comp
		stop
		;;

		getps)    
		PS=$(ls "${DIRECTORY}/${OUTPUT}" |grep ps |tail -1)
		echo ${PS#ps}
		stop
		;;

		general)    
		get_general_infos
		stop
		;;

		video)	  
		get_video_infos 
		stop
		;;

		audio)
		get_audio_infos 
		stop
		;;	
		infos)
		
		  ### check if the video is compatible with ffmpeg or mplayer
		  
		  check_comp 
		  
		  ### General informations 
		  
		  get_general_infos
		  
		  ### Video informations 
		  
		  get_video_infos      
		  
		  ### Audio Informations
		  
		  get_audio_infos
		  
		  ### get the format
		  
		  get_format
		  
		  ### extra informations
		  
		  get_extra_infos
		  
		  
		  stop
		  ;;
		  *)
		  
		### check if the video is compatible with ffmpeg or mplayer
		
		if  [[ $OVERWRITE == 2  || ! -f "${DIRECTORY}/${OUTPUT}/info.txt" ]]
		then
		check_comp 
		else
		[[ $DEBUG -gt 0 ]] && cat "${DIRECTORY}/${OUTPUT}/info.txt"
		eval "$(cat "${DIRECTORY}/${OUTPUT}/info.txt")"
		fi
				
		    
				if [[ $MPLAYER_VIDEO_TEST == 0 || $MPLAYER_AUDIO_TEST == 0 ]] 
				then
				ERROR="ERROR: This video is not supported!"
				echo -e "\\n${RED}${ERROR}${NC}\\n"
				echo $ERROR >> ${DIRECTORY}/${OUTPUT}/error.txt
				stop
				else
				
				### try to read from the info file

				if  [[ $OVERWRITE == 2 ||  -z "$FILE_PATH" ]]
				then
			
				### General informations 
				
				get_general_infos
				
				### Video informations 
				
				get_video_infos	      
				
				### Audio Informations
				
				get_audio_infos
				
				
			 
				[[ ! -z $ERROR ]] &&  mediainfo ${INPUT} >> ${DIRECTORY}/${OUTPUT}/error.txt

				# Get some infos about the fornat 1.77 pat ntsc ...
				get_format 

				save_info "\\n# Format infos\\n"
				save_info "DETECTED_FORMAT=\"$DETECTED_FORMAT\""

				save_info "FF_PAD=\"$FF_PAD\""
				save_info "PADTOP=\"$PADTOP\""
				save_info "PADBOTTOM=\"$PADBOTTOM\""	

				save_info "CROPTOP=\"$CROPTOP\""
				save_info "CROPBOTTOM=\"$CROPBOTTOM\""	

				save_info "CROPLEFT=\"$CROPLEFT\""				
				save_info "CROPRIGHT=\"$CROPRIGHT\""	

				save_info "FF_CROP_WIDTH=\"$FF_CROP_WIDTH\""
				save_info "FF_CROP_HEIGHT=\"$FF_CROP_HEIGHT\""

				save_info "DISTORTION=\"$DISTORTION\""


				save_info  "NEW_WIDTH=$NEW_WIDTH"
				save_info  "NEW_HEIGHT=$NEW_HEIGHT"
				save_info  "NEW_SIZE=$NEW_SIZE"



				### extra informations

				get_extra_infos

				fi




	 
				# check if the format is detected (pal 1.77 2.35 etc)
				
						if [[ -z $DETECTED_FORMAT  ]] 
						then
						ERROR="ERROR: This video format is not supported!"
						echo -e "\\n${RED}${ERROR}${NC}\\n"
						echo $ERROR >> ${DIRECTORY}/${OUTPUT}/error.txt
						#save_info "${ERROR}"						
						
						else
						

 
							   
						# start the encoding   
						encode
							 
					 fi			
				fi 				
		  ;;
		esac
	
		[[ $CLEAN == 1 ]] && clean "${DIRECTORY}/${OUTPUT}${EXTENTION}"											


}





	   ### TODO 
	   # check_ouput_size "$FF_SIZE"
	   




		### $1 is a file
		
		if [[ -f $(realpath "${1}") ]]
		then
		
		SCAN_TYPE=1
		EXTENTION=$(echo $1  |grep -o  -E "\..{2,4}$")
		
		execute  "$(realpath "${1}")" 
		
		
		### $1 is a folder
		
		elif [[ -d  $(realpath "${1}") ]]
		then
		
		
		    SCAN_TYPE=2
		    DIRECTORY=$(realpath "${1}")
		
		    
		    for VIDEO  in `find ${DIRECTORY}  -name "*${EXTENTION}"`
		    do
		
		    SUBDIR=`basename "$VIDEO"`
		    SUBDIR=${SUBDIR%%${EXTENTION}}
		
		
		      #if [[ ! -d ${DIRECTORY}/${SUBDIR} || $OVERWRITE  !=  0 ]]
		      #then
		      execute $VIDEO 
		      #fi
		    done
		else 
		usage
		fi



exit 0
