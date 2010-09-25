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
@synthesize controller;

-(id)init {
	self = [super init];
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
		[controller taskFinished];
}

- (void) getVideoPar {
	videoparTask   = [[NSTask alloc] init];
  NSString *videoparPath = [[NSBundle  mainBundle] pathForResource:@"videopar" ofType:@"pl"];
	[videoparTask setLaunchPath: videoparPath];
	
	NSArray* videoparArgs;
	videoparArgs = [NSArray arrayWithObjects:
									[self inVFile],
									nil];
	[videoparTask setArguments: videoparArgs];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	
	[videoparTask setStandardOutput: pipe];
	[videoparTask setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	NSLog(@"Calling videopar with arguments: %@\n",videoparArgs);
	
	// Redirect output to stdout
	[videoparTask setStandardInput:[NSPipe pipe]];
	[videoparTask launch];
	[videoparTask waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog (@"%@", string);
	
	[controller textViewPrint:[NSString stringWithFormat:@"%@\n", string]];
	
	NSArray* videoPar = [string componentsSeparatedByString:@" "];
	NSArray* videoRes = [[videoPar objectAtIndex:0] componentsSeparatedByString:@"x"];

	videoWidth=[[videoRes objectAtIndex:0] intValue];
	videoHeight=[[videoRes objectAtIndex:1] intValue];
	assert(videoHeight > 0);
	assert(videoWidth > 0);
	if (videoHeight != 0) {
		aspectRatio = (float)self->videoWidth/self->videoHeight;
	}
	audioSRate = [[videoPar objectAtIndex:1] intValue];
	audioChannel = [[videoPar objectAtIndex:2] intValue];
	audioBitRate = [[videoPar objectAtIndex:3] intValue];
//	NSArray* videoParameter = [[[NSArray alloc] init] addObject:<#(id)anObject#> ];
	[controller setFormatProperties:(NSArray*)[[NSArray alloc] initWithObjects:string, nil]];
}

- (void) startTranscode {
//	[controllerCB processStarted];
	transcodeTask1 = [[NSTask alloc] init];
	
  NSString *transcodePath = [[NSBundle  mainBundle] pathForResource:@"transcode" ofType:@"sh"];
	
	[transcodeTask1	setLaunchPath: transcodePath];
	
	NSArray *transcodeArguments;
	//TODO also video bitrate
	transcodeArguments = [NSArray arrayWithObjects:
							 [self inVFile],
							 [NSString stringWithFormat:@"%d",[self videoWidthNew]],
 							 [NSString stringWithFormat:@"%d",[self videoHeightNew]],
 							 [NSString stringWithFormat:@"%d",[self audioBitRate]],
							 [NSString stringWithFormat:@"%d",[self audioChannel]],
							 nil];
	[transcodeTask1 setArguments: transcodeArguments];
	
		
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[transcodeTask1 setStandardOutput: pipe];
	[transcodeTask1 setStandardError: pipe];
	
	// Register as task termination observer
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(checkATaskStatus:)
																							 name:NSTaskDidTerminateNotification
																						 object:nil];
	// Register to get notified on new data from pipe
	[[NSNotificationCenter defaultCenter] addObserver:self 
																					 selector:@selector(getData:) 
																							 name: NSFileHandleReadCompletionNotification 
																						 object: [[transcodeTask1 standardOutput] fileHandleForReading]];
	// We tell the file handle to go ahead and read in the background asynchronously, and notify
	// us via the callback registered above when we signed up as an observer.  The file handle will
	// send a NSFileHandleReadCompletionNotification when it has data that is available.
	[[[transcodeTask1 standardOutput] fileHandleForReading] readInBackgroundAndNotify];

	NSLog(@"Calling transcode with arguments: %@\n",transcodeArguments);

	[controller taskStarted];
	// Redirect output to stdout
	//[transcodeTask1 setStandardInput:[NSPipe pipe]];

	// launch the task asynchronously
	[transcodeTask1 launch];
	
}

- (void) terminateTransTask {
	NSData *data;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
																				name:NSFileHandleReadCompletionNotification
																				object: [[transcodeTask1 standardOutput] fileHandleForReading]];
	// Make sure the task has actually stopped!
	[transcodeTask1 terminate];

	while ((data = [[[transcodeTask1 standardOutput] fileHandleForReading] availableData]) && [data length])
	{
		[controller textViewPrint: [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
	}

	NSLog(@"Terminating task: %@\n", self->transcodeTask1);
	[controller taskFinished];
	
}
// This method is called asynchronously when data is available from the task's file handle.
// We just pass the data along to the controller as an NSString.
- (void) getData: (NSNotification *)aNotification
{
	NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	// If the length of the data is zero, then the task is basically over - there is nothing
	// more to get from the handle so we may as well shut down.
	if ([data length])
	{
		// Send the data on to the controller; we can't just use +stringWithUTF8String: here
		// because -[data bytes] is not necessarily a properly terminated string.
		// -initWithData:encoding: on the other hand checks -[data length]
		[controller textViewPrint: [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
	} else {
		// We're finished here
		[self terminateTransTask];
	}
	
	// we need to schedule the file handle go read more data in the background again.
	[[aNotification object] readInBackgroundAndNotify];  
}
@end
