#!/usr/local/bin/bash



function PORTSNAP(){
sudo su -
# install portsnap if needed
} 



### mplayer

function INSTALL_MPLAYER_SVN(){

cd  
svn checkout -r  $MPLAYER_VERSION  svn://svn.mplayerhq.hu/mplayer/trunk mplayer
cd mplayer
sudo  su root -c 'gmake install'
}





function INSTALL_FFMPEG_old(){


chmod +x /home/fred/tr-encoder/tr-encoder.sh
}





# Controle the version of mplayer

echo -en "mplayer\t"
MPLAYER_VERSION_DETECTED=$(mplayer|head -1 |awk '{print $2 }'
)


if [[ "$MPLAYER_VERSION_DETECTED" != "$MPLAYER_VERSION" ]]
fi




### ruby-flvtool2

echo -en "ruby-flvtool2\t"
if [[ ! -z $(which flvtool2) ]]
then
fi






### sox

echo -en "sox\t"

if [[ ! -z $(which sox) ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^sox- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/sox && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/audio/sox && sudo make install clean

fi




### mediainfo

echo -en "mediainfo\t"

if [[ ! -z $(which mediainfo) ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && sudo make install clean

fi




### mpabox

echo -en "gpac-mp4box\t"

if [[ ! -z $(which mp4box) ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^gpac-mp4box- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/gpac-mp4box && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^gpac-mp4box- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/gpac-mp4box && sudo make install clean

fi




### readlink

echo -en "readlink\t"

if [[ ! -z $(which mediainfo) ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && sudo make install clean

fi


### seq2

echo -en "seq2\t"

if [[ ! -z $(which seq2) ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/misc/seq2 && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/misc/seq2 && sudo make install clean

fi





### md5

echo -en "md5 (cfv)\t"

if [[ -z $(which cfv) ]]
then


echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/security/cfv && sudo make install clean

else

echo -e "${green}true${NC}\t($(pkg_version  -vs ^cfv- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/security/cfv && make deinstall && sudo make install clean

fi



### x264

echo -en "x264\t"
if [[ ! -z $(which x264) && $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*) == $X264_VERSION ]]
then

echo -e "${green}true${NC}\t($(pkg_version  -vs ^x264- |awk -F " " '{print $1}')) $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*)"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && make deinstall && sudo make install clean

else

echo -e "${yellow}false${NC}\t"

[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && sudo make install clean
# old
# wget -O x264.patch  http://www.freebsd.org/cgi/query-pr.cgi?prp=132780-1-txt&n=/x264.patch 
# patch -p0 < x264.patch
# make install clean

fi



### ffmpeg

echo -en "ffmpeg\t"

FFMPEG_INSTALLED=$(ffmpeg -i 2>&1 |grep FFmpeg |grep -o SVN-r[0-9]* )
if [[ $FFMPEG_INSTALLED != "SVN-r$FFMPEG_VERSION" ]]
then

echo -e "${yellow}false${NC}\t($FFMPEG_INSTALLED)"
[[ $INSTALL == 1 ]] && INSTALL_FFMPEG

else

echo -e "${green}true${NC}\t($FFMPEG_INSTALLED)"

fi
