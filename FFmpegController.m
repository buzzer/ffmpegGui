//
//  FFmpegController.m
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//

#import "FFmpegController.h"


@implementation FFmpegController
- (id) init {
	if (self = [super init]){
		self->ffmpeggui = [[FFmpegGui alloc] init];
	}
	return self;
}

- (IBAction)transcode:(id)sender {
	Boolean result;
	
	[ffmpeggui setVideoWidth:[widthField intValue]];
	[ffmpeggui setVideoHeight:[heightField intValue]];
	
	result = [ffmpeggui transcodeStart];
}

- (IBAction)loadFileOpenPanel:(id)sender {
	int result;
	NSArray *fileTypes = [NSArray arrayWithObjects:@"txt", @"log", @"mov", nil];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSArray *filesToOpen;
	NSString *theFileName;
	
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setTitle:@"Choose Video File"];
	[oPanel setMessage:@"Choose video to convert to the target format."];
	
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:fileTypes];
	
	if (result == NSOKButton) {
		filesToOpen = [oPanel filenames];
		theFileName = [filesToOpen objectAtIndex:0];
		NSLog(@"Open Panel Returned: %@.\n", theFileName);
		
		[self->ffmpeggui setInVFile:theFileName];
	}
}
- (IBAction) interruptTranscode:(id)sender {
	[ffmpeggui terminateTask];
}
@end
