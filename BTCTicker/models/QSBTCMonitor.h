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

@protocol QSBTCMonitorDelegate <NSObject>
@optional

- (void)		tickerDidUpdate: (QSBTCMonitor *) inMonitor;

@end

@interface QSBTCMonitor : NSObject <SRWebSocketDelegate>

+ (QSBTCMonitor *)			sharedMonitor;

- (void)					begingMonitoring;

@property (nonatomic, weak) id <QSBTCMonitorDelegate>	delegate;
@property (nonatomic, readonly) QSBTCTicker				*ticker;

@end
