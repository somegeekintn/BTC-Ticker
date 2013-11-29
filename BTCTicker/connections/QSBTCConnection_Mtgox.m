//
//  QSBTCConnection_Mtgox.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConnection_Mtgox.h"
#import "QSBTCService.h"
#import "QSBTCTicker.h"


#define kGOXRetryCount		3

NSString * const		QSGOX_TickerURL						= @"http://websocket.mtgox.com:80/mtgox?Currency=USD";

NSString * const		QSGOX_ResponseKey_Op				= @"op";
NSString * const		QSGOX_ResponseKey_MessageType		= @"private";
NSString * const		QSGOX_MessageType_Ticker				= @"ticker";
NSString * const		QSGOX_MessageType_Trade					= @"trade";
NSString * const		QSGOX_MessageType_Depth					= @"depth";
NSString * const		QSGOX_TickerKey_TimeStamp			= @"now";
NSString * const		QSGOX_TickerValueKey_Currency		= @"currency";
NSString * const		QSGOX_TickerValueKey_ValueInt		= @"value_int";		// note: value deprecated, use value_int
NSString * const		QSGOX_TickerValueTypeKey_Average	= @"avg";
NSString * const		QSGOX_TickerValueTypeKey_Buy		= @"buy";
NSString * const		QSGOX_TickerValueTypeKey_High		= @"high";
NSString * const		QSGOX_TickerValueTypeKey_Last		= @"last";
NSString * const		QSGOX_TickerValueTypeKey_LastAll	= @"last_all";
NSString * const		QSGOX_TickerValueTypeKey_LastLocal	= @"last_local";
NSString * const		QSGOX_TickerValueTypeKey_LastOrig	= @"last_orig";
NSString * const		QSGOX_TickerValueTypeKey_Low		= @"low";
NSString * const		QSGOX_TickerValueTypeKey_Sell		= @"sell";
NSString * const		QSGOX_TickerValueTypeKey_Volume		= @"vol";
NSString * const		QSGOX_TickerValueTypeKey_VWAP		= @"vwap";
NSString * const		QSGOX_TradeKey_Currency				= @"price_currency";
NSString * const		QSGOX_TradeKey_TimeStamp			= @"tid";
NSString * const		QSGOX_TradeKey_PriceInt				= @"price_int";

enum {
	eQSGOXMessageType_Ticker = 0,
	eQSGOXMessageType_Trade,
	eQSGOXMessageType_Depth,
};

@interface QSBTCConnection_Mtgox ()

@property (nonatomic, strong) SRWebSocket		*webSocket;
@property (nonatomic, strong) NSArray			*messageTypes;
@property (nonatomic, assign) NSInteger			retryCount;

@end

@implementation QSBTCConnection_Mtgox

+ (NSDictionary *) responseKeyMap
{
	static NSDictionary		*sValueKeyMap = nil;
	
	if (sValueKeyMap == nil) {
		sValueKeyMap = @{
			@"ask"			: QSGOX_TickerValueTypeKey_Sell,
			@"bid"			: QSGOX_TickerValueTypeKey_Buy,
			@"last"			: QSGOX_TickerValueTypeKey_Last,
			@"volume"		: QSGOX_TickerValueTypeKey_Volume,
		};
	}
	
	return sValueKeyMap;
}

- (id) initWithService: (QSBTCService *) inService
{
	if ((self = [super initWithService: inService]) != nil) {
		self.messageTypes = @[QSGOX_MessageType_Ticker, QSGOX_MessageType_Trade, QSGOX_MessageType_Depth];
	}
	
	return self;
}

- (void) connect
{
	if ([self.service.status integerValue] == eServiceStatus_Disconnected) {
		NSURLRequest		*webSocketRequest = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: QSGOX_TickerURL]];

		if (webSocketRequest != nil && webSocketRequest.URL != nil) {
			self.webSocket = [[SRWebSocket alloc] initWithURLRequest: webSocketRequest];
			self.webSocket.delegate = self;
			self.service.status = @(eServiceStatus_Connecting);
			[self.webSocket open];
		}
		else {
			NSLog(@"%s: failed to create request for %@", __PRETTY_FUNCTION__, QSGOX_TickerURL);
		}
	}
}

- (void) disconnect
{
	if (self.webSocket != nil) {
		self.service.status = @(eServiceStatus_Disconnected);
		[self.webSocket close];
		self.webSocket = nil;
	}
}

- (void) handleRawResponse: (NSDictionary *) inRawResponse
{
	NSString		*op = [inRawResponse objectForKey: QSGOX_ResponseKey_Op];
	
	if (op != nil && [op isEqualToString: QSGOX_ResponseKey_MessageType]) {
		NSString		*messageType = [inRawResponse objectForKey: QSGOX_ResponseKey_MessageType];
		
		if (messageType != nil) {
			NSDictionary	*messageData = [inRawResponse objectForKey: messageType];
			NSInteger		messageIndex = [self.messageTypes indexOfObject: messageType];
			
			switch (messageIndex) {
				case eQSGOXMessageType_Ticker:	[self handleRawTicker: messageData];	break;
				case eQSGOXMessageType_Trade:	[self handleRawTrade: messageData];		break;
				case eQSGOXMessageType_Depth:	[self handleRawDepth: messageData];		break;
			}
		}
	}
	// else?
}

