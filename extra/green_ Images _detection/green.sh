#!/bin/bash

### Create some thumb
ffmpeg -i video.mp4 -s 32x24 -sameq  -y -r 2 -t 12 -an  image-%2d.jpg 

### Remove 1 image
rm image-26.jpg


### create a montage
montage image-*.jpg  -tile 25x -geometry 32x24+0+0  images.png
convert  ruler.png   images.png -append  montage.png

### Clean up
rm image*

### Display the montage
display montage.png






