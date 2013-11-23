//
//  QSBTCTickerController.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCTickerController.h"
#import "QSBTCTicker.h"
#import "QSBTCTickerValue.h"
#import "QSBTCMonitor.h"

@interface QSBTCTickerController ()

@property (nonatomic, strong) NSDate				*lastUpdate;
@property (nonatomic, strong) dispatch_source_t		statusUpdateSource;
@property (nonatomic, weak) IBOutlet NSTextField	*lastPrice;
@property (nonatomic, weak) IBOutlet NSTextField	*status;
@property (nonatomic, weak) IBOutlet NSTextField	*buyPrice;
@property (nonatomic, weak) IBOutlet NSTextField	*sellPrice;

@end

@implementation QSBTCTickerController

#pragma mark - QSBTCMonitorDelegate

- (void) awakeFromNib
{
	[self updateStatus];
}

- (NSColor *) colorForValueChange: (QSBTCTickerValue *) inValue
{
	NSColor		*changeColor = nil;
	
	switch (inValue.change) {
		case NSOrderedSame:			changeColor = [NSColor whiteColor];	break;
		case NSOrderedAscending:	changeColor = [NSColor greenColor];	break;
		case NSOrderedDescending:	changeColor = [NSColor redColor];	break;
	}
	
	return changeColor;
}

- (void) tickerDidUpdate: (QSBTCMonitor *) inMonitor
{
	QSBTCTicker		*ticker = inMonitor.ticker;
	
	[self.lastPrice setObjectValue: ticker.last.value];
	[self.lastPrice setTextColor: [self colorForValueChange: ticker.last]];
	[self.buyPrice setObjectValue: ticker.buy.value];
	[self.buyPrice setTextColor: [self colorForValueChange: ticker.buy]];
	[self.sellPrice setObjectValue: ticker.sell.value];
	[self.sellPrice setTextColor: [self colorForValueChange: ticker.sell]];
	
	self.lastUpdate = inMonitor.ticker.timestamp;
}

- (void) updateStatus
{
	if (self.lastUpdate != nil) {
		NSTimeInterval	secondsSinceUpdate = -[self.lastUpdate timeIntervalSinceNow];
		
		[self.status setStringValue: [NSString stringWithFormat: @"updated: %2.2fs ago", secondsSinceUpdate]];
	}
	else {
		[self.status setStringValue: @"connecting…"];	// possibly a lie...
	}
}

#pragma mark - Getters / Setters

- (void) setLastUpdate: (NSDate *) inLastUpdate
{
	_lastUpdate = inLastUpdate;
	[self updateStatus];
	
	// perhaps a bit heavy handed...
	if (self.statusUpdateSource != nil) {
		dispatch_source_cancel(self.statusUpdateSource);
		self.statusUpdateSource = nil;
	}
	if (_lastUpdate != nil) {
		self.statusUpdateSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
		dispatch_source_set_timer(self.statusUpdateSource, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
		dispatch_source_set_event_handler(self.statusUpdateSource, ^() {
			[self updateStatus];
		});
		dispatch_resume(self.statusUpdateSource);
	}
}

@end
