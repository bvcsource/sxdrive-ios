//
//  SKYPendingUploadsBehaviour.h
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPersistence.h"
#import "SKYSyncService.h"

/**
 * Presenter for the pending uploads behaviour.
 */
@protocol SKYPendingUploadsBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Uploads mode: built-in or summary.
 */
@property (nonatomic, strong) NSString *uploadsMode;

/**
 * Instructs the presenter to display results based on fetched results controller.
 * @param fetchedResultsController Fetched results controller configured to provide the listing.
 */
- (void)displayPendingChangesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 * Instructs the presenter to display new progress for given item.
 * @param progress Progress.
 * @param item     Item.
 */
- (void)displayProgress:(float)progress forItem:(SKYItem *)item;

@end

/**
 * Protocol of pending uploads behaviour.
 */
@protocol SKYPendingUploadsBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the pending uploads behaviour.
 */
@property (nonatomic, weak) id <SKYPendingUploadsBehaviourPresenter> presenter;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Item (directory) for which this behaviour check pending changes.
 */
@property (nonatomic, strong) SKYItem *item;

/**
 * Sync service.
 */
@property (nonatomic, strong) id <SKYSyncService> syncService;

/**
 * Returns upload progress for given item.
 * @param item Item.
 * @return Upload progress.
 */
- (float)uploadProgressForItem:(SKYItem *)item;

/**
 * Cancels the upload for given item.
 * @param item Item.
 */
- (void)cancelUploadForItem:(SKYItem *)item;

/**
 * Method called when user selected an item.
 * @param item Selected item.
 */
- (void)userDidSelectItem:(SKYItem *)item;

@end
