//
//  QSBTCMonitor.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@class QSBTCTicker;
@class QSBTCMonitor;

enum {
	eMonitorState_Disconnected = 0,
	eMonitorState_Connecting,
	eMonitorState_Connected
};

@protocol QSBTCMonitorDelegate <NSObject>
@optional
- (void)		monitor: (QSBTCMonitor *) inMonitor
					didUpdateTicker: (QSBTCTicker *) inTicker;
- (void)		monitor: (QSBTCMonitor *) inMonitor
					connectionDidChange: (NSInteger) inConnectionState;

@end

@interface QSBTCMonitor : NSObject <SRWebSocketDelegate>

+ (QSBTCMonitor *)			sharedMonitor;

- (void)					toggleMonitor;
- (void)					beginMonitoring;

@property (nonatomic, weak) id <QSBTCMonitorDelegate>	delegate;
@property (nonatomic, readonly) QSBTCTicker				*ticker;
@property (nonatomic, readonly) NSInteger				connectionState;

@end
