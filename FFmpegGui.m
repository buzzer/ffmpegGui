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

- (Boolean) transcodeStart {
	// Call shell command with NSTask here and give a return value
	NSLog(@"Set video width to: %d.\n",      [self videoWidth]);
	NSLog(@"Set video height to: %d.\n",     [self videoHeight]);
	NSLog(@"Set input video file to: %@.\n", [self inVFile]);
	[self dummyTask];
	
	return YES;
}

//- (void)runFfmpegTask:(id)sender
//{
//	NSTask *aTask = [[NSTask alloc] init];
//	NSMutableArray *args = [NSMutableArray array];
//	
//	/* set arguments */
//	NSFileHandle * inputFile=[[self inVFile] fileSystemRepresentation];
//	NSFileHandle * outputFile=[[self inVFile] fileSystemRepresentation];
//	[args addObject:[[inputFile stringValue] lastPathComponent]];
//	[args addObject:[outputFile stringValue]];
//	[aTask setCurrentDirectoryPath:[[inputFile stringValue]
//																	stringByDeletingLastPathComponent]];
//	[aTask setLaunchPath:[taskField stringValue]];
//	[aTask setArguments:args];
//	[aTask launch];
//}
//
- (void)checkATaskStatus:(NSNotification *)aNotification {
	const int ATASK_SUCCESS_VALUE = 1;
	int status = [[aNotification object] terminationStatus];
	if (status == ATASK_SUCCESS_VALUE)
		NSLog(@"Task succeeded.");
	else
		NSLog(@"Task failed.");
}

-(void) dummyTask{
	self->task = [[NSTask alloc] init];

	NSString * scriptPath = @"/Users/sebastian/bin/any2video";
	[self->task	setLaunchPath: scriptPath];
	
	NSArray *arguments;
//	arguments = [NSArray arrayWithObjects: [self inVFile], @"-a", @"-t", nil];
arguments = [NSArray arrayWithObjects: @"Test",
							 [[self inVFile] UTF8String],
							// [NSNumber numberWithInt:[self videoWidth]],
//							 [NSNumber numberWithInt:[self videoHeight]],
							 nil];
	[self->task setArguments: arguments];
	NSLog(@"Arguments: %@\n",arguments);
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[self->task setStandardOutput: pipe];
	[self->task setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];

	// Redirect output to stdout
	[self->task setStandardInput:[NSPipe pipe]];
	[self->task launch];
	[self->task waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog (@"%@", string);
}
- (void) terminateTask{
	if ([self->task isRunning]) {
  	[self->task terminate];
		NSLog(@"Terminating task: %@\n", self->task);
	} else {
		NSLog(@"No task to abort\n");
	}

}

@end
