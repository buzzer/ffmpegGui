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

-(id)init {
	self = [super init];
	// Register as task termination observer
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(checkATaskStatus:)
																							 name:NSTaskDidTerminateNotification
																						 object:nil];

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
}

- (void) startTranscode {
	self->transcodeTask1 = [[NSTask alloc] init];
	
  NSString *transcodePath = [[NSBundle  mainBundle] pathForResource:@"transcode" ofType:@"sh"];
	
	[self->transcodeTask1	setLaunchPath: transcodePath];
	
	NSArray *transcodeArguments;
	transcodeArguments = [NSArray arrayWithObjects:
							 [self inVFile],
							 [NSString stringWithFormat:@"%d",[self videoWidth]],
 							 [NSString stringWithFormat:@"%d",[self videoHeight]],
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
