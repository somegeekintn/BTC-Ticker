//
//  QSBTCTickerController.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCTickerController.h"

@implementation QSBTCTickerController

- (void) awakeFromNib
{
	[super awakeFromNib];

	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(launchComplete:) name: NSApplicationDidBecomeActiveNotification object: nil];
	
	[self reloadTimeColumn];
	[self setSelectionIndexes: [NSIndexSet indexSet]];
}

- (void) reloadTimeColumn
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(){
		NSInteger		updateColumnIndex = [self.tickerTable columnWithIdentifier: @"update"];
		NSRange			rowRange = NSMakeRange(0, [self.arrangedObjects count]);
		
		if (updateColumnIndex != NSNotFound)
			[self.tickerTable reloadDataForRowIndexes: [NSIndexSet indexSetWithIndexesInRange: rowRange] columnIndexes: [NSIndexSet indexSetWithIndex: updateColumnIndex]];
			
		[self reloadTimeColumn];
	});
}

- (void) launchComplete: (NSNotification *) inNotification
{
	[self setSelectionIndexes: [NSIndexSet indexSet]];
}

@end
