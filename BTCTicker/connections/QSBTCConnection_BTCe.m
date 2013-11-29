//
//  QSBTCConnection_BTCe.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConnection_BTCe.h"
#import "QSBTCService.h"
#import "QSBTCTicker.h"
#import "AFNetworking.h"


NSString * const		QSBTCe_TickerKey_Ticker			= @"ticker";
NSString * const		QSBTCe_TickerKey_Last			= @"last";
NSString * const		QSBTCe_TickerKey_Ask			= @"buy";
NSString * const		QSBTCe_TickerKey_Bid			= @"sell";
NSString * const		QSBTCe_TickerKey_Volume			= @"vol_cur";
NSString * const		QSBTCe_TickerKey_Timestamp		= @"server_time";

@interface QSBTCConnection_BTCe ()

@property (nonatomic, strong) dispatch_source_t			updateSource;

@end

@implementation QSBTCConnection_BTCe

- (void) connect
{
	if ([self.service.status integerValue] == eServiceStatus_Disconnected) {
		if (self.updateSource != nil) {
			dispatch_source_cancel(self.updateSource);
			self.updateSource = nil;
		}

		self.updateSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
		dispatch_source_set_timer(self.updateSource, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
		dispatch_source_set_event_handler(self.updateSource, ^() {
			[self updateTicker];
		});
		dispatch_resume(self.updateSource);
		self.service.status = @(eServiceStatus_Connected);
	}
}

- (void) disconnect
{
	if (self.updateSource != nil) {
		dispatch_source_cancel(self.updateSource);
		self.updateSource = nil;
		self.service.status = @(eServiceStatus_Disconnected);
	}
}

- (void) updateTicker
{
	AFHTTPRequestOperationManager		*manager = [AFHTTPRequestOperationManager manager];
	AFHTTPResponseSerializer			*responseSerializer = manager.responseSerializer;
	
	if (![responseSerializer.acceptableContentTypes containsObject: @"text/html"])
		responseSerializer.acceptableContentTypes = [responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];

	[manager GET: @"https://btc-e.com/api/2/btc_usd/ticker" parameters: nil success: ^(AFHTTPRequestOperation *inOperation, id inResponseObject) {
		NSDictionary	*rawTicker = [inResponseObject objectForKey: QSBTCe_TickerKey_Ticker];
		NSNumber		*rawTime = [rawTicker objectForKey: QSBTCe_TickerKey_Timestamp];
		NSNumber		*ask = [rawTicker objectForKey: QSBTCe_TickerKey_Ask];
		NSNumber		*bid = [rawTicker objectForKey: QSBTCe_TickerKey_Bid];
		NSNumber		*last = [rawTicker objectForKey: QSBTCe_TickerKey_Last];
		NSNumber		*volume = [rawTicker objectForKey: QSBTCe_TickerKey_Volume];

		if (rawTime != nil)
			self.service.ticker.timestamp = [NSDate dateWithTimeIntervalSince1970: [rawTime doubleValue]];
		if (ask != nil)
			self.service.ticker.ask = ask;
		if (bid != nil)
			self.service.ticker.bid = bid;
		if (last != nil)
			self.service.ticker.last = last;
		if (volume != nil)
			self.service.ticker.volume = volume;
	} failure: nil];
}

@end
