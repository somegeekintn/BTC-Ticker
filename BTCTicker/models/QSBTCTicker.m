//
//  QSBTCTicker.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCTicker.h"
#import "QSBTCService.h"


@implementation QSBTCTicker

@dynamic ask;
@dynamic askChange;
@dynamic bid;
@dynamic bidChange;
@dynamic last;
@dynamic lastChange;
@dynamic volume;
@dynamic timestamp;
@dynamic service;

- (void) changeTickerValue: (NSNumber *) inValue
	forKey: (NSString *) inValueKey
{
	NSNumber	*oldValue = [self valueForKey: inValueKey];
	
	if (oldValue != nil) {
		NSNumber		*change = @([oldValue compare: inValue]);
		
		[self setValue: change forKey: [inValueKey stringByAppendingString: @"Change"]];
	}

	[self willChangeValueForKey: inValueKey];
	[self setPrimitiveValue: inValue forKey: inValueKey];
	[self didChangeValueForKey: inValueKey];
}

- (void) setAsk: (NSNumber *) inAsk
{
	[self changeTickerValue: inAsk forKey: @"ask"];
}

- (void) setBid: (NSNumber *) inBid
{
	[self changeTickerValue: inBid forKey: @"bid"];
}

- (void) setLast: (NSNumber *) inLast
{
	[self changeTickerValue: inLast forKey: @"last"];
}

@end
