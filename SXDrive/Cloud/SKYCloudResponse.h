//
//  SKYCloudResponse.h
//  SXDrive
//
//  Created by Skylable on 18/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import <AFNetworking/AFNetworking.h>

@class SKYCloudResponse;
@class SKYCloudRequest;

/**
 * Cloud response completion block.
 * @param response Response.
 */
typedef void (^SKYCloudResponseCompletionBlock)(SKYCloudResponse *response);

/**
 * Cloud response object.
 */
@interface SKYCloudResponse : NSObject

/**
 * Response's status code.
 */
@property (nonatomic) NSInteger statusCode;

/**
 * Plain response.
 */
@property (nonatomic, readonly) NSHTTPURLResponse *plainResponse;

/**
 * Response data.
 */
@property (nonatomic, readonly) NSData *data;

/**
 * Response serialized to JSON.
 */
@property (nonatomic, readonly) id jsonResponse;

/**
 * JSON response casted to dictionary;
 */
@property (nonatomic, readonly) NSDictionary *jsonDictionary;

/**
 * Connection error.
 */
@property (nonatomic, readonly) NSError *connectionError;

/**
 * Cloud error.
 */
@property (nonatomic, readonly) NSDictionary *cloudError;

/**
 * Returns either connection error or cloud error (whichever is not nil) or nil if no error.
 */
@property (nonatomic, readonly) id error;

/**
 * Clouser ID.
 */
@property (nonatomic, readonly) NSString *clusterID;

/**
 * Used node.
 * @note Can be nil if node wasn't used directly.
 */
@property (nonatomic, readonly) NSString *node;

/**
 * Initializes and processes the request.
 *
 * @param request          Request to process.
 * @param nodes            Nodes to use one by one to check the request.
 * @param operationManager Operation manager on which the request will be executed.
 * @param completion       Completion containing response.
 *
 * @return Initialized object.
 */
+ (void)processWithRequest:(SKYCloudRequest *)request nodes:(NSArray *)nodes operationManager:(AFHTTPRequestOperationManager *)operationManager withCompletion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Returns information if the request was successful or not - due to connection or request error.
 * @return YES if success, NO otherwise.
 */
- (BOOL)success;

@end
