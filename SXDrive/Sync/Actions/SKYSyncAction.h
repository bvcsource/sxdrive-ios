//
//  SKYSyncAction.h
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYNetworkManager.h"

@class SKYCloudResponse, SKYItem;
@protocol SKYCloud, SKYErrorManager, SKYPersistence, SKYSyncActionDelegate;

/**
 * Block for sync action completion.
 */
typedef void (^SKYSyncActionCompletionBlock)();

/**
 * Base class for various sync actions.
 */
@interface SKYSyncAction : NSObject <SKYNetworkManagerCallback>

/**
 * YES if action has been cancelled, NO otherwise.
 */
@property (nonatomic) BOOL cancelled;

/**
 * Item related to the sync action.
 * Not all sync actions will require this item.
 */
@property (nonatomic, strong) SKYItem *item;

/**
 * Sync action completion block.
 */
@property (nonatomic, copy) SKYSyncActionCompletionBlock completionBlock;

/**
 * Cloud.
 */
@property (nonatomic, readonly) id <SKYCloud> cloud;

/**
 * Error manager.
 */
@property (nonatomic, readonly) id <SKYErrorManager> errorManager;

/**
 * Persistence.
 */
@property (nonatomic, readonly) id <SKYPersistence> persistence;

/**
 * Starts the action on the appropriate background queue.
 */
- (void)startAction;

/**
 * Dispatches the appropriate methods at a given state of the sync action.
 */
- (void)syncDirector;

/**
 * Process the error and decides what to do.
 * Either the sync action will be cancelled, or postponed.
 *
 * @param response Failed response to process.
 */
- (void)processErrorWithResponse:(SKYCloudResponse *)response;

/**
 * Should be the last operation called by sync director. Mean the action finish with success.
 * It should usually clean up the pending state of the item, move the file from tmp directory to the appropriate location, etc.
 * It has to call the completionBlock also.
 */
- (void)finishAction;

/**
 * Should be the last operation called by sync director. Means the action finish with failure.
 * It should usually clean up the pending state of the item, move the file from tmp directory to the appropriate location, etc.
 * It has to call the completionBlock also.
 */
- (void)failAction;

/**
 * Cancels the action.
 */
- (void)cancelAction;

@end
