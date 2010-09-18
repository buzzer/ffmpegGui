//
//  ffmpegGui.m
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//

#import "ffmpegGui.h"


@implementation FFmpegGui
@synthesize videoWidth, videoHeight;
@synthesize videoWidthStd, videoHeightStd, maxRate, audioBitRate, audioSRate, threads;
@synthesize outDirectory, tmpDirectory, ffmpegApp, videoparApp, logfilePath;
@synthesize inVFile;
@synthesize outVFile;

- (Boolean) transcodeStart {
	// Call shell command with NSTask here and give a return value
	NSLog(@"Set video width to: %d.\n",      [self videoWidth]);
	NSLog(@"Set video height to: %d.\n",     [self videoHeight]);
	NSLog(@"Set input video file to: %@.\n", [self inVFile]);
	
	return YES;
}

@end