- (void) handleRawTicker: (NSDictionary *) inRawTicker
{
	NSNumber		*rawTime = [inRawTicker objectForKey: QSGOX_TickerKey_TimeStamp];
	
	if (rawTime != nil)
		self.service.ticker.timestamp = [NSDate dateWithTimeIntervalSince1970: [rawTime doubleValue] / 1000000.0];

	[[QSBTCConnection_Mtgox responseKeyMap] enumerateKeysAndObjectsUsingBlock: ^(id inKey, id inObject, BOOL *outStop) {
		NSDictionary	*rawValue = [inRawTicker objectForKey: inObject];
		
		if (rawValue != nil) {
			NSNumber		*fixedPointValue = [rawValue objectForKey: QSGOX_TickerValueKey_ValueInt];
			NSString		*currency = [rawValue objectForKey: QSGOX_TickerValueKey_Currency];
			NSNumber		*value;
			
			if ((value = [self decimalValueFromFixedValue: fixedPointValue andCurrency: currency]) != nil) {
				[self.service.ticker setValue: value forKey: inKey];
			}
		}
	}];
}

- (void) handleRawTrade: (NSDictionary *) inRawTrade
{
	NSNumber		*rawTime = [inRawTrade objectForKey: QSGOX_TradeKey_TimeStamp];
	
	if (rawTime != nil) {
		NSDate			*timestamp = [NSDate dateWithTimeIntervalSince1970: [rawTime doubleValue] / 1000000.0];
		NSDate			*lastTime = self.service.ticker.timestamp;
		
		if (lastTime == nil || [lastTime compare: timestamp] == NSOrderedAscending) {
			NSString		*currency = [inRawTrade objectForKey: QSGOX_TradeKey_Currency];

			self.service.ticker.timestamp = timestamp;
			if (currency != nil && [currency isEqualToString: @"USD"]) {
				NSNumber		*fixedPointValue = [inRawTrade objectForKey: QSGOX_TradeKey_PriceInt];
				NSNumber		*value;
				if ((value = [self decimalValueFromFixedValue: fixedPointValue andCurrency: currency]) != nil) {
					self.service.ticker.last = value;
				}
			}
		}
	}
}

- (void) handleRawDepth: (NSDictionary *) inRawDepth
{
}

- (NSDecimalNumber *) decimalValueFromFixedValue: (NSNumber *) inFixedValue
	andCurrency: (NSString *) inCurrency
{
	NSDecimalNumber		*decimalNumber = nil;
	
	if (inCurrency != nil) {
		long long		mantissa = [inFixedValue longLongValue];
		short			exponent = 0;
		BOOL			negative = NO;
		
		if (mantissa < 0) {
			mantissa = -mantissa;
			negative = YES;
		}
	
		if (inCurrency != nil) {
			if ([inCurrency isEqualToString: @"BTC"])
				exponent = -8;
			else if ([inCurrency isEqualToString: @"JPY"] || [inCurrency isEqualToString: @"SEK"])
				exponent = -3;
			else// if ([inCurrency isEqualToString: @"USD"])
				exponent = -5;
		}
	
		decimalNumber = [NSDecimalNumber decimalNumberWithMantissa: mantissa exponent: exponent isNegative: negative];
	}
	
	return decimalNumber;
}

#pragma mark - SRWebSocketDelegate

- (void) webSocket: (SRWebSocket *) inWebSocket
	didReceiveMessage: (id) inMessage
{
	NSData			*messageData = [inMessage dataUsingEncoding: NSUTF8StringEncoding];
	NSError			*jsonError;
	id				jsonResponse = [NSJSONSerialization JSONObjectWithData: messageData options: 0 error: &jsonError];
	
	if (jsonResponse != nil) {
		[self handleRawResponse: jsonResponse];
	}
	else {
		NSLog(@"%s: unable to interpret response - %@\nError: %@", __PRETTY_FUNCTION__, inMessage, jsonError);
	}
}

- (void) webSocketDidOpen: (SRWebSocket *) inWebSocket
{
	self.retryCount = 0;
	self.service.status = @(eServiceStatus_Connected);
}

- (void) webSocket: (SRWebSocket *) inWebSocket
	didFailWithError: (NSError *) inError
{
	self.retryCount++;
	if (self.retryCount < kGOXRetryCount) {
		self.service.status = @(eServiceStatus_Disconnected);
		[self connect];
	}
}

- (void) webSocket: (SRWebSocket *) inWebSocket
	didCloseWithCode: (NSInteger) inCode
	reason: (NSString *) inReason
	wasClean: (BOOL) inWasClean
{
	NSLog(@"%s: code - %d reason - %@ wasClean - %d", __PRETTY_FUNCTION__, (int32_t)inCode, inReason, inWasClean);
}

@end
