#!/bin/bash
#get new videos from play

#go to the encoding machine and get the index page

wget  --user=encodeman --password=encode88video http://encoding-1.filmtrailer.com/video/all/ -O index.html
rm ./video/new_video.txt
# parse the links to a tmp file
cat index.html |grep -o '"http:[0-9a-z_/\./-]*.info"'|sed -e 's/"http/wget -N  --user=encodeman --password=encode88video  "http/' -e 's/info/org/'> tmp_video.txt

cat tmp_video.txt archive_video.txt |sort | uniq -u > ./video/new_video.txt

echo "#" >> archive_video.txt
cd ./video
#bash new_video.txt
cd ..
cat ./video/new_video.txt >> archive_video.txt