#!/usr/bin/perl

# videopar.pl
# ffmpegGui
#
# Created by Sebastian on 19.09.10.
# Copyright 2010 Sebastian Rockel. All rights reserved.

# Read and return video parameters

use warnings;
use strict;


if ( $#ARGV+1 < 1) {
	print "No argument given\n";
	exit 0;
}
	
print "Called with args: $ARGV[0]\n";

my $INFILE=shift;
die "Cannot open file $INFILE, $!" if (! -e $INFILE);
my $TMPDIR="/tmp";
my $RAWINFO="rawinfo.txt";
qx(/opt/local/bin/ffmpeg -i "$INFILE" 2&> "$TMPDIR"/"$RAWINFO");
open(RAWINFO, "<", "$TMPDIR/$RAWINFO") or die "Cannot open file: $!";
my @videopar;
my @audiopar;
while (<RAWINFO>) {
  chomp($_);
  # Video parameters
  if ( $_=~ m/Video:(.*)/g ) {
    @videopar = split(",", $1);
  # Audio parameters
  } elsif ( $_=~ m/Audio:(.*)/g ) {
    @audiopar = split(",", $1);
  }
}
my @vidpar;
# resolution
my @resolution = split(" ", $videopar[2]);
push(@vidpar, $resolution[0]);
# video rate
#my @vrate = split(" ", $videopar[3]);
#push(@vidpar, $vrate[0]);
## fps
#my @fps = split(" ", $videopar[4]);
#push(@vidpar, $fps[0]);
# sample rate
my @srate = split(" ", $audiopar[1]);
push(@vidpar, $srate[0]);
# channels
my @channel = split(" ", $audiopar[2]);
push(@vidpar, $channel[0]);
# audio rate
#my @arate = split(" ", $audiopar[4]);
#push(@vidpar, $arate[0]);

foreach (@vidpar) {
  print $_." ";
}

system("rm -f '$TMPDIR/$RAWINFO'");

exit 0;
