//
//  QSBTCTicker.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCTicker.h"
#import "QSBTCTickerValue.h"
#import "QSBTCConsts.h"


@interface QSBTCTicker ()

@property (nonatomic, strong) NSDate				*timestamp;
@property (nonatomic, strong) QSBTCTickerValue		*average;
@property (nonatomic, strong) QSBTCTickerValue		*buy;
@property (nonatomic, strong) QSBTCTickerValue		*high;
@property (nonatomic, strong) QSBTCTickerValue		*last;
@property (nonatomic, strong) QSBTCTickerValue		*lastAll;
@property (nonatomic, strong) QSBTCTickerValue		*lastLocal;
@property (nonatomic, strong) QSBTCTickerValue		*lastOrig;
@property (nonatomic, strong) QSBTCTickerValue		*low;
@property (nonatomic, strong) QSBTCTickerValue		*sell;
@property (nonatomic, strong) QSBTCTickerValue		*volume;
@property (nonatomic, strong) QSBTCTickerValue		*weightedAvg;

@end


@implementation QSBTCTicker

+ (NSDictionary *) responseKeyMap
{
	static NSDictionary		*sValueKeyMap = nil;
	
	if (sValueKeyMap == nil) {
		sValueKeyMap = @{
			@"average"		: QSBTCTickerValueTypeKey_Average,
			@"buy"			: QSBTCTickerValueTypeKey_Buy,
			@"high"			: QSBTCTickerValueTypeKey_High,
			@"last"			: QSBTCTickerValueTypeKey_Last,
			@"lastAll"		: QSBTCTickerValueTypeKey_LastAll,
			@"lastLocal"	: QSBTCTickerValueTypeKey_LastLocal,
			@"lastOrig"		: QSBTCTickerValueTypeKey_LastOrig,
			@"low"			: QSBTCTickerValueTypeKey_Low,
			@"sell"			: QSBTCTickerValueTypeKey_Sell,
			@"volume"		: QSBTCTickerValueTypeKey_Volume,
			@"weightedAvg"	: QSBTCTickerValueTypeKey_VWAP
		};
	}
	
	return sValueKeyMap;
}

- (id) initWithResponse: (NSDictionary *) inResponse
{
	if ((self = [super init]) != nil) {
		[self updateWithTickerResponse: inResponse];
	}
	
	return self;
}

- (void) updateWithTickerResponse: (NSDictionary *) inResponse
{
	NSNumber		*rawTime = [inResponse objectForKey: QSBTCTickerKey_TimeStamp];
	
	if (rawTime != nil)
		self.timestamp = [NSDate dateWithTimeIntervalSince1970: [rawTime doubleValue] / 1000000.0];
	
	[[QSBTCTicker responseKeyMap] enumerateKeysAndObjectsUsingBlock: ^(id inKey, id inObject, BOOL *outStop) {
		NSDictionary	*rawValue = [inResponse objectForKey: inObject];
		
		if (rawValue != nil) {
			QSBTCTickerValue		*tickerValue = [[QSBTCTickerValue alloc] initWithResponse: rawValue];
			
			if (tickerValue != nil) {
				[self setValue: tickerValue forKey: inKey];
			}
		}
	}];
}

- (BOOL) updateWithTradeResponse: (NSDictionary *) inResponse
{
	NSNumber		*rawTime = [inResponse objectForKey: QSBTCTradeKey_TimeStamp];
	BOOL			didUpdate = NO;
	
	if (rawTime != nil) {
		NSDate			*timestamp = [NSDate dateWithTimeIntervalSince1970: [rawTime doubleValue] / 1000000.0];
		
		if (self.timestamp == nil || [self.timestamp compare: timestamp] == NSOrderedAscending) {
			QSBTCTickerValue		*tickerValue = [[QSBTCTickerValue alloc] initWithTradeResponse: inResponse];
			
			self.timestamp = timestamp;
			if (tickerValue != nil) {
				[tickerValue updateChangeFromValue: self.last];
				self.last = tickerValue;
				didUpdate = YES;
			}
		}
	}
	
	return didUpdate;
}

- (void) updateChangesFromTicker: (QSBTCTicker *) inOldTicker
{
	if (inOldTicker != nil) {
		for (NSString *valueKey in [[QSBTCTicker responseKeyMap] allKeys]) {
			QSBTCTickerValue		*thisValue = [self valueForKey: valueKey];
			QSBTCTickerValue		*oldValue = [inOldTicker valueForKey: valueKey];
			
			if (thisValue != nil && oldValue != nil)
				[thisValue updateChangeFromValue: oldValue];
		}
	}
}

@end
