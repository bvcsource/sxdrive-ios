//
//  SKYFileViewerBehaviour.h
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPersistence.h"

/**
 * Presenter for the file viewer behaviour.
 */
@protocol SKYFileViewerBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Instructs the presenter to display files based on fetched results controller.
 * @param item                     Item to be displayed at first.
 * @param fetchedResultsController Fetched results controller configured to provide the files.
 */

- (void)displayItem:(SKYItem *)item andOtherFilesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 * Instructs the presenter to display share menu for given item.
 * @param item Item to share.
 */
- (void)displayShareMenuForItem:(SKYItem *)item;

/**
 * Instructs the presenter to notify user that the file cannot be shared right now becase download has not compleated yet.
 * @param item Item to share.
 */
- (void)displayShareUnavailableBecauseOfNotDownloadedFile:(SKYItem *)item;

@end

/**
 * Protocol of file viewer behaviour.
 */
@protocol SKYFileViewerBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the file viewer behaviour.
 */
@property (nonatomic, weak) id <SKYFileViewerBehaviourPresenter> presenter;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Reverses favourite status
 * @param item Item to change favourite flag.
 */
- (void)reverseFavouriteStatus:(SKYItem *)item;

/**
 * Performs action when all the files displayed by the presenter has either been removed by user or via cloud.
 */
- (void)performActionForNoMoreItemsToDisplay;

/**
 * Called when user wants to share the item.
 * Immediately replies with appropriate presenter method.
 * @param item Item to share.
 */
- (void)shareItem:(SKYItem *)item;

/**
 * Called when user wants to delete the item.
 * @param item Item to delete.
 */
- (void)deleteItem:(SKYItem *)item;

@end
