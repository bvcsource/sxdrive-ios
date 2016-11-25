//
//  SKYAppInjector.m
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYAppInjector.h"

#import "SKYBigTransfersManagerImplementation.h"
#import "SKYCloudImplementation.h"
#import "SKYDiskManagerImplementation.h"
#import "SKYErrorManagerImplementation.h"
#import "SKYInfoKeys.h"
#import "SKYNavigationController.h"
#import "SKYNetworkManagerImplementation.h"
#import "SKYPersistenceImplementation.h"
#import "SKYSyncServiceImplementation.h"
#import "SKYUserImplementation.h"
#import "SKYViewControllerFactoryImplementation.h"
#import "SKYViewNavigatorImplementation.h"

@implementation SKYAppInjector

+ (id)injectObjectForProtocol:(Protocol *)protocol
{
	return [self injectObjectForProtocol:protocol info:nil];
}

+ (id)injectObjectForProtocol:(Protocol *)protocol info:(NSDictionary *)info
{
	if (protocol == @protocol(SKYViewControllerFactory)) {
		return [SKYViewControllerFactoryImplementation new];
	}
	else if (protocol == @protocol(SKYViewNavigator)) {
		
		static dispatch_once_t onceToken;
		static id <SKYViewNavigator> viewNavigator;
		dispatch_once(&onceToken, ^{
			NSAssert(info[SKYInfoKeyForApplicationMainWindow] != nil, @"Info key must contain SKYInfoKeyForApplicationMainWindow");
			
			id <SKYViewControllerFactory> controllerFactory = [self injectObjectForProtocol:@protocol(SKYViewControllerFactory)];
			viewNavigator = [[SKYViewNavigatorImplementation alloc] initWithViewControllerFactory:controllerFactory applicationWindow:info[SKYInfoKeyForApplicationMainWindow]];
		});

		return viewNavigator;
	}
	else if (protocol == @protocol(SKYCloud)) {
		// Cloud should not be a singleton!
		
		id <SKYCloud> cloud = [[SKYCloudImplementation alloc] init];
		
		return cloud;
	}
	else if (protocol == @protocol(SKYPersistence)) {
		static dispatch_once_t onceToken;
		static id <SKYPersistence> persistnence;
		dispatch_once(&onceToken, ^{
			persistnence = [[SKYPersistenceImplementation alloc] init];
		});
		
		return persistnence;
	}
	else if (protocol == @protocol(SKYSyncService)) {
		static dispatch_once_t onceToken;
		static id <SKYSyncService> syncService;
		dispatch_once(&onceToken, ^{
			syncService = [[SKYSyncServiceImplementation alloc] init];
		});
		
		return syncService;
	}
	else if (protocol == @protocol(SKYUser)) {
		static dispatch_once_t onceToken;
		static id <SKYUser> user;
		dispatch_once(&onceToken, ^{
			user = [[SKYUserImplementation alloc] init];
		});
		
		return user;
	}
	else if (protocol == @protocol(SKYNetworkManager)) {
		static dispatch_once_t onceToken;
		static id <SKYNetworkManager> networkManager;
		dispatch_once(&onceToken, ^{
			networkManager = [[SKYNetworkManagerImplementation alloc] init];
		});
		
		return networkManager;
	}
	else if (protocol == @protocol(SKYErrorManager)) {
		static dispatch_once_t onceToken;
		static id <SKYErrorManager> errorManager;
		dispatch_once(&onceToken, ^{
			errorManager = [[SKYErrorManagerImplementation alloc] init];
		});
		
		return errorManager;
	}
	else if (protocol == @protocol(SKYDiskManager)) {
		static dispatch_once_t onceToken;
		static id <SKYDiskManager> diskManager;
		dispatch_once(&onceToken, ^{
			diskManager = [SKYDiskManagerImplementation new];
		});
		
		return diskManager;
	}
	else if (protocol == @protocol(SKYBigTransfersManager)) {
		static dispatch_once_t onceToken;
		static id <SKYBigTransfersManager> bigTransfersManager;
		dispatch_once(&onceToken, ^{
			bigTransfersManager = [SKYBigTransfersManagerImplementation new];
		});
		
		return bigTransfersManager;
	}
	else {
		NSAssert(NO, @"SKYAppInjector cannot inject this protocol.");
	}
	
	return nil;
}

@end
