//
//  SKYNetworkManager.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

@protocol SKYNetworkManagerCallback;

/**
 * Protocol of network manager.
 */
@protocol SKYNetworkManager <NSObject>

/**
 * YES if has internet access, no otherwise.
 */
@property (readonly) BOOL hasInternetAccess;

/**
 * Total size of all requests.
 */
@property (nonatomic, readonly) unsigned long long requestsTotalSize;

/**
 * Total size of all responses.
 */
@property (nonatomic, readonly) unsigned long long responsesTotalSize;

/**
 * Adds request to calculate how much data application used (for requests).
 *
 * @param request Request to add to general sum.
 */
- (void)addRequestToRequestsSizeQuota:(NSURLRequest *)request;

/**
 * Adds response to calculate how much data application used (for responses).
 *
 * @param response Response to add to general sum.
 * @param body     Response's body.
 */
- (void)addResponseToResponsesSizeQuota:(NSHTTPURLResponse *)response body:(NSData *)body;

/**
 * Resets statistics.
 */
- (void)resetStatistics;

/**
 * Adds object to be notified when the connection with the server is possible again.
 *
 * @param object Object to be added.
 */
- (void)addObjectToNetworkRestoredCallback:(id <SKYNetworkManagerCallback>)object;

@end

/**
 * Protocol for network manager callback.
 */
@protocol SKYNetworkManagerCallback <NSObject>

/**
 * Called when connection with server is possible again.
 */
- (void)didRestoreConnectionWithServer;

@end
