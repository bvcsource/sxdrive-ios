//
//  SKYNetworkManagerImplementation.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYNetworkManagerImplementation.h"

#import "SKYNotificationNames.h"

#import <AFNetworking/AFNetworking.h>

/**
 * Name of user defaults entry where total size of requests is stored, holds NSNumber as unsinged long long.
 */
static NSString * const SKYNetworkManagerTotalSizeOfRequestsKey = @"SKYNetworkManagerTotalSizeOfRequestsKey";

/**
 * Name of user defaults entry where total size of responses is stored, holds NSNumber as unsinged long long.
 */
static NSString * const SKYNetworkManagerTotalSizeOfResponsesKey = @"SKYNetworkManagerTotalSizeOfResponsesKey";

@interface SKYNetworkManagerImplementation ()

/**
 * Array containing objects to be notified when network is restored.
 */
@property (nonatomic, strong) NSMutableArray *networkRestoredCallbacks;

/**
 * Increases total size of requests by given size.
 *
 * @param additionalSize Additional size to add.
 */
- (void)increaseTotalSizeOfRequests:(unsigned long long)additionalSize;

/**
 * Increases total size of responses by given size.
 *
 * @param additionalSize Additional size to add.
 */
- (void)increaseTotalSizeOfResponses:(unsigned long long)additionalSize;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic) unsigned long long requestsTotalSize;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic) unsigned long long responsesTotalSize;

@end

@implementation SKYNetworkManagerImplementation

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		__weak typeof(self) weakSelf = self;
		[[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
			
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYNetworkDidChangeStateNotification object:weakSelf];
			
			if ([AFNetworkReachabilityManager sharedManager].isReachable == YES) {
				for (id <SKYNetworkManagerCallback> callback in self.networkRestoredCallbacks) {
					[callback didRestoreConnectionWithServer];
				}
				
				[self.networkRestoredCallbacks removeAllObjects];
			}
		}];
		
		[[AFNetworkReachabilityManager sharedManager] startMonitoring];
	}
	
	return self;
}

- (BOOL)hasInternetAccess
{
	return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (void)addRequestToRequestsSizeQuota:(NSURLRequest *)request
{
	unsigned long long requestSize = 0;
	requestSize += request.URL.absoluteString.length;
	requestSize += request.HTTPMethod.length;
	
	// the following is not perfect, but very close
	requestSize += request.allHTTPHeaderFields.description.length;
	requestSize += request.HTTPBody.length;
	
	[self increaseTotalSizeOfRequests:requestSize];
}

- (void)addResponseToResponsesSizeQuota:(NSHTTPURLResponse *)response body:(NSData *)body
{
	unsigned long long responseSize = 3; // for status code
	responseSize += response.allHeaderFields.description.length;
	responseSize += body.length;
	
	[self increaseTotalSizeOfResponses:responseSize];
}

- (unsigned long long)requestsTotalSize
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:SKYNetworkManagerTotalSizeOfRequestsKey] unsignedLongLongValue];
}

- (void)setRequestsTotalSize:(unsigned long long)requestsTotalSize
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:requestsTotalSize] forKey:SKYNetworkManagerTotalSizeOfRequestsKey];
	[[NSUserDefaults standardUserDefaults] synchronize]; // TODO think about some interval or listen to background and terminate notificatins
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYNetworkUsageDidChangeNotification object:self];
}

- (unsigned long long )responsesTotalSize
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:SKYNetworkManagerTotalSizeOfResponsesKey] unsignedLongLongValue];
}

- (void)setResponsesTotalSize:(unsigned long long)responsesTotalSize
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:responsesTotalSize] forKey:SKYNetworkManagerTotalSizeOfResponsesKey];
	[[NSUserDefaults standardUserDefaults] synchronize]; // TODO think about some interval or listen to background and terminate notificatins
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYNetworkUsageDidChangeNotification object:self];
}

- (void)increaseTotalSizeOfRequests:(unsigned long long)additionalSize
{
	@synchronized(self) {
		self.requestsTotalSize += additionalSize;
	}
}

- (void)increaseTotalSizeOfResponses:(unsigned long long)additionalSize
{
	@synchronized(self) {
		self.responsesTotalSize += additionalSize;
	}
}

- (void)resetStatistics
{
	self.requestsTotalSize = 0;
	self.responsesTotalSize = 0;
}

- (void)addObjectToNetworkRestoredCallback:(id <SKYNetworkManagerCallback>)object
{
	if ([self.networkRestoredCallbacks containsObject:object] == NO) {
		[self.networkRestoredCallbacks addObject:object];
	}
}

- (NSMutableArray *)networkRestoredCallbacks
{
	if (_networkRestoredCallbacks == nil) {
		_networkRestoredCallbacks = [NSMutableArray array];
	}
	
	return _networkRestoredCallbacks;
}

@end
