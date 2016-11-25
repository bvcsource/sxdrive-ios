//
//  SKYBackgrounMediaUploadManager.h
//  SXDrive
//
//  Created by Skylable on 7/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKYBackgrounMediaUploadManager : NSObject

+ (SKYBackgrounMediaUploadManager *)manager;

- (void)startUploadWithCompletionHandler:(void(^)(void))handler;
- (void)cancelUpload;

@end
