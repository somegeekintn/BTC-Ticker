//
//  QSBTCTicker.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QSBTCService;

@interface QSBTCTicker : NSManagedObject

@property (nonatomic, strong) NSNumber		*ask;
@property (nonatomic, strong) NSNumber		*askChange;
@property (nonatomic, strong) NSNumber		*bid;
@property (nonatomic, strong) NSNumber		*bidChange;
@property (nonatomic, strong) NSNumber		*last;
@property (nonatomic, strong) NSNumber		*lastChange;
@property (nonatomic, strong) NSNumber		*volume;
@property (nonatomic, strong) NSDate		*timestamp;
@property (nonatomic, strong) QSBTCService	*service;

@end
