//
//  QSBTCStatusView.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// mirrors QSBTCMonitor's connection state as it happens

enum {
	eBTCStatus_Bad = 0,
	eBTCStatus_Okay,
	eBTCStatus_Good
};

@interface QSBTCStatusView : NSView

@property (nonatomic, assign) NSInteger		status;

@end
