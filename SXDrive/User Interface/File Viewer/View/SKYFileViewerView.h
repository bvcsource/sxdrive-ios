//
//  SKYFileViewerView.h
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"
#import "SKYFileViewerCollectionView.h"

/**
 * Delegate for handling view events.
 */
@protocol SKYFileViewerViewInteractionDelegate <NSObject>

/**
 * Called when user is scrolling the collection view.
 * @note This method executes many times with the same value.
 * @param index Index of item which is currently being viewed.
 */
- (void)userDidScrollToItemAtIndex:(NSUInteger)index;

/**
 * Called when the file view is no longer needed.
 * @param fileView FileView that is no longer within visible area.
 */
- (void)userScrolledFileViewBeyondVisibleArea:(UIView *)fileView;

/**
 * Called when user wants to change favourite status of item at given index.
 * @param index Index of item.
 */
- (void)userWantsToReverseFavouriteStatusOfItemAtIndex:(NSUInteger)index;

/**
 * Called when user wants to share item at given index.
 * @param index Index of item.
 */
- (void)userWantsToShareItemAtIndex:(NSUInteger)index;

/**
 * Called when user wants to generate a public link for item at given index.
 * @param indexPath Index path of item.
 */
- (void)userWantsToGetPublicLinkForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Called when user wants to delete item at given index.
 * @param index Index of item.
 */
- (void)userWantsToDeleteItemAtIndex:(NSUInteger)index;

@end

/**
 * Data source for file viewer view.
 */
@protocol SKYFileViewerViewDataSource <NSObject>

/**
 * Returns number of items.
 * @return Number of items.
 */
- (NSInteger)numberOfItems;

/**
 * View to display contents or loader of file at given index.
 * @param index Index
 * @return View.
 */
- (UIView *)fileViewForItemAtIndex:(NSInteger)index;

/**
 * Returns favourite status of file at given index.
 * @param index Index.
 * @return YES if file is favourited, NO otherwise.
 */
- (BOOL)isItemFavouritedAtIndex:(NSInteger)index;

@end

/**
 * Protocol of file viewer view.
 */
@protocol SKYFileViewerView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYFileViewerViewInteractionDelegate> interactionDelegate;

/**
 * Data source.
 */
@property (nonatomic, weak) id <SKYFileViewerViewDataSource> dataSource;

/**
 * Share button item.
 * @note Useful to have it here because menus are presented from this item.
 */
@property (nonatomic, strong) UIBarButtonItem *shareButtonItem;

/**
 * Collection View responsible for displaying file views.
 * This property is public due to very problematic update when there is more then one update operation.
 */
@property (nonatomic, strong) SKYFileViewerCollectionView *collectionView;

/**
 * Once view is ready file with given indexPath is presented.
 */
@property (nonatomic, strong) NSIndexPath *indexPathToFocus;

/**
 * Locks scroll
 */
@property (nonatomic, assign) BOOL scrollLocked;

/**
 * Asks the view to reload favourite status of file at given index.
 * @param index Index.
 */
- (void)reloadFavouriteStatusOfItemAtIndex:(NSInteger)index;

/**
 * Used to reload the style of favourite button item.
 */
- (void)updateFavouriteButtonItem;

/**
 * Displays alert informing the user that the file he wants to share is not downloaded yet.
 */
- (void)displayShareUnavailableBecauseOfNotDownloadedFile;

@end
