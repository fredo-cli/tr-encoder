#!/usr/local/bin/bash

# config
INSTALL=0
REINSTALL=0


LAME_VERSION=3.98
FFMPEG_VERSION=17768
X264_VERSION=0.65



usage() {
echo >&2 "Usage: `basename $0` [-i install] [-i reinstall]"
}


    while getopts "iI" option
    do
	case "$option" in
	  i)	INSTALL=1;;	
	  I)	REINSTALL=1;;
	[?])    usage
		exit 1;;
	esac
    done
    shift $(($OPTIND - 1))




# Define some colors:

red='\e[0;31m'
RED='\e[1;31m'

green='\e[0;32m'
GREEN='\e[1;32m'

yellow='\e[0;33m'
YELLOW='\e[1;33m'

NC='\e[0m' 


## ??
# cd /usr/ports/audio/liba52
# make install clean




function PORTSNAP(){
sudo su -
# install portsnap if needed
#pkg_add -r portsnap
#mkdir /usr/ports
#portsnap fetch
#portsnap extract

portsnap fetch
portsnap update
}


### lame

function INSTALL_LAME(){
#http://fastbull.dl.sourceforge.net/sourceforge/lame/lame-398.tar.gz
cd
wget http://freefr.dl.sourceforge.net/sourceforge/lame/lame-397.tar.gz -O - | tar xzf -
cd lame-398
./configure --enable-shared --enable-static
sudo gmake
sudo gmake install
} 


function INSTALL_MPLAYER_old(){

cd  
svn checkout -r 29033 svn://svn.mplayerhq.hu/mplayer/trunk mplayer
cd mplayer
./configure
gmake
sudo  su root -c 'gmake install'
}


function INSTALL_FFMPEG(){
cd 


echo -e "${yellow}# clean ffmpeg*${NC}"
[[ -d ffmpeg ]] &&  rm -rf ffmpeg*
mkdir ffmpeg
cd ffmpeg

echo -e "${yellow}# checkout version $FFMPEG_VERSIONff from ffmpeg${NC}"

svn checkout -r $FFMPEG_VERSION svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg

 
cd ffmpeg

#patch wma3 

echo -e "${yellow}# add patch wma3${NC}" 

cd libavcodec
ln -s ../../wma3dec.c wma3dec.c
ln -s ../../wma3data.h wma3data.h
ln -s ../../wma3.h wma3.h
cd ../
patch -p0 <../wmapro_ffmpeg.patch
patch -p0 <../audioframesize.patch

# patch pip

echo -e "${yellow}# add patch pip${NC}" 
cd ./vhook
ln -s  ../../pip1.2.1.c pip.c
cd ../
patch -p0  <  ../pip.patch
 
echo "${yellow}# add patch freebsd${NC}" 
cd .. 
wget http://www.nabble.com/attachment/22286995/0/ffmpeg.bsd.patch
patch -p0 < ffmpeg.bsd.patch 
cd ffmpeg

echo -e "${yellow}# configure${NC}" 
export LIBRARY_PATH=/usr/local/lib
export CPATH=/usr/local/include
# --enable-swscale
./configure --cc=cc --prefix=/usr/local --disable-debug --enable-memalign-hack --enable-shared --enable-postproc --extra-cflags="-I/usr/local/include/vorbis -I/usr/local/include" --extra-ldflags="-L/usr/local/lib -la52" --extra-libs=-pthread --enable-gpl --enable-pthreads  --mandir=/usr/local/man  --enable-libfaac --enable-libfaad --enable-libfaadbin --enable-libamr-nb --enable-nonfree --disable-libamr-wb --enable-nonfree --disable-mmx --disable-libgsm --enable-libmp3lame --disable-ffplay --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --disable-ipv6


# compile using GNU Make (gmake), not BSD Make
echo -e "${yellow}# gmake${NC}" 
gmake

# install

echo -e "${yellow}# gmake install${NC}" 
sudo  su root -c 'gmake install'


}

function INSTALL_TR-ENCODER(){
cd 
svn checkout http://tr-encoder.googlecode.com/svn/trunk/ tr-encoder
sudo ln -sf /home/fred/tr-encoder/tr-encoder.sh /usr/bin/tr-encoder
chmod +x /home/fred/tr-encoder/tr-encoder.sh
}


# Controle the version of lame

echo -en "lame\t"
LAME_VERSION_DETECTED=$(lame --longhelp|grep -o "version [0-9.]\{4,\}")

