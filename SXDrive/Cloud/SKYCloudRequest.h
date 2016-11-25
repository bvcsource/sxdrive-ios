//
//  SKYCloudRequest.h
//  SXDrive
//
//  Created by Skylable on 04/12/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

@protocol SKYUser;

/**
 * Cloud request object.
 */
@interface SKYCloudRequest : NSObject

/**
 * Initializes cloud request object.
 *
 * @param path   Path.
 * @param method Method.
 * @param body   Body.
 * @param user   User.
 *
 * @return Initialized cloud request object.
 */
+ (instancetype)requestWithPath:(NSString *)path
						 method:(NSString *)method
						   body:(NSData *)body
						   user:(id <SKYUser>)user;

/**
 * Returns URL request.
 * @return URL request.
 */
- (NSURLRequest *)urlRequest;

/**
 * Returns URL request with given node (it will be used, not host).
 * @param node Node.
 * @return URL request.
 */
- (NSURLRequest *)urlRequestWithNode:(NSString *)node;

@end
