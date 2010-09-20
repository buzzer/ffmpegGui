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
	NSInteger videoWidthNew;
	NSInteger videoHeightNew;
	NSInteger videoWidthStd;
	NSInteger videoHeightStd;
	float aspectRatio;
	float aspectRatioStd;
	NSInteger maxRate;
	NSInteger videoBitRate;
	NSInteger audioBitRate;
	NSInteger audioSRate;
	NSInteger audioChannel;
	NSInteger threads;
	NSString * outDirectory;
	NSString * tmpDirectory;
	NSString * inVFile;
	NSString * outVFile;
	NSString * ffmpegApp;
	NSString * videoparApp;
	NSString * logfilePath;
	NSTask *transcodeTask1;
	NSTask *videoparTask;
	NSObject *controllerCB;
}
@property(assign) NSInteger videoWidthNew, videoHeightNew;
@property(readonly) NSInteger videoWidth, videoHeight, videoWidthStd, videoHeightStd;
@property(assign) NSInteger  maxRate, audioBitRate, audioSRate, threads, audioChannel, videoBitRate;
@property(readonly) float aspectRatioStd;
@property(readonly) float aspectRatio;
@property(readonly) NSString* outDirectory;
@property(readonly) NSString* tmpDirectory;
@property(readonly) NSString* ffmpegApp;
@property(readonly) NSString* videoparApp;
@property(readonly) NSString* logfilePath;
@property(copy) NSString* inVFile;
@property(copy) NSString* outVFile;
@property(assign) NSObject* controllerCB;

- (void) startTranscode;
- (void) getVideoPar;
- (void) terminateTransTask;

@end
