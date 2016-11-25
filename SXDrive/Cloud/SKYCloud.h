//
//  SKYCloud.h
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import <AFNetworking/AFNetworking.h>

#import "SKYCloudResponse.h"

/**
 * Protocol of cloud.
 */
@protocol SKYCloud <NSObject>

/**
 * Cluster's UDID. Assigned after successful response.
 */
@property (nonatomic, readonly) NSString *clusterID;

/**
 * Operation manager on which all the requests are performed.
 * By default shared instance of AFHTTPRequestOperationManager.
 * Useful if operation takes multiple requests and in case of error should cancel them.
 */
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

/**
 * Lists nodes.
 * @param completion Completion block.
 */
- (void)listNodesWithCompletion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Lists volumes.
 * @param completion Completion block.
 */
- (void)listVolumesWithCompletion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Lists volume nodes.
 * @param volumeName Volume name
 * @param completion Completion block.
 */
- (void)listVolumeNodes:(NSString *)volumeName completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Lists volume access rights.
 * @param volumeName Volume name
 * @param completion Completion block.
 */
- (void)listVolumeAccessRights:(NSString *)volumeName completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Lists the directory at given path.
 * Use recursive param with caution as it can download masive amount of data.
 * @param path       Path to list.
 * @param recursive  YES if should include subdirectories, NO otherwise.
 * @param completion Completion block.
 */
- (void)listDirectoryAtPath:(NSString *)path recursive:(BOOL)recursive completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Adds file at given path.
 * @param path       Path of the file.
 * @param bytes      Size of the file.
 * @param blockNames Array containing block names.
 * @param completion Completion block.
 */
- (void)addFileWithPath:(NSString *)path size:(unsigned long long)bytes blockNames:(NSArray *)blockNames completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Uploads block to given node.
 * @param node        Node.
 * @param uploadToken Upload token.
 * @param data        Block's data.
 * @param completion  Completion block.
 */
- (void)uploadBlockToNode:(NSString *)node uploadToken:(NSString *)uploadToken data:(NSData *)data completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Flushes added file.
 * @param uploadToken Upload token.
 * @param node        Node to send the request to.
 * @param completion  Completion block.
 */
- (void)flushAddedFileWithUploadToken:(NSString *)uploadToken node:(NSString *)node completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Polls.
 * @param requestId  Request ID.
 * @param node       Node to send the request to.
 * @param completion Completion block.
 */
- (void)pollWithRequestId:(NSString *)requestId node:(NSString *)node completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Deletes file at given path.
 * @param path       Path.
 * @param completion Completion block.
 */
- (void)deleteFileWithPath:(NSString *)path completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Estimates the expected blocks size for the upload.
 * @param volume     Volume.
 * @param bytes      Size of the file which is about to be uploaded.
 * @param completion Completion block.
 */
- (void)blockSizeForVolume:(NSString *)volume withFileSize:(unsigned long long)bytes completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Gets filter active for volume.
 * @param volume     Volume.
 * @param completion Completion block.
 */
- (void)filterActiveForVolume:(NSString *)volume completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Gets info about the file at given path.
 * @param path       Path.
 * @param completion Completion block.
 */
- (void)fileAtPath:(NSString *)path completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Gets block with given node and block's name.
 * @param node       Node.
 * @param name       Block's name.
 * @param blockSize  Block's size.
 * @param completion Completion block.
 */
- (void)blockFromNode:(NSString *)node withName:(NSString *)name size:(unsigned long long)blockSize completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Lists users.
 * @param completion Completion block.
 */
- (void)listUsersWithCompletion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Generates public link for a file.
 * @param filePath   File path including filename and extension.
 * @param expireTime Time interval in secs the link will be valid.
 * @param password   Password which the receiver has to enter in order to download the file.
 * @param completion Completion block.
 */
- (void)publicLinkForFileAtPath:(NSString *)filePath expireTime:(NSTimeInterval)expireTime password:(NSString *)password isDirectory:(BOOL)isDirectory completion:(SKYCloudResponseCompletionBlock)completion;

/**
 * Get cluster meta.
 * @param completion Completion block.
 */
- (void)getClusterMeta:(SKYCloudResponseCompletionBlock)completion;

@end
