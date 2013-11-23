//
//  QSBTCTickerValue.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSBTCTickerValue : NSObject

- (id)			initWithResponse: (NSDictionary *) inResponse;
- (id)			initWithTradeResponse: (NSDictionary *) inResponse;

- (void)		updateChangeFromValue: (QSBTCTickerValue *) inValue;

@property (nonatomic, readonly) NSString			*currency;
@property (nonatomic, readonly) NSDecimalNumber		*value;
@property (nonatomic, readonly) NSComparisonResult	change;

@end
