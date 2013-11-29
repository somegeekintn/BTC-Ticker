//
//  QSBTCManager.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCManager.h"
#import "QSBTCService.h"

@interface QSBTCManager ()

@property (nonatomic, strong) NSManagedObjectModel			*managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator	*persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext		*rootContext;

@end

@implementation QSBTCManager

@synthesize defaultContext = _defaultContext;

- (id) init
{
	if ((self = [super init]) != nil) {
		[QSBTCService serviceNamed: @"bitstamp" inContext: self.defaultContext];
		[QSBTCService serviceNamed: @"btc-e" inContext: self.defaultContext];
		[QSBTCService serviceNamed: @"coinbase" inContext: self.defaultContext];
		[QSBTCService serviceNamed: @"mtgox" inContext: self.defaultContext];

		[self saveObjectsAsync: NO];
	}
	
	return self;
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	self.tickerController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES]];
}

- (NSManagedObjectContext *) defaultContext
{
	if (_defaultContext == nil) {
		NSPersistentStoreCoordinator	*coordinator = self.persistentStoreCoordinator;
		
		if (coordinator != nil) {
			self.rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
			self.rootContext.persistentStoreCoordinator = coordinator;
			_defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
			_defaultContext.parentContext = self.rootContext;
		}
	}

    return _defaultContext;
}

- (NSManagedObjectModel *) managedObjectModel
{

    if (_managedObjectModel == nil) {
		NSURL		*modelURL = [[NSBundle mainBundle] URLForResource: @"QSBTCModel" withExtension: @"momd"];

		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    }
	
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
		NSURL		*storeURL = [self persistentStoreURL];
		NSError		*cdError;
		
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
		if (![_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL
				options: @{ NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES } error: &cdError]) {
			NSURL		*movedStoreURL = [storeURL URLByAppendingPathExtension: @"bad"];
			
			NSLog(@"Core Data: Error %@, %@", cdError, [cdError userInfo]);
			NSLog(@"Will move old store and create new");
			
			[[NSFileManager defaultManager] removeItemAtURL: movedStoreURL error: nil];
			if (![[NSFileManager defaultManager] moveItemAtURL: storeURL toURL: movedStoreURL error: &cdError]) {
				NSLog(@"Failed with %@ trying to move %@ to %@", cdError, storeURL, movedStoreURL);
			}
			else if (![_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL
				options: @{ NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES } error: &cdError]) {
				NSLog(@"Core Data: removed old store but still...");
				NSLog(@"Core Data: Error %@, %@", cdError, [cdError userInfo]);
			}
		}
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *) documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject];
}

- (NSURL *) persistentStoreURL
{
	NSURL		*appSupportURL = [[self documentsDirectory] URLByAppendingPathComponent: @"BTC Ticker" isDirectory: YES];
	
	[[NSFileManager defaultManager] createDirectoryAtURL: appSupportURL withIntermediateDirectories: YES attributes: nil error: nil];
	
	return [appSupportURL URLByAppendingPathComponent: @"btcticker.sqlite"];
}

- (BOOL) persistentStoreExists
{
	return [[NSFileManager defaultManager] fileExistsAtPath: [[self persistentStoreURL] path]];
}

- (void) saveObjectsAsync: (BOOL) inAsync
{
    NSManagedObjectContext	*managedObjectContext = self.defaultContext;

	if (managedObjectContext != nil) {
		[managedObjectContext performBlockAndWait: ^() {
			if ([managedObjectContext hasChanges]) {
				NSError			*childError = nil;
				void			(^saveBlock)(void);
				
				if (![managedObjectContext save: &childError]) {
					[self handleCoreDataError: childError withMessage: @"Error saving default context"];
				}
				
				saveBlock = ^() {
					NSError			*rootError = nil;
					
					if (![self.rootContext save: &rootError]) {
						[self handleCoreDataError: rootError withMessage: @"Error saving root context"];
					}
				};
				
				if (inAsync)
					[self.rootContext performBlock: saveBlock];
				else
					[self.rootContext performBlockAndWait: saveBlock];
			}
		}];
	}
}

- (void) handleCoreDataError: (NSError *) inError
	withMessage: (NSString *) inMessage
{
	NSDictionary		*errorInfo = [inError userInfo];
	
	if (inMessage != nil)
		NSLog(@"%@", inMessage);
	
	switch (inError.code) {
		case NSManagedObjectValidationError: {
				NSString			*validationObject = [errorInfo objectForKey: NSValidationObjectErrorKey];
				NSString			*validationKey = [errorInfo objectForKey: NSValidationKeyErrorKey];

				NSLog(@"%@ failed validation for %@", NSStringFromClass([validationObject class]), validationKey);
			}
			break;
		
		case NSValidationMissingMandatoryPropertyError: {
				NSString			*validationObject = [errorInfo objectForKey: NSValidationObjectErrorKey];
				NSString			*validationKey = [errorInfo objectForKey: NSValidationKeyErrorKey];

				NSLog(@"%@ missing mandatory property: %@", NSStringFromClass([validationObject class]), validationKey);
			}
			break;
		
		case NSValidationMultipleErrorsError:
			for (NSError *subError in [[inError userInfo] objectForKey: NSDetailedErrorsKey])
				[self handleCoreDataError: subError withMessage: nil];
			break;
		
		default:
			NSLog(@"error: %@", inError);
			break;
	}
}

@end