#if [[ -z $(lame --longhelp|grep "version" |grep  -o "3.98 ") ]]
if [[ -z $(pkg_version  -vs ^lame- |grep  -o $LAME_VERSION) ]]
then 
echo -e "${yellow}false${NC}\t($LAME_VERSION_DETECTED)"
[[ $INSTALL == 1 ]] && INSTALL_LAME
else
echo -e "${green}true${NC}\t($LAME_VERSION_DETECTED)"
[[ $REINSTALL == 1 ]] && INSTALL_LAME
fi


# Controle if faac  is install

echo -en "faac\t"
if [[ ! -z $(which faac) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^faac- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/faac/ && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/audio/faac/ && sudo make install clean
fi


# Controle if faacd  is install

echo -en "faad\t"
if [[ ! -z $(which faad) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^faad2- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/faad/ && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/audio/faad/ && sudo make install clean
fi




# Controle if AtomicParsley  is install

echo -en "AtomicParsley\t"
if [[ ! -z $(which AtomicParsley) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^AtomicParsley |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/atomicparsley/ && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^AtomicParsley |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/atomicparsley/ && sudo make install clean
fi


# Controle if ruby-flvtool2  is install

echo -en "ruby-flvtool2\t"
if [[ ! -z $(which flvtool2) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^ruby-flvtool2 |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/ruby-flvtool2/ && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^ruby-flvtool2 |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/ruby-flvtool2/ && sudo make install clean
fi


# Controle if ruby-flvtool2  is install

echo -en "sox\t"
if [[ ! -z $(which flvtool2) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^sox- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/audio/sox && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^sox- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/audio/sox && sudo make install clean
fi



# Controle if mediainfo  is install

echo -en "mediainfo\t"
if [[ ! -z $(which mediainfo) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^mediainfo- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/mediainfo/ && sudo make install clean
fi


# Controle if readlink  is install

echo -en "readlink\t"
if [[ ! -z $(which mediainfo) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^readlink- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/sysutils/readlink && sudo make install clean
fi

# Controle if seq2  is install

echo -en "seq2\t"
if [[ ! -z $(which seq2) ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/misc/seq2 && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t($(pkg_version  -vs ^seq2- |awk -F " " '{print $1}'))"
[[ $INSTALL == 1 ]] && cd /usr/ports/misc/seq2 && sudo make install clean
fi


# Controle if md5  is install

echo -en "md5 (cfv)\t"
if [[  ! -z $(pkg_version  -vs ^cfv- |awk -F " " '{print $1}' | grep "pkg_version: no packages match pattern") ]]
then
echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/security/cfv && sudo make install clean
else
echo -e "${green}true${NC}\t($(pkg_version  -vs ^cfv- |awk -F " " '{print $1}'))"
[[ $REINSTALL == 1 ]] && cd /usr/ports/security/cfv && make deinstall && sudo make install clean
fi



# Controle if x264  is install and the check version

echo -en "x264\t"
if [[ ! -z $(which x264) && $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*) == $X264_VERSION ]]
then
echo -e "${green}true${NC}\t($(pkg_version  -vs ^x264- |awk -F " " '{print $1}')) $(x264 --version |grep x264 |grep -o [0-9]\\.[0-9]*)"
[[ $REINSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && make deinstall && sudo make install clean
else
echo -e "${yellow}false${NC}\t"
[[ $INSTALL == 1 ]] && cd /usr/ports/multimedia/x264 && sudo make install clean
fi


# old
# wget -O x264.patch  http://www.freebsd.org/cgi/query-pr.cgi?prp=132780-1-txt&n=/x264.patch 
# patch -p0 < x264.patch
# make install clean


echo -en "ffmpeg\t"
FFMPEG_INSTALLED=$(ffmpeg -i 2>&1 |grep FFmpeg |grep -o SVN-r[0-9]* )
if [[ $FFMPEG_INSTALLED != "SVN-r$FFMPEG_VERSION" ]]
then
echo -e "${yellow}false${NC}\t($FFMPEG_INSTALLED)"
[[ $INSTALL == 1 ]] && INSTALL_FFMPEG
else
echo -e "${green}true${NC}\t($FFMPEG_INSTALLED)"
fi


cd

echo "Press any keys to exit"
[[ $INSTALL == 0 ]] && echo "bash $0 -i to install missing packages"
read
exit







