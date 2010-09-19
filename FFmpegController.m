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
	
	[ffmpeggui setVideoWidthNew:[widthField intValue]];
	[ffmpeggui setVideoHeightNew:[heightField intValue]];
	[ffmpeggui setVideoBitRate:[vBitRateField intValue]];
	[ffmpeggui setAudioBitRate:[aBitRateField intValue]];
  [ffmpeggui setAudioChannel:[aChanField intValue]];
	[ffmpeggui startTranscode];
}

- (IBAction) getVideoPar:(id)sender {
	[ffmpeggui getVideoPar];
}

- (IBAction)loadFileOpenPanel:(id)sender {
	int result;
	NSArray *fileTypes = [NSArray arrayWithObjects:
												@"mov",@"avi",@"wmv",@"flv",@"mpeg", nil];
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
		[self->ffmpeggui getVideoPar];
	}
}
- (IBAction) interruptTranscode:(id)sender {
	[ffmpeggui terminateTransTask];
}
@end
