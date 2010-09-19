#!/bin/sh

# transcode.sh
# ffmpegGui
#
# Created by Sebastian on 19.09.10.
# Copyright 2010 Sebastian Rockel. All rights reserved.
#
# Outputs ipod/iphone compatible video files in $ODIR
# Using 2-pass encoding

FFMPEG="ffmpeg"
VIDEOPAR="videopar.pl"
LOGFILE="$HOME/`basename $0`.log"

echo "Called with args: "$@

# TODO take also relative paths
if [ "$1" = "" ] || [ ! -f "$1" ]
then
  echo "usage: `basename $0` <input_video>"
  echo "Absolute path is needed!"
  exit 0
fi

# Source file parameters
i=0
for par in `$VIDEOPAR "$1"`; do
  case $i in
    0 ) resolution=$par
        vwidth=`echo $resolution | sed -e 's/x.*//'`
        vheight=`echo $resolution | sed -e 's/.*x//'` ;;
    1 ) audiorate=$par ;;
    2 ) audiochan=$par ;;
  esac
  let i=$i+1
done

# ffmpeg cannot handle more than 2 channel audio
case $audiochan in
  [1-2])    ;;
  "stereo") ;;
  *) echo "Embedded audio track not compatible: $audiochan" ; exit 0 ;;
esac

# Output parameters of video
MAXRATE="1450k"
VBITR=512
ABITR=96
ARATE=44100
# Calculate video width and height
VWIDTH_STD=480 ; VHEIGHT_STD=320 # iPod default
VRatioIpod=`echo "$VWIDTH_STD/$VHEIGHT_STD" | bc -l`
OriVRatio=`echo "$vwidth/$vheight" | bc -l`
if [ `echo "$OriVRatio<$VRatioIpod" | bc` == "1"  ] ; then
  VHEIGHT=$VHEIGHT_STD
  VWIDTH=`echo "$VHEIGHT_STD*$OriVRatio" | bc -l | sed -e 's/\..*//'`
else
  VWIDTH=$VWIDTH_STD
  VHEIGHT=`echo "$VWIDTH_STD/$OriVRatio" | bc -l | sed -e 's/\..*//'`
fi
# For ffmpeg resolution has to be multiple of 2
let wOddRatio=$VWIDTH%2
let hOddRatio=$VHEIGHT%2
[ $wOddRatio -eq 1 ] && let VWIDTH=$VWIDTH-1
[ $hOddRatio -eq 1 ] && let VHEIGHT=$VHEIGHT-1
THREADS=0 # 0 sets automatic
ODIR="/Users/sebastian/Music/iTunes/iTunes Music/Movies/"


exit 0
