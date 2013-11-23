//
//  QSAppDelegate.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QSBTCTickerController;

@interface QSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow				*window;
@property (assign) IBOutlet QSBTCTickerController	*controller;

@end
