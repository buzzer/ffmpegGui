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
@synthesize controllerCB;

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
		[controllerCB stopProgressBar];
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
	
	[controllerCB textViewPrint:[NSString stringWithFormat:@"%@\n", string]];
	
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
	
	//NSFileHandle *file;
	//file = [pipe fileHandleForReading];

	NSLog(@"Calling transcode with arguments: %@\n",transcodeArguments);

	[controllerCB startProgressBar];
	// Redirect output to stdout
	//[transcodeTask1 setStandardInput:[NSPipe pipe]];

	// launch the task asynchronously
	[transcodeTask1 launch];
	
	//[transcodeTask1 waitUntilExit];
	
	//NSData *data;
	//data = [file readDataToEndOfFile];
	
	//NSString *string;
	//string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	//NSLog (@"%@", string);
	//[controllerCB textViewPrint: string];
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
		[controllerCB textViewPrint: [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
	}

	NSLog(@"Terminating task: %@\n", self->transcodeTask1);
	[controllerCB stopProgressBar];
	
//	if ([self->transcodeTask1 isRunning]) {
//  	[self->transcodeTask1 terminate];
//		NSLog(@"Terminating task: %@\n", self->transcodeTask1);
//		[controllerCB textViewPrint:@"Terminating task: %@\n", self->transcodeTask1];
//	} else {
//		NSLog(@"No task to abort\n");
//		[controllerCB textViewPrint:@"No task to abort\n"];
//	}
//		[controllerCB stopProgressBar];
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
		[controllerCB textViewPrint: [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
	} else {
		// We're finished here
		[self terminateTransTask];
	}
	
	// we need to schedule the file handle go read more data in the background again.
	[[aNotification object] readInBackgroundAndNotify];  
}
@end
