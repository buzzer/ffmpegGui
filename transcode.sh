#!/bin/sh

# transcode.sh
# ffmpegGui
#
# Created by Sebastian on 19.09.10.
# Copyright 2010 Sebastian Rockel. All rights reserved.
#
# Outputs ipod/iphone compatible video files in $ODIR
# Using 2-pass encoding

FFMPEG="/opt/local/bin/ffmpeg"
LOGFILE="$HOME/`basename $0`.log"

echo "Called with args: "$@

# TODO take also relative paths
if [ "$1" = "" ] || [ ! -f "$1" ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ -z $5 ]
then
  echo "usage: `basename $0` <input_video>"
  echo "Absolute path is needed!"
  exit 0
fi

vwidth=$2
vheight=$3
audiorate=$4
audiochan=$5
OriVRatio=`echo "$vwidth/$vheight" | bc -l`

# ffmpeg cannot handle more than 2 channel audio
case $audiochan in
  [0-2])    ;;
  "stereo") ;;
  *) echo "Embedded audio track not compatible: $audiochan" ; exit 0 ;;
esac

# Output parameters of video
MAXRATE="1450k"
VBITR=512
ABITR=96
ARATE=44100
VWIDTH=$vwidth
VHEIGHT=$vheight

let wOddRatio=$VWIDTH%2
let hOddRatio=$VHEIGHT%2
[ $wOddRatio -eq 1 ] && let VWIDTH=$VWIDTH-1
[ $hOddRatio -eq 1 ] && let VHEIGHT=$VHEIGHT-1
THREADS=0 # 0 sets automatic
ODIR="/Users/sebastian/Music/iTunes/iTunes Music/Movies/"

echo $VWIDTH $VHEIGHT $ABITR $audiochan


# Create unique temp directory
#RANPREFIX="`basename $0`-""$RANDOM"
#TMPDIR="/tmp/$RANPREFIX/" ;
#[ -d "$TMPDIR" ] || mkdir "$TMPDIR" || exit -1
#cd $TMPDIR

echo
echo "Encode with following settings:"
echo video bitrate: "$VBITR"
echo audio bitrate: "$ABITR"
echo audio sample rate: "$ARATE"
echo audio channel: "$audiochan"
echo video size: "$VWIDTH"x"$VHEIGHT"
echo aspect ratio: "$OriVRatio"
echo 2-pass encoding
echo threads: $THREADS
echo output directory: $ODIR
echo

#IFILE="$1"
IFILE=""
OFILE="$TMPDIR"`basename "$1"`.mp4

#echo "`date` `basename "$OFILE"` BEGIN ENCODING" >> $LOGFILE

# 1st pass
$FFMPEG -an -pass 1 \
  -i "$IFILE" \
  -threads $THREADS \
  -vf "scale=$VWIDTH:$VHEIGHT" \
  -vcodec libx264 \
  -flags +loop \
  -cmp +chroma \
  -partitions +parti4x4+partp4x4+partp8x8+partb8x8 \
  -subq 1 \
  -trellis 0 \
  -refs 2 \
  -coder 0 \
  -me_range 24 \
  -g 250 \
  -keyint_min 30 \
  -sc_threshold 40 \
  -i_qfactor 0.71 \
  -flags2 \
  -bpyramid-wpred-mixed_refs-dct8x8+fastpskip \
  -b "$VBITR"k \
  -minrate 75k \
  -maxrate $MAXRATE \
  -bufsize 10M \
  -rc_eq 'blurCplx^(1-qComp)' \
  -qcomp 0.75 \
  -qmin 10 \
  -qmax 51 \
  -qdiff 9 \
  -level 30 \
  -f rawvideo -y /dev/null || exit -1

  #"$OFILE" && rm "$OFILE" || exit -1

  # 2nd pass
$FFMPEG \
  -i "$IFILE" \
  -acodec libfaac \
  -ab "$ABITR"k \
  -ar $ARATE \
  -ac 2 \
  -pass 2 \
  -threads $THREADS \
  -vf "scale=$VWIDTH:$VHEIGHT" \
  -vcodec libx264 \
  -flags +loop \
  -cmp +chroma \
  -partitions +parti4x4+partp4x4+partp8x8+partb8x8 \
  -subq 1 \
  -trellis 2 \
  -refs 4 \
  -coder 0 \
  -me_range 24 \
  -g 250 \
  -keyint_min 30 \
  -sc_threshold 40 \
  -i_qfactor 0.71 \
  -b "$VBITR"k \
  -minrate 75k \
  -maxrate $MAXRATE \
  -bufsize 10M \
  -rc_eq 'blurCplx^(1-qComp)' \
  -qcomp 0.75 \
  -qmin 10 \
  -qmax 51 \
  -qdiff 9 \
  -level 30 \
  "$OFILE" && mv "$OFILE" "$ODIR""`basename "$OFILE"`" && \
    echo && echo Moved "$OFILE" to "$ODIR""`basename "$OFILE"`" && echo

#echo "`date` `basename "$OFILE"` END ENCODING" >> $LOGFILE

# Clean log files
#rm ffmpeg2pass-0.log x264_2pass.log* || exit -1
#rm -r $TMPDIR || exit -1

exit 0
