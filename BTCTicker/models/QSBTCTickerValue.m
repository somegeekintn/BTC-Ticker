//
//  QSBTCTickerValue.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCTickerValue.h"
#import "QSBTCConsts.h"

@interface QSBTCTickerValue ()

@property (nonatomic, strong) NSString				*currency;
@property (nonatomic, strong) NSDecimalNumber		*value;
@property (nonatomic, assign) NSComparisonResult	change;

@end

@implementation QSBTCTickerValue

- (id) initWithResponse: (NSDictionary *) inResponse
{
	if ((self = [super init]) != nil) {
		[self updateWithTickerResponse: inResponse];
	}
	
	return self;
}

- (id) initWithTradeResponse: (NSDictionary *) inResponse
{
	if ((self = [super init]) != nil) {
		NSString	*tradeCurrency = [inResponse objectForKey: QSBTCTradeKey_Currency];
		
		if (tradeCurrency != nil && [tradeCurrency isEqualToString: @"USD"]) {
			[self updateWithTradeResponse: inResponse];
		}
		else {
			self = nil;
		}
	}
	
	return self;
}

- (void) updateWithTickerResponse: (NSDictionary *) inResponse
{
	NSNumber		*fixedPointValue = [inResponse objectForKey: QSBTCTickerValueKey_ValueInt];
	
	self.currency = [inResponse objectForKey: QSBTCTickerValueKey_Currency];
	self.value = [self decimalValueFromFixedValue: fixedPointValue];
}

- (void) updateWithTradeResponse: (NSDictionary *) inResponse
{
	NSNumber		*fixedPointValue = [inResponse objectForKey: QSBTCTradeKey_PriceInt];

	self.currency = [inResponse objectForKey: QSBTCTradeKey_Currency];
	self.value = [self decimalValueFromFixedValue: fixedPointValue];
}

- (void) updateChangeFromValue: (QSBTCTickerValue *) inValue
{
	self.change = [inValue.value compare: self.value];
}

- (NSDecimalNumber *) decimalValueFromFixedValue: (NSNumber *) inFixedValue
{
	NSDecimalNumber		*decimalNumber = nil;
	
	if (self.currency != nil) {
		long long		mantissa = [inFixedValue longLongValue];
		BOOL			negative = NO;
		
		if (mantissa < 0) {
			mantissa = -mantissa;
			negative = YES;
		}
	
		decimalNumber = [NSDecimalNumber decimalNumberWithMantissa: mantissa exponent: [self currencyExponent] isNegative: negative];
	}
	
	return decimalNumber;
}

- (short) currencyExponent
{
	// See https://en.bitcoin.it/wiki/MtGox/API#Currency_Symbols
	short	exponent = 0;
	
	if (self.currency != nil) {
		if ([self.currency isEqualToString: @"BTC"])
			exponent = -8;
		else if ([self.currency isEqualToString: @"JPY"] || [self.currency isEqualToString: @"SEK"])
			exponent = -3;
		else// if ([self.currency isEqualToString: @"USD"])
			exponent = -5;
	}
	
	return exponent;
}

@end
