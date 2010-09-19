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
@synthesize videoWidthNew, videoHeightNew;
@synthesize maxRate, audioBitRate, audioSRate, threads, audioChannel, videoBitRate;
@synthesize videoWidthStd, videoHeightStd;
@synthesize aspectRatioStd, aspectRatio;
@synthesize outDirectory, tmpDirectory, ffmpegApp, videoparApp, logfilePath;
@synthesize inVFile;
@synthesize outVFile;

-(id)init {
	self = [super init];
	// Register as task termination observer
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(checkATaskStatus:)
																							 name:NSTaskDidTerminateNotification
																						 object:nil];
	// Set default parameters
	self->videoWidthStd = 480;
	self->videoHeightStd = 320;
	self->aspectRatioStd = (float)self->videoWidthStd/self->videoHeightStd;
	self->videoWidthNew = self->videoWidthStd;
	self->videoHeightNew = self->videoHeightStd;

	return self;
}

- (void)checkATaskStatus:(NSNotification *)aNotification {
	const int ATASK_SUCCESS_VALUE = 0;
	int status = [[aNotification object] terminationStatus];
	if (status == ATASK_SUCCESS_VALUE)
		NSLog(@"Task succeeded.");
	else
		NSLog(@"Task failed.");
}

- (void) getVideoPar {
	self->videoparTask   = [[NSTask alloc] init];
  NSString *videoparPath = [[NSBundle  mainBundle] pathForResource:@"videopar" ofType:@"pl"];
	[self->videoparTask setLaunchPath: videoparPath];
	
	NSArray* videoparArgs;
	videoparArgs = [NSArray arrayWithObjects:
									[self inVFile],
									nil];
	[self->videoparTask setArguments: videoparArgs];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	
	[self->videoparTask setStandardOutput: pipe];
	[self->videoparTask setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	NSLog(@"Calling videopar with arguments: %@\n",videoparArgs);
	
	// Redirect output to stdout
	[self->videoparTask setStandardInput:[NSPipe pipe]];
	[self->videoparTask launch];
	[self->videoparTask waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog (@"%@", string);
	NSArray* videoPar = [string componentsSeparatedByString:@" "];
	NSArray* videoRes = [[videoPar objectAtIndex:0] componentsSeparatedByString:@"x"];

	self->videoWidth=[[videoRes objectAtIndex:0] intValue];
	self->videoHeight=[[videoRes objectAtIndex:1] intValue];
	assert(self->videoHeight > 0);
	assert(self->videoWidth > 0);
	if (self->videoHeight != 0) {
		self->aspectRatio = (float)self->videoWidth/self->videoHeight;
	}
	self->audioSRate = [[videoPar objectAtIndex:1] intValue];
	self->audioChannel = [[videoPar objectAtIndex:2] intValue];
	self->audioBitRate = [[videoPar objectAtIndex:3] intValue];

}

- (void) startTranscode {
	self->transcodeTask1 = [[NSTask alloc] init];
	
  NSString *transcodePath = [[NSBundle  mainBundle] pathForResource:@"transcode" ofType:@"sh"];
	
	[self->transcodeTask1	setLaunchPath: transcodePath];
	
	NSArray *transcodeArguments;
	transcodeArguments = [NSArray arrayWithObjects:
							 [self inVFile],
							 [NSString stringWithFormat:@"%d",[self videoWidthNew]],
 							 [NSString stringWithFormat:@"%d",[self videoHeightNew]],
 							 [NSString stringWithFormat:@"%d",[self audioBitRate]],
							 [NSString stringWithFormat:@"%d",[self audioChannel]],
							 nil];
	[self->transcodeTask1 setArguments: transcodeArguments];
	
		
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[self->transcodeTask1 setStandardOutput: pipe];
	[self->transcodeTask1 setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];

	NSLog(@"Calling transcode with arguments: %@\n",transcodeArguments);

	// Redirect output to stdout
	[self->transcodeTask1 setStandardInput:[NSPipe pipe]];
	[self->transcodeTask1 launch];
	[self->transcodeTask1 waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog (@"%@", string);
}

- (void) terminateTransTask {
	if ([self->transcodeTask1 isRunning]) {
  	[self->transcodeTask1 terminate];
		NSLog(@"Terminating task: %@\n", self->transcodeTask1);
	} else {
		NSLog(@"No task to abort\n");
	}
}

@end
