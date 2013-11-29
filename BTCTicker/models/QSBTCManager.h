//
//  QSBTCManager.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QSBTCManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext		*defaultContext;
@property (nonatomic, strong) IBOutlet NSArrayController	*tickerController;

@end
