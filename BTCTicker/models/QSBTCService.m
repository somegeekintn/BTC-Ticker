//
//  QSBTCService.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCService.h"
#import "QSBTCTicker.h"
#import "QSBTCConnection_Bitstamp.h"
#import "QSBTCConnection_BTCe.h"
#import "QSBTCConnection_Coinbase.h"
#import "QSBTCConnection_Mtgox.h"


@implementation QSBTCService

@dynamic name;
@dynamic status;
@dynamic ticker;
@synthesize connection = _connection;

+ (QSBTCService *) serviceNamed: (NSString *) inServiceName
	inContext: (NSManagedObjectContext *) inContext
{
	NSFetchRequest		*request = [NSFetchRequest fetchRequestWithEntityName: @"Service"];
	NSArray				*results;
	QSBTCService		*service = nil;
	
	request.predicate = [NSPredicate predicateWithFormat: @"name == %@", inServiceName];
	if ((results = [inContext executeFetchRequest: request error: nil]) != nil) {
		service = [results lastObject];
	}
	
	if (service == nil) {
		service = [NSEntityDescription insertNewObjectForEntityForName: @"Service" inManagedObjectContext: inContext];
		service.name = inServiceName;
		service.ticker = [NSEntityDescription insertNewObjectForEntityForName: @"Ticker" inManagedObjectContext: inContext];
		
		[service createServiceConnection];
	}
	
	return service;
}

- (void) awakeFromFetch
{
	[super awakeFromFetch];

	[self createServiceConnection];
}

- (void) createServiceConnection
{
	if ([self.name isEqualToString: @"mtgox"])
		_connection = [[QSBTCConnection_Mtgox alloc] initWithService: self];
	else if ([self.name isEqualToString: @"coinbase"])
		_connection = [[QSBTCConnection_Coinbase alloc] initWithService: self];
	else if ([self.name isEqualToString: @"bitstamp"])
		_connection = [[QSBTCConnection_Bitstamp alloc] initWithService: self];
	else if ([self.name isEqualToString: @"btc-e"])
		_connection = [[QSBTCConnection_BTCe alloc] initWithService: self];
}

@end
