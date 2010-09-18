//
//  FFmpegController.h
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FFmpegGui.h"


@interface FFmpegController : NSObject {
	IBOutlet NSTextField *widthField;
	IBOutlet NSTextField *heightField;	
	IBOutlet NSTextField *filenameField;
	FFmpegGui *ffmpeggui;
}
- (IBAction)transcode:(id)sender;
- (IBAction)loadFileOpenPanel:(id)sender;
@end
