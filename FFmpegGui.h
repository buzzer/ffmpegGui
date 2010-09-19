//
//  ffmpegGui.h
//  ffmpegGui
//
//  Created by Sebastian on 17.09.10.
//  Copyright 2010 ICQ: 171680864. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FFmpegGui : NSObject {
@protected
	NSInteger videoWidth;
	NSInteger videoHeight;
	NSInteger videoWidthStd;
	NSInteger videoHeightStd;
	float aspectRatio;
	float aspectRatioStd;
	NSInteger maxRate;
	NSInteger audioBitRate;
	NSInteger audioSRate;
	NSInteger threads;
	NSString * outDirectory;
	NSString * tmpDirectory;
	NSString * inVFile;
	NSString * outVFile;
	NSString * ffmpegApp;
	NSString * videoparApp;
	NSString * logfilePath;
	NSTask *task;
}
@property(assign) NSInteger videoWidth, videoHeight;
@property(readonly) NSInteger videoWidthStd, videoHeightStd, maxRate, audioBitRate, audioSRate, threads;
@property(readonly) NSString* outDirectory;
@property(readonly) NSString* tmpDirectory;
@property(readonly) NSString* ffmpegApp;
@property(readonly) NSString* videoparApp;
@property(readonly) NSString* logfilePath;
@property(retain) NSString* inVFile;
@property(retain) NSString* outVFile;

- (Boolean) transcodeStart;
- (void) dummyTask;
- (void) terminateTask;

@end
