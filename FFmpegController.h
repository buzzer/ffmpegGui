//
//  FFmpegController.h
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "FFmpegGui.h"

@class FFmpegGui;

@interface FFmpegController : NSObject {
	IBOutlet NSTextField *widthField;
	IBOutlet NSTextField *heightField;	
	IBOutlet NSTextField *filenameField;
	IBOutlet NSTextField *vBitRateField;
	IBOutlet NSTextField *aBitRateField;
	IBOutlet NSTextField *aChanField;
//	IBOutlet NSTextField *widthFieldIn;
//	IBOutlet NSTextField *heightFieldIn;	
//	IBOutlet NSTextField *vBitRateFieldIn;
//	IBOutlet NSTextField *aBitRateFieldIn;
//	IBOutlet NSTextField *aChanFieldIn;
	IBOutlet NSTextView  *textView;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *ffmpegPath;
	FFmpegGui *ffmpeggui;
}
//@property (readwrite,copy) NSTextField* widthFieldIn;
//@property (readwrite,copy) NSTextField* heightFieldIn;
//@property (readwrite,copy) NSTextField* vBitRateFieldIn;
//@property (readwrite,copy) NSTextField* aBitRateFieldIn;
//@property (readwrite,copy) NSTextField* aChanFieldIn;

- (IBAction)getVideoPar:(id)sender;
- (IBAction)transcode:(id)sender;
- (IBAction)loadFileOpenPanel:(id)sender;
- (IBAction)interruptTranscode:(id)sender;
- (void)textViewPrint:(NSString*)string;
- (void)startProgressBar;
- (void)stopProgressBar;
- (IBAction) openPreferences:(id)sender;
- (IBAction) openAbout:(id)sender;

@end
