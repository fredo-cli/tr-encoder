#!/bin/bash
### go to this folder and run ./logos.sh
### you need to install imagemagick and ffmpeg 

#logos="dk7 dk11 dk15 dk99 fi3 fi7 fi13 fi11 fi15 fi18 "
logos="fi3"


for logo in $logos 
do
i="1"

### create folder and transparent background

[ ! -d "$logo" ]  && mkdir $logo &&  convert logos/$logo.png  -alpha transparent $logo/$logo-bg.png





		while [ $i -le 50 ]
		do
			echo $i
			disolve=$[$i*2]
			composite -dissolve $disolve logos/$logo.png  $logo/$logo-bg.png -alpha Set $logo/$i.png
			i=$[$i+1]
		done

		while [ $i -le 100 ]
		do
			echo $i
			composite -dissolve 100 logos/$logo.png  $logo/$logo-bg.png  -alpha Set $logo/$i.png
			i=$[$i+1]
		done

		while [ $i -le 149 ]
		do
			echo $i
			disolve=$[(150-$i)*2]
			composite -dissolve $disolve logos/$logo.png  $logo/$logo-bg.png  -alpha Set $logo/$i.png
			i=$[$i+1]
		done

### Create a movie 

ffmpeg-webm -i $logo/%d.png -sameq -vcodec png -y $logo.mov

### Clean up

rm -r $logo




done

exit
