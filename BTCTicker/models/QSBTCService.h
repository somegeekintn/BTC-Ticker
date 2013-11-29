//
//  QSBTCService.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class QSBTCTicker;
@class QSBTCConnection;

enum {
	eServiceStatus_Disconnected = 0,
	eServiceStatus_Connecting,
	eServiceStatus_Connected
};

@interface QSBTCService : NSManagedObject

+ (QSBTCService *)			serviceNamed: (NSString *) inServiceName
								inContext: (NSManagedObjectContext *) inContext;

@property (nonatomic, strong) NSString				*name;
@property (nonatomic, strong) NSNumber				*status;
@property (nonatomic, strong) QSBTCTicker			*ticker;
@property (nonatomic, readonly) QSBTCConnection		*connection;

@end
