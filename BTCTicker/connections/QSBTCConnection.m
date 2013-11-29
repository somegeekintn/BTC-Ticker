//
//  QSBTCConnection.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConnection.h"
#import "QSBTCService.h"

@implementation QSBTCConnection

- (id) initWithService: (QSBTCService *) inService
{
	if ((self = [super init]) != nil) {
		_service = inService;
		
		self.service.status = @(eServiceStatus_Disconnected);
		[self connect];
	}
	
	return self;
}

- (void) connect
{
	NSLog(@"%@ does not know how to connect", NSStringFromClass([self class]));
}

- (void) disconnect
{
	NSLog(@"%@ does not know how to disconnect", NSStringFromClass([self class]));
}

@end
