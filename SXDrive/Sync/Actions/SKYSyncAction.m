//
//  SKYSyncAction.m
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

#import "SKYAppInjector.h"
#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYErrorManager.h"
#import "SKYItem+Extras.h"
#import "SKYNetworkManager.h"
#import "SKYPersistence.h"

@interface SKYSyncAction ()

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) id <SKYCloud> cloud;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) id <SKYErrorManager> errorManager;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

@property (nonatomic) BOOL willCallDelayedProcessErrorWithResponse;

@end

@implementation SKYSyncAction

- (void)startAction
{
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		[self syncDirector];
	});
}

- (id <SKYCloud>)cloud
{
	if (_cloud == nil) {
		_cloud = [SKYAppInjector injectObjectForProtocol:@protocol(SKYCloud)];
		AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
		[_cloud setOperationManager:operationManager];
	}
	
	return _cloud;
}

- (id <SKYErrorManager>)errorManager
{
	if (_errorManager == nil) {
		_errorManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYErrorManager)];
	}
	
	return _errorManager;
}

- (id <SKYPersistence>)persistence
{
	if (_persistence == nil) {
		_persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	}
	
	return _persistence;
}

- (void)syncDirector
{
	
}

- (void)finishAction
{
	
}

- (void)failAction
{
	
}

- (void)cancelAction
{
	self.cancelled = YES;
}

- (void)delayedProcessErrorWithResponse:(SKYCloudResponse *)response
{
	self.willCallDelayedProcessErrorWithResponse = NO;
	
	if (response.connectionError != nil) {
		if (response.connectionError.code == NSURLErrorCancelled) {
			// do nothing
		}
		else if (response.connectionError.code == NSURLErrorTimedOut) {
			[self syncDirector];
		}
		else if (response.connectionError.code == NSURLErrorNotConnectedToInternet || response.connectionError.code == NSURLErrorCannotConnectToHost || response.connectionError.code == NSURLErrorNetworkConnectionLost) {
			if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
					[self syncDirector];
				});
			}
			else {
				id <SKYNetworkManager> networkmanager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYNetworkManager)];
				[networkmanager addObjectToNetworkRestoredCallback:self];
				[self.errorManager displayNoInternetSmartError];
			}
		}
		else {
            NSLog(@"Error code: %ld, HTTP code: %ld", (long)response.connectionError.code, (long)response.statusCode);
            if(response.statusCode == 401)
                [self.errorManager displayInvalidLoginCredentialsError];
            else if(response.statusCode == 403)
                [self.errorManager displayAccessDeniedError];
            else if(response.statusCode == 404)
                [self.errorManager displayNotFoundError];
            else
                [self.errorManager displayInternalError:[NSString stringWithFormat:@"connection error code: %ld, HTTP code: %ld", (long)response.connectionError.code, (long)response.statusCode]];
			[self failAction];
		}
	}
}

- (void)processErrorWithResponse:(SKYCloudResponse *)response
{
	if (self.willCallDelayedProcessErrorWithResponse == NO) {
		self.willCallDelayedProcessErrorWithResponse = YES;
		
		[self performSelector:@selector(delayedProcessErrorWithResponse:) withObject:response afterDelay:0.5];
	}
	[[self.cloud operationManager].operationQueue cancelAllOperations];
}

- (void)didRestoreConnectionWithServer
{
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		[self syncDirector];
	});
}

- (BOOL)isEqual:(SKYSyncAction *)otherSyncAction
{
	if ([otherSyncAction class] == [self class]) {
		if ([self.item.objectID isEqual:otherSyncAction.item.objectID] == YES) {
			return YES;
		}
	}
	
	return [super isEqual:otherSyncAction];
}

@end
