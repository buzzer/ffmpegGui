//
//  FFmpegController.m
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//

#import "FFmpegController.h"

@implementation FFmpegController
//@synthesize widthFieldIn,heightFieldIn, vBitRateFieldIn, aBitRateFieldIn, aChanFieldIn;

- (id) init {
	if (self = [super init]){
		self->ffmpeggui = [[FFmpegGui alloc] init];
	}
	// Register callback to model
	[ffmpeggui setController:self];
//	[textView toggleContinuousSpellChecking:(id)self];
//	if ([self->textView isContinuousSpellCheckingEnabled]) {
//		[self->textView setContinuousSpellCheckingEnabled:YES];
//	}

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
	//[oPanel setMessage:@"Choose video to convert to the target format."];
	
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:fileTypes];
	
	if (result == NSOKButton) {
		filesToOpen = [oPanel filenames];
		theFileName = [filesToOpen objectAtIndex:0];
		NSLog(@"Open Panel Returned: %@.\n", theFileName);
		
		[ffmpeggui setInVFile:theFileName];
		[ffmpeggui getVideoPar];
		[self textViewPrint:[NSString stringWithFormat:@"%@\n",theFileName]];
	
		// Display opened filepath
		[filenameField setStringValue:theFileName];
	}
}
- (IBAction)saveFileSavePanel:(id)sender {
	int result;
	NSOpenPanel *sPanel = [NSOpenPanel openPanel];
	NSString * theFolderName;
	
	[sPanel setAllowsMultipleSelection:NO];
	[sPanel setCanChooseFiles:NO];
	[sPanel setCanChooseDirectories:YES];
	[sPanel setTitle:@"Choose Output Directory"];
	
	result = [sPanel runModal];
	
	if (result == NSFileHandlingPanelOKButton) {
		theFolderName = [[[sPanel URLs] objectAtIndex:0] absoluteString];
		
		NSLog(@"Save Panel Returned: %@.\n", theFolderName);
		
		[ffmpeggui setOutVFile:theFolderName];
		[self textViewPrint:[NSString stringWithFormat:@"Output folder: %@\n",theFolderName]];
		// Display opened filepath
		[folderNameField setStringValue:theFolderName];
	}
}
- (IBAction) interruptTranscode:(id)sender {
	[ffmpeggui terminateTransTask];
}
- (void) awakeFromNib {
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];
	[textView insertText:[NSString stringWithFormat:@"%@\n",now]];
	[widthField setIntegerValue:[ffmpeggui videoWidthStd]];
	[heightField setIntegerValue:[ffmpeggui videoHeightStd]];
	[vBitRateField setIntegerValue:512];
	[aBitRateField setIntegerValue:96];
	[aChanField setIntegerValue:2];
}
- (void) textViewPrint:(NSString*) string {
	[textView setEditable:YES];
	[textView setContinuousSpellCheckingEnabled:NO];
	[textView insertText:string];
	[textView setEditable:NO];
}
- (void) startProgressBar {
	[progressBar startAnimation:self];
}
- (void) stopProgressBar {
	[progressBar stopAnimation:self];
}
- (IBAction) openPreferences:(id)sender {
	
}
- (IBAction) openAbout:(id)sender {
	
}
@end
