//
//  QSBTCMonitor.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCMonitor.h"
#import "QSBTCTicker.h"
#import "QSBTCTickerValue.h"
#import "QSBTCConsts.h"

#define kTickerRetryCount		3


@interface QSBTCMonitor()

@property (nonatomic, strong) SRWebSocket		*webSocket;
@property (nonatomic, strong) NSArray			*messageTypes;
@property (nonatomic, strong) QSBTCTicker		*ticker;
@property (nonatomic, assign) NSInteger			connectionState;
@property (nonatomic, assign) NSInteger			retryCount;

@end


@implementation QSBTCMonitor

+ (QSBTCMonitor *) sharedMonitor
{
	static QSBTCMonitor			*sSharedMonitor = nil;
	static dispatch_once_t		onceToken;
	
	dispatch_once(&onceToken, ^{
		sSharedMonitor = [[QSBTCMonitor alloc] init];
	});
	
	return sSharedMonitor;
}

- (id) init
{
	if ((self = [super init]) != nil) {
		self.connectionState = eMonitorState_Disconnected;
		self.messageTypes = @[QSBTCMessageType_Ticker, QSBTCMessageType_Trade, QSBTCMessageType_Depth];
	}
	
	return self;
}

- (void) toggleMonitor
{
	if (self.connectionState == eMonitorState_Disconnected)
		[self beginMonitoring];
	else
		[self endMonitoring];
}

- (void) beginMonitoring
{
	if (self.connectionState == eMonitorState_Disconnected) {
		NSURLRequest		*webSocketRequest = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: QSBTC_TickerURL]];

		if (webSocketRequest != nil && webSocketRequest.URL != nil) {
			self.webSocket = [[SRWebSocket alloc] initWithURLRequest: webSocketRequest];
			self.webSocket.delegate = self;
			self.connectionState = eMonitorState_Connecting;
			[self.webSocket open];
		}
		else {
			NSLog(@"%s: failed to create request for %@", __PRETTY_FUNCTION__, QSBTC_TickerURL);
		}
	}
}

- (void) endMonitoring
{
	if (self.webSocket != nil) {
		self.connectionState = eMonitorState_Disconnected;
		[self.webSocket close];
		self.webSocket = nil;
	}
}

- (void) handleRawResponse: (NSDictionary *) inRawResponse
{
	NSString		*op = [inRawResponse objectForKey: QSBTCResponseKey_Op];
	
	if (op != nil && [op isEqualToString: QSBTCResponseKey_MessageType]) {
		NSString		*messageType = [inRawResponse objectForKey: QSBTCResponseKey_MessageType];
		
		if (messageType != nil) {
			NSDictionary	*messageData = [inRawResponse objectForKey: messageType];
			NSInteger		messageIndex = [self.messageTypes indexOfObject: messageType];
			
			switch (messageIndex) {
				case eQSBTCMessageType_Ticker:	[self handleRawTicker: messageData];	break;
				case eQSBTCMessageType_Trade:	[self handleRawTrade: messageData];		break;
				case eQSBTCMessageType_Depth:	[self handleRawDepth: messageData];		break;
			}
		}
	}
	// else?
}

- (void) handleRawTicker: (NSDictionary *) inRawTicker
{
	QSBTCTicker		*ticker = [[QSBTCTicker alloc] initWithResponse: inRawTicker];
	
	if (ticker != nil)
		self.ticker = ticker;
}

- (void) handleRawTrade: (NSDictionary *) inRawTrade
{
	if (self.ticker != nil) {
		if ([self.ticker updateWithTradeResponse: inRawTrade])
			[self notifyDelegateOfTickerUpdate];
	}
}

- (void) handleRawDepth: (NSDictionary *) inRawDepth
{
}

- (void) notifyDelegateOfTickerUpdate
{
	if (self.delegate != nil && [self.delegate respondsToSelector: @selector(monitor:didUpdateTicker:)]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate monitor: self didUpdateTicker: self.ticker];
		});
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
	self.connectionState = eMonitorState_Connected;
}

- (void) webSocket: (SRWebSocket *) inWebSocket
	didFailWithError: (NSError *) inError
{
	self.retryCount++;
	if (self.retryCount < kTickerRetryCount) {
		_connectionState = eMonitorState_Disconnected;
		[self beginMonitoring];
	}
}

- (void) webSocket: (SRWebSocket *) inWebSocket
	didCloseWithCode: (NSInteger) inCode
	reason: (NSString *) inReason
	wasClean: (BOOL) inWasClean
{
	NSLog(@"%s: code - %d reason - %@ wasClean - %d", __PRETTY_FUNCTION__, (int32_t)inCode, inReason, inWasClean);
}

#pragma mark - Setters / Getters

- (void) setTicker: (QSBTCTicker *) inTicker
{
	[inTicker updateChangesFromTicker: self.ticker];
	_ticker = inTicker;

	[self notifyDelegateOfTickerUpdate];
}

- (void) setConnectionState: (NSInteger) inConnectionState
{
	if (_connectionState != inConnectionState) {
		_connectionState = inConnectionState;
		if (self.delegate != nil && [self.delegate respondsToSelector: @selector(monitor:connectionDidChange:)]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate monitor: self connectionDidChange: _connectionState];
			});
		}
	}
}

@end
