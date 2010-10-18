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

//- (IBAction) getVideoPar:(id)sender {
//	[ffmpeggui getVideoPar];
//}

- (IBAction)loadFileOpenPanel:(id)sender {
	int result;
	NSArray *fileTypes = [NSArray arrayWithObjects:
												@"mov",@"avi",@"wmv",@"flv",@"mpeg", nil];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSArray *filesToOpen;
	NSString *theFileName;
	
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setTitle:@"Choose Video File"];
	
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:fileTypes];
	
	if (result == NSFileHandlingPanelOKButton) {
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
	[sPanel setTitle:@"Choose output directory"];
	[sPanel setDirectoryURL:[NSURL URLWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
	
	result = [sPanel runModal];
	
	if (result == NSFileHandlingPanelOKButton) {
		theFolderName = [[[sPanel URLs] objectAtIndex:0] path];
		
		NSLog(@"Save Panel Returned: %@.\n", theFolderName);
		
		[ffmpeggui setOutVFile:theFolderName];
		[self textViewPrint:[NSString stringWithFormat:@"Output folder: %@\n",theFolderName]];
		// Display opened filepath
		[folderNameField setStringValue:theFolderName];
		[pathControlPath setURL:[[sPanel URLs] objectAtIndex:0]];
	}
}
- (IBAction) interruptTranscode:(id)sender {
	[ffmpeggui terminateTransTask];
}
- (void) awakeFromNib {
	NSString* theFolderName = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
	[self textViewPrint:[NSString stringWithFormat:@"%@\n",now]];
	[widthField setIntegerValue:[ffmpeggui videoWidthStd]];
	[heightField setIntegerValue:[ffmpeggui videoHeightStd]];
	[vBitRateField setIntegerValue:512];
	[aBitRateField setIntegerValue:96];
	[aChanField setIntegerValue:2];
	// Set default output directory
	[pathControlPath setURL:[NSURL URLWithString:theFolderName]];
	[ffmpeggui setOutVFile:theFolderName];
}
- (void) textViewPrint:(NSString*) string {
	[textView setEditable:YES];
	[textView setContinuousSpellCheckingEnabled:NO];
	[textView insertText:string];
	[textView setEditable:NO];
}
- (void) taskStarted {
	[progressBar startAnimation:self];
}
- (void) taskFinished {
	[progressBar stopAnimation:self];
}
- (IBAction) openPreferences:(id)sender {
	;
}
- (IBAction) openAbout:(id)sender {
	;
}
- (void) setFormatProperties:(NSArray*)propertyArray {
	NSMutableString *trackFormatStr = [NSMutableString string];
	NSEnumerator *enumerator = [propertyArray objectEnumerator];
	id anStringObject;
	
	while (anStringObject = [enumerator nextObject]) {
		[trackFormatStr appendFormat:@"%@", anStringObject];
	}
	[inFileProperties setEditable:YES];
	[inFileProperties	setStringValue:trackFormatStr];
	[inFileProperties setEditable:NO];
}
@end
