### extra
montage [0-9]*_[0-9]*.jpg -geometry 160x90+1+1 montage.png
rm *.jpg

### rename  mrd -> org
rename  s/mrd/org/ new/*.mrd

###

### clean
# ls  | sed   "/[0-9]*_[0-9]*/n" | sort|uniq | sed s/.org//|sort|uniq -u | sed "s/$/\.org/" |xargs  rm


	      ### info from ffmpeg 
	      
	      
	      
	      # get duration of the video with ffmpeg
	      
	      echo -e "#ffmpeg \\n"
	      DURATION=`ffmpeg  -i "$INPUT"  2>&1 |grep -o "Duration: [0-9]*:[0-9]*:[0-9]*"`
	      DURATION=${DURATION#"Duration: "}
	      MINUTE=`echo $DURATION| awk -F ':' '{ print $2 }'`
	      SECONDE=`echo $DURATION| awk -F ':' '{ print $3 }'`
	      DURATION=`echo  "( $MINUTE * 60 ) + $SECONDE "|bc`
	      echo "DURATION=$DURATION"
	      
	      
	      
	      
	      
	      
	      `mplayer  $INPUT  -frames 1 -identify -quiet -vo null -ao null  |grep  "ID_AUDIO_BITRATE="`  
	      
	      Get the size.(cropdetection mplayer)
	      
	      sourceWidth=`cat ${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop | grep ID_VIDEO_WIDTH`
	      sourceWidth=${sourceWidth#ID_VIDEO_WIDTH=}
	      sourceHeight=`cat ${DIRECTORY}/${SUBDIR}/${OUTPUT}.crop | grep ID_VIDEO_HEIGHT`
	      sourceHeight=${sourceHeight#ID_VIDEO_HEIGHT=}
	      SIZE=$sourceWidth:$sourceHeight
	      SIZE=` echo $SIZE |tr : x`
	      echo "SIZE=${SIZE}"
	      # get the width
	      WIDTH=`echo ${SIZE}|grep -o  ^[0-9]*`
	      #get the height
	      HEIGHT=`echo ${SIZE}|grep -o  [0-9]*$`
	      # get the ratio
	      