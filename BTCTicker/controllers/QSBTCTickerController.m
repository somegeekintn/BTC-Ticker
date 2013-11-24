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
#import "QSBTCStatusView.h"

@interface QSBTCTickerController ()

@property (nonatomic, strong) NSDate					*lastUpdate;
@property (nonatomic, strong) dispatch_source_t			statusUpdateSource;
@property (nonatomic, weak) IBOutlet NSTextField		*lastPrice;
@property (nonatomic, weak) IBOutlet NSTextField		*btcVolume;
@property (nonatomic, weak) IBOutlet NSTextField		*status;
@property (nonatomic, weak) IBOutlet NSTextField		*buyPrice;
@property (nonatomic, weak) IBOutlet NSTextField		*sellPrice;
@property (nonatomic, weak) IBOutlet NSMenuItem			*connectItem;
@property (nonatomic, weak) IBOutlet QSBTCStatusView	*statusView;

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

- (void) monitor: (QSBTCMonitor *) inMonitor
	didUpdateTicker: (QSBTCTicker *) inTicker
{
	[self.lastPrice setObjectValue: inTicker.last.value];
	[self.lastPrice setTextColor: [self colorForValueChange: inTicker.last]];
	[self.buyPrice setObjectValue: inTicker.buy.value];
	[self.buyPrice setTextColor: [self colorForValueChange: inTicker.buy]];
	[self.sellPrice setObjectValue: inTicker.sell.value];
	[self.sellPrice setTextColor: [self colorForValueChange: inTicker.sell]];
	[self.btcVolume setObjectValue: inTicker.volume.value];
	
	self.lastUpdate = inTicker.timestamp;
}

- (void) monitor: (QSBTCMonitor *) inMonitor
	connectionDidChange: (NSInteger) inConnectionState
{
	self.statusView.status = inConnectionState;
	[self.connectItem setTitle: inConnectionState == eMonitorState_Disconnected ? @"Connect" : @"Disconnect"];

	switch (inConnectionState) {
		case eMonitorState_Disconnected: {
				dispatch_source_cancel(self.statusUpdateSource);
				self.statusUpdateSource = nil;
				[self.status setStringValue: @"disconnected"];
			}
			break;
		
		case eMonitorState_Connecting:
			[self.status setStringValue: @"connecting…"];
			break;
			
		case eMonitorState_Connected:
			[self.status setStringValue: @"connected"];
			break;
	}
}

- (void) updateStatus
{
	if (self.lastUpdate != nil) {
		NSTimeInterval	secondsSinceUpdate = -[self.lastUpdate timeIntervalSinceNow];
		
		[self.status setStringValue: [NSString stringWithFormat: @"updated: %2.2fs ago", secondsSinceUpdate]];
	}
}

#pragma mark - Handlers

- (void) handleConnectionToggle: (id) inSender
{
	[[QSBTCMonitor sharedMonitor] toggleMonitor];
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
