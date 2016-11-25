//
//  SKYBrowseDirectoryView.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

#import "SKYPendingUploadsView.h"

@class SKYItem;

/**
 * Delegate for handling view events.
 */
@protocol SKYBrowseDirectoryViewInteractionDelegate <NSObject>

/**
 * Called when user wants to create new directory.
 * @param name Proposed name of the directory.
 */
- (void)userWantsToCreateDirectoryWithName:(NSString *)name;

/**
 * Called when user selects the item.
 * @param indexPath Index path of selected item.
 */
- (void)userDidSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Called when user wants to delete the items.
 * @param indexPaths Array containing index paths of items to delete.
 */
- (void)userWantsToDeleteItemAtIndexPaths:(NSArray *)indexPaths;

/**
 * Called when user shared a public link to the item.
 * @param indexPath Index path of selected item.
 */
- (void)userWantsToGetPublicLinkForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Called when user wants to show revisions for the item.
 * @param indexPath Index path of selected item.
 */
- (void)userWantsToShowRevisionsForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Browser mode: default or choose directory.
 */
- (NSString *)controllerBrowserMode;

@end

/**
 * Data source for browse directory view.
 */
@protocol SKYBrowseDirectoryViewDataSource <NSObject>

/**
 * Returns number of sections in the directory.
 * @return Number of sections in the directory.
 */
- (NSInteger)numberOfSections;

/**
 * Returns number of rows in given section.
 * @param section Section index.
 * @return Number of rows in given section.
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 * Checks if a item at given index path a directory or not.
 * @param indexPath Index path of the item.
 * @return YES if it's a directory, NO otherwise.
 */
- (BOOL)isRowAtIndexPathDirectory:(NSIndexPath *)indexPath;

/**
 * Returns name of item at given index path.
 * @param indexPath Index path of the item.
 * @return Name of the item.
 */
- (NSString *)nameOfItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns formatted size of item at given index path.
 * @param indexPath Index path of the item.
 * @return Formatted size of item.
 */
- (NSString *)formattedSizeOfItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns modification (or creation) date of item at given index path.
 * @param indexPath Index path of the item.
 * @return Modification (or creation) date.
 */
- (NSString *)modificationDateOfItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns SKYItem at given index path.
 * @param indexPath Index path of the item.
 * @return Item at given index path.
 */
- (SKYItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns favourite status of item at given index path.
 * @param indexPath  Index path of the item.
 * @return YES if item is favourited, NO otherwise.
 */
- (BOOL)isItemFavouritedAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Checks if user can modify the item at given index path.
 * @param indexPath Index path of the item.
 * @return YES if user can modify it, NO otherwise.
 */
- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Checks if user can share public link for an item at given index path.
 * @param indexPath Index path of the item.
 * @return YES if user can share public link, NO otherwise.
 */
- (BOOL)canShareItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Checks if user can show revisions for an item at given index path.
 * @param indexPath Index path of the item.
 * @return YES if user can show revisions, NO otherwise.
 */
- (BOOL)canShowRevisionsForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 * Protocol of browse directory view.
 */
@protocol SKYBrowseDirectoryView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYBrowseDirectoryViewInteractionDelegate> interactionDelegate;

/**
 * Data source.
 */
@property (nonatomic, weak) id <SKYBrowseDirectoryViewDataSource> browseDirectoryDataSource;

/**
 * Displays add new directory interface.
 */
- (void)displayAddNewDirectoryInterface;

/**
 * Reloads the data.
 */
- (void)reloadData;

/**
 * Deselects selected cell.
 * @param animated YES if it should be animated, NO otherwise.
 */
- (void)deselectSelectedCellAnimated:(BOOL)animated;

/**
 * Displays loading spinner.
 */
- (void)displayLoadingSpinner;

/**
 * Displays file.
 * @note To be honest list is always visible (sometimes empty), this method hides spinner and no contents label.
 */
- (void)displaysFiles;

/**
 * Displays empty directory label.
 */
- (void)displayEmptyDirectoryLabel;

/**
 * Displays no internet label.
 */
- (void)displayNoInternetLabel;

/**
 * Displays curtain (like empty view/favourites/loading).
 * @param curtain Curtain to display on full screen.
 */
- (void)displayCurtain:(UIView *)curtain;

/**
 * Removes any curtain.
 */
- (void)removeCurtain;

/**
 * Adds pending uploads view.
 * @param view Pending uploads view.
 */
- (void)addPendingUpdatesView:(id <SKYPendingUploadsView>)view;

/**
 * Shows selection view.
 */
- (void)showSelectionView;

/**
 * Hides selection view.
 */
- (void)hideSelectionView;

/**
 * Selects row at index path programmatically.
 * @param indexPath indes path to select.
 */
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
