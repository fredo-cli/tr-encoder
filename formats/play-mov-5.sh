#!/usr/local/bin/bash

PREFIX="play"
FF_FORMAT="mov"
PLAY_SIZE="_5"

FF_WIDTH=640
FF_HEIGHT=360
FF_FPS=24
FF_VBITRATE=1050

FF_AB=96
FF_AC=2
FF_AR=44100

FF_PASS=2
MPLAYER_SUB=" -subfont-text-scale 2 -sub-bg-color 0 -sub-bg-alpha 150 -font /usr/share/fonts/truetype/msttcorefonts/arial.ttf -utf8 "





		if [[ $NEW_WIDTH -ge 640 ]]
		then
		
		
				if [[ $EVALUTE == 1 && $EVALUATION == 0 ]]
				then
				
				### evalute only once or encode
				
				evaluation_ini
				
				### check the evolution of the encoding
				
				elif [[ $EVALUTE == 1 && $EVALUATION -gt 0 ]]
				then
				
				evaluation_check
				
				else
				
				### encode the video
				
				. "$APP_DIR/formats/$PREFIX-$FF_FORMAT.sh" 
				
				fi

		
		fi