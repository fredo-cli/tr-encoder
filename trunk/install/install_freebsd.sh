# the script is base on
#http://piao-tech.blogspot.com/2008/04/get-latest-ffmpeg-svn-in-freebsd-70.html
#http://www.nabble.com/ffmpeg-patch-td22286995.html#a22286995
#http://www.freebsd.org/cgi/query-pr.cgi?pr=132780








sudo su -

### using protsnap to upgrade

# install portsnap if needed

#pkg_add -r portsnap
#mkdir /usr/ports


portsnap fetch
portsnap extract
portsnap update

# install audio lib and tools


cd /usr/ports/multimedia/atomicparsley/
make install clean
 
cd /usr/ports/multimedia/ruby-flvtool2/
make install clean
 
cd /usr/ports/audio/sox
make install clean

cd /usr/ports/multimedia/mediainfo/
make install clean


# sysutils for tr-encoder

cd /usr/ports/sysutils/readlink
make install clean


cd /usr/ports/misc/seq2
make install clean

cd /usr/ports/security/cfv
make install clean
 
 




 
cd /usr/ports/audio/faac
make install clean

cd /usr/ports/audio/faad
make install clean

cd /usr/ports/audio/lame
make install clean

cd /usr/ports/audio/liba52
make install clean



# apply a patch to the port x264
# and compile it


cd /usr/ports/multimedia/x264
# get a patch for  x264 
wget -O x264.patch  http://www.freebsd.org/cgi/query-pr.cgi?prp=132780-1-txt&n=/x264.patch 
patch -p0 < x264.patch
make install clean

exit







### install ffmpeg
# version 17768 + patch for wma3 pip.so 

wget http://dl.getdropbox.com/u/221284/ffmpeg.tar.gz
tar -xzvf ffmpeg.tar.gz 

cd ffmpeg

# checkout ffmpeg from subversion


svn checkout -r 17768 svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg
 
 
cd ffmpeg
 
 
#patch wma3
cd libavcodec
ln -s ../../wma3dec.c wma3dec.c
ln -s ../../wma3data.h wma3data.h
ln -s ../../wma3.h wma3.h
cd ../
patch -p0 <../wmapro_ffmpeg.patch
patch -p0 <../audioframesize.patch

# patch pip
cd ./vhook
ln -s  ../../pip1.2.1.c pip.c
cd ../
patch -p0  <  ../pip.patch
 
 
cd .. 
wget http://www.nabble.com/attachment/22286995/0/ffmpeg.bsd.patch
patch -p0 < ffmpeg.bsd.patch 
cd ffmpeg

 export LIBRARY_PATH=/usr/local/lib
 export CPATH=/usr/local/include

./configure --cc=cc --prefix=/usr/local --disable-debug --enable-memalign-hack --enable-shared --enable-postproc --extra-cflags="-I/usr/local/include/vorbis -I/usr/local/include" --extra-ldflags="-L/usr/local/lib -la52" --extra-libs=-pthread --enable-gpl --enable-pthreads --enable-swscale --mandir=/usr/local/man  --enable-libfaac --enable-libfaad --enable-libfaadbin --enable-libamr-nb --enable-nonfree --enable-libamr-wb --enable-nonfree --disable-mmx --disable-libgsm --enable-libmp3lame --disable-ffplay --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --disable-ipv6


# compile using GNU Make (gmake), not BSD Make
gmake

# install
sudo  su root -c 'gmake install'





#Install mplayer
#MPlayer SVN-r29033-4.2.1 (C) 2000-2009 MPlayer Team

cd  

svn checkout -r 29033 svn://svn.mplayerhq.hu/mplayer/trunk mplayer
cd mplayer
./configure
gmake
sudo  su root -c 'gmake install'




### install tr-encoder


cd 
# cX9fe6rg2Js6
# svn checkout https://tr-encoder.googlecode.com/svn/trunk/ tr-encoder --username froggies.dk

svn checkout http://tr-encoder.googlecode.com/svn/trunk/ tr-encoder

sudo ln -sf /home/fredo/tr-encoder/tr-encoder.sh /usr/bin/tr-encoder
chmod +x /home/fredo/tr-encoder/tr-encoder.sh






