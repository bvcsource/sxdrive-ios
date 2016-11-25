//
//  SKYBrowseDirectoryBehaviour.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import CoreData;
@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYConfig.h"
#import "SKYDiskManager.h"
#import "SKYNetworkManager.h"
#import "SKYPersistence.h"
#import "SKYSyncService.h"
#import "SKYUser.h"

@class SKYItem;
@class SKYPendingUploadsController;

/**
 * Presenter for the browse directory behaviour.
 */
@protocol SKYBrowseDirectoryBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Directory title (filename of directory).
 */
@property (nonatomic, strong) NSString *directoryTitle;

/**
 * Browser mode: default or choose directory.
 */
@property (nonatomic, strong) NSString *browserMode;

/**
 * Instructs the presenter to display results based on fetched results controller.
 * @param fetchedResultsController Fetched results controller configured to provide the listing.
 */
- (void)displayDirectoryListingFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 * Instructs the presenter to display pending uploads controller.
 * @param pendingUploadsController Pending uploads controller.
 */
- (void)displayPendingUploadsController:(SKYPendingUploadsController *)pendingUploadsController;

/**
 * Instructs the presenter to display loading interface (for the initial sync).
 */
- (void)displayLoadingInterface;

/**
 * Instructs the presenter to display no internet interface.
 */
- (void)displayNoInternetInterface;

/**
 * Instructs the presenter to display or hide loading indicator.
 * @param display YES if loading indicator should be displayed, NO otherwise.
 */
- (void)displayLoadingIndicator:(BOOL)display;

/**
 * Instructs the presenter to display the tools that only user with write access can use.
 * @note I.g. create file, delete files etc.
 */
- (void)displayToolsForUserWithWriteAccessRight;

/**
 * Shows 'Choose Directory' button in case of a respective browser mode.
 */
- (void)displayToolsForChoosingDirectory;

@end

/**
 * Protocol of browse directory behaviour.
 */
@protocol SKYBrowseDirectoryBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the browse directory behaviour.
 */
@property (nonatomic, weak) id <SKYBrowseDirectoryBehaviourPresenter> presenter;

/**
 * User.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Sync service.
 */
@property (nonatomic, strong) id <SKYSyncService> syncService;

/**
 * Network manager.
 */
@property (nonatomic, strong) id <SKYNetworkManager> networkManager;

/**
 * Disk manager.
 */
@property (nonatomic, strong) id <SKYDiskManager> diskManager;

/**
 * Create directory with given name.
 * @param name Name of the new directory.
 */
- (void)createDirectoryWithName:(NSString *)name;

/**
 * Adds the file with given dictionary containing details of the file.
 * @param file Dictionary contain file details.
 * @note For image file contains SKYInfoKeyForImage and SKYInfoKeyForImageType keys.
 * @note For video file contains SKYInfoKeyForMovieURL key.
 * @note For other files contains SKYInfoKeyForFileURL key.
 */
- (void)addFile:(NSDictionary *)file;

/**
 * Deletes the items.
 * @param indexPaths Array containing items to delete.
 */
- (void)deleteItems:(NSArray *)items;

/**
 * Method called when user selected an item.
 * @param item Selected item.
 */
- (void)userDidSelectItem:(SKYItem *)item;

/**
 * Starts keeping the directory in sync.
 */
- (void)startKeepingDirectoryInSync;

/**
 * Stops keeping the directory in sync.
 */
- (void)stopKeepingDirectoryInSync;

/**
 * Refreshes the content.
 */
- (void)refresh;

/**
 * Changes sorting type to given sorting type.
 * @param sortingType Sorting type.
 */
- (void)changeSortingType:(SKYConfigSortingType)sortingType;

/**
 * Updates directory.
 */
- (void)updateDirectory;

/**
 * Called when user presses choose directory button in toolbar.
 */
- (void)userDidChooseDirectory;

/**
 * Called when user presses cancel button in toolbar while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

/**
 * Shows file revisions.
 * @param item Item to show revisions.
 */
- (void)showRevisionsForItem:(SKYItem *)item;

@end
