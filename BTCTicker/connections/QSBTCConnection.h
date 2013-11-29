//
//  QSBTCConnection.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>


@class QSBTCService;

@interface QSBTCConnection : NSObject

- (id)						initWithService: (QSBTCService *) inService;

- (void)					connect;
- (void)					disconnect;

@property (nonatomic, readonly) QSBTCService			*service;

@end
