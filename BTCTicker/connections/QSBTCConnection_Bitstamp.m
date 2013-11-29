//
//  QSBTCConnection_Bitstamp.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConnection_Bitstamp.h"
#import "QSBTCService.h"
#import "QSBTCTicker.h"

#define kBitRetryCount		3

NSString * const		QSBit_TickerURL						= @"wss://ws.pusherapp.com/app/de504dc5763aeef9ff52?protocol=6&client=js&version=2.1.2&flash=false";

NSString * const		QSBit_ResponseKey_Channel			= @"channel";
NSString * const		QSBit_ResponseKey_Data				= @"data";
NSString * const		QSBit_Channel_Trade					= @"live_trades";
NSString * const		QSBit_Channel_Book					= @"order_book";
NSString * const		QSBit_TradeKey_Price				= @"price";
NSString * const		QSBit_BookKey_Bids					= @"bids";
NSString * const		QSBit_BookKey_Asks					= @"asks";

enum {
	eQSBitChannelType_Trade = 0,
	eQSBitChannelType_Book,
};

@interface QSBTCConnection_Bitstamp ()

@property (nonatomic, strong) SRWebSocket		*webSocket;
@property (nonatomic, strong) NSArray			*channelTypes;
@property (nonatomic, assign) NSInteger			retryCount;

@end

@implementation QSBTCConnection_Bitstamp

- (id) initWithService: (QSBTCService *) inService
{
	if ((self = [super initWithService: inService]) != nil) {
		self.service.status = @(eServiceStatus_Disconnected);
		self.channelTypes = @[QSBit_Channel_Trade, QSBit_Channel_Book];
	}
	
	return self;
}

- (void) connect
{
	if ([self.service.status integerValue] == eServiceStatus_Disconnected) {
		NSURLRequest		*webSocketRequest = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: QSBit_TickerURL]];

		if (webSocketRequest != nil && webSocketRequest.URL != nil) {
			self.webSocket = [[SRWebSocket alloc] initWithURLRequest: webSocketRequest];
			self.webSocket.delegate = self;
			self.service.status = @(eServiceStatus_Connecting);
			[self.webSocket open];
		}
		else {
			NSLog(@"%s: failed to create request for %@", __PRETTY_FUNCTION__, QSBit_TickerURL);
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
	NSString		*channelType = [inRawResponse objectForKey: QSBit_ResponseKey_Channel];
	
	if (channelType != nil) {
		NSString		*dataString = [inRawResponse objectForKey: QSBit_ResponseKey_Data];
		
		if (dataString != nil) {
			NSInteger		channelIndex = [self.channelTypes indexOfObject: channelType];
			NSDictionary	*channelData;
			NSError			*jsonError;
			
			channelData = [NSJSONSerialization JSONObjectWithData: [dataString dataUsingEncoding: NSUTF8StringEncoding] options: 0 error: &jsonError];
			switch (channelIndex) {
				case eQSBitChannelType_Trade:	[self handleRawTrade: channelData];		break;
				case eQSBitChannelType_Book:	[self handleRawBook: channelData];		break;
			}
		}
	}
}

- (void) handleRawTrade: (NSDictionary *) inRawTrade
{
	if (inRawTrade != nil) {
		id		price = [inRawTrade objectForKey: QSBit_TradeKey_Price];
		
		if (price != nil) {
			self.service.ticker.timestamp = [NSDate date];
			self.service.ticker.last = price;
		}
	}
}

- (void) handleRawBook: (NSDictionary *) inRawBook
{
	if (inRawBook != nil) {
		NSArray				*rawPairs;
		
		rawPairs = [inRawBook objectForKey: QSBit_BookKey_Bids];
		if (rawPairs != nil && [rawPairs count]) {
			NSString	*stringValue = [[rawPairs objectAtIndex: 0] objectAtIndex: 0];
			
			if (stringValue != nil)
				self.service.ticker.bid = @([stringValue floatValue]);
		}
		
		rawPairs = [inRawBook objectForKey: QSBit_BookKey_Asks];
		if (rawPairs != nil && [rawPairs count]) {
			NSString	*stringValue = [[rawPairs objectAtIndex: 0] objectAtIndex: 0];
			
			if (stringValue != nil)
				self.service.ticker.ask = @([stringValue floatValue]);
		}
	}
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
	
	[inWebSocket send: @"{\"event\":\"pusher:subscribe\",\"data\":{\"channel\":\"order_book\"}}"];
	[inWebSocket send: @"{\"event\":\"pusher:subscribe\",\"data\":{\"channel\":\"live_trades\"}}"];
}

- (void) webSocket: (SRWebSocket *) inWebSocket
	didFailWithError: (NSError *) inError
{
	self.retryCount++;
	if (self.retryCount < kBitRetryCount) {
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
