//
//  QSBTCConnection_Coinbase.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConnection_Coinbase.h"
#import "QSBTCService.h"
#import "QSBTCTicker.h"
#import "AFNetworking.h"

@interface QSBTCConnection_Coinbase ()

@property (nonatomic, strong) dispatch_source_t			updateSource;

@end

@implementation QSBTCConnection_Coinbase

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
	
	[manager GET: @"https://coinbase.com/api/v1/prices/spot_rate" parameters: nil success: ^(AFHTTPRequestOperation *inOperation, id inResponseObject) {
		[self updateWithRawAmount: inResponseObject forKey: @"last"];
	} failure: nil];
	[manager GET: @"https://coinbase.com/api/v1/prices/buy" parameters: nil success: ^(AFHTTPRequestOperation *inOperation, id inResponseObject) {
		[self updateWithRawAmount: [inResponseObject objectForKey: @"subtotal"] forKey: @"ask"];
	} failure: nil];
	[manager GET: @"https://coinbase.com/api/v1/prices/sell" parameters: nil success: ^(AFHTTPRequestOperation *inOperation, id inResponseObject) {
		[self updateWithRawAmount: [inResponseObject objectForKey: @"subtotal"] forKey: @"bid"];
	} failure: nil];
}

- (void) updateWithRawAmount: (NSDictionary *) inRawResponse
	forKey: (NSString *) inKey
{
	if (inRawResponse != nil) {
		NSString		*stringValue = [inRawResponse objectForKey: @"amount"];
		
		if (stringValue != nil) {
			[self.service.managedObjectContext performBlock: ^{
				[self.service.ticker setValue: @([stringValue floatValue]) forKey: inKey];
				
				if ([inKey isEqualToString: @"last"])
					self.service.ticker.timestamp = [NSDate date];
			}];
		}
	}
}

@end
