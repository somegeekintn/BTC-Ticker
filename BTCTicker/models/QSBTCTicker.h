//
//  QSBTCTicker.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QSBTCTickerValue;

@interface QSBTCTicker : NSObject

- (id)			initWithResponse: (NSDictionary *) inResponse;

- (BOOL)		updateWithTradeResponse: (NSDictionary *) inResponse;
- (void)		updateChangesFromTicker: (QSBTCTicker *) inOldTicker;

@property (nonatomic, readonly) NSDate					*timestamp;
@property (nonatomic, readonly) QSBTCTickerValue		*average;
@property (nonatomic, readonly) QSBTCTickerValue		*buy;
@property (nonatomic, readonly) QSBTCTickerValue		*high;
@property (nonatomic, readonly) QSBTCTickerValue		*last;
@property (nonatomic, readonly) QSBTCTickerValue		*lastAll;
@property (nonatomic, readonly) QSBTCTickerValue		*lastLocal;
@property (nonatomic, readonly) QSBTCTickerValue		*lastOrig;
@property (nonatomic, readonly) QSBTCTickerValue		*low;
@property (nonatomic, readonly) QSBTCTickerValue		*sell;
@property (nonatomic, readonly) QSBTCTickerValue		*volume;
@property (nonatomic, readonly) QSBTCTickerValue		*weightedAvg;

@end
