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
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSArray *filesToOpen;
	NSString *theFileName;
	
	[oPanel setAllowsMultipleSelection:NO];
	
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil ];
	
	if (result == NSOKButton) {
		filesToOpen = [oPanel filenames];
		theFileName = [filesToOpen objectAtIndex:0];
		NSLog(@"Open Panel Returned: %@.\n", theFileName);
		
		[self->ffmpeggui setInVFile:theFileName];
	} else {
		NSLog(@"Open file failed to load: %@.\n", theFileName);
	}
}
@end
