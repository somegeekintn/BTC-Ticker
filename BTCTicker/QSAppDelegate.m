//
//  QSAppDelegate.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSAppDelegate.h"
#import "QSBTCMonitor.h"
#import "QSBTCTickerController.h"

@implementation QSAppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
	[QSBTCMonitor sharedMonitor].delegate = self.controller;
	[[QSBTCMonitor sharedMonitor] begingMonitoring];
}

@end
