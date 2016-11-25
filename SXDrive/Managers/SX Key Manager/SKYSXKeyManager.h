//
//  SKYSXKeyManager.h
//  SXDrive
//
//  Created by Skylable on 4/17/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKYSXKeyManager : NSObject

+ (SKYSXKeyManager *)manager;

@property (nonatomic, assign) BOOL logEnabled;

- (void)retrieveClusterUUIDForHost:(NSString *)host success:(void (^)(NSString *uuid))success failure:(void (^)(NSString *errorMessage))failure;
- (void)generateKeyForClusterUUID:(NSString *)uuid username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL status, NSString *key))completion;

@end
