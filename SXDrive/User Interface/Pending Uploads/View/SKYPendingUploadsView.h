//
//  SKYPendingUploadsView.h
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

/**
 * Delegate for handling view events.
 */
@protocol SKYPendingUploadsViewInteractionDelegate <NSObject>

/**
 * Called when user presses cancel button.
 * @param indexPath Index path for item to cancel upload.
 */
- (void)userWantsToCancelUploadAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Uploads mode: built-in or summary.
 */
- (NSString *)controllerUploadsMode;

/**
 * Called when user selects the item.
 * @param indexPath Index path of selected item.
 */
- (void)userDidSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 * Data source for pending uploads view.
 */
@protocol SKYPendingUploadsViewDataSource <NSObject>

/**
 * Returns number of sections with items.
 * @return Number of sections.
 */
- (NSInteger)numberOfItemSections;

/**
 * Returns number of items in section.
 * @param section Index of section with items.
 * @return Number of items.
 */
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

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
 * Returns icon for item at given index path.
 * @param indexPath Index path of the item.
 * @return Icon for the item.
 */
- (UIImage *)iconForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns progress for item at given index path.
 * @param indexPath Index path of the item.
 * @return Progress for item at given index path.
 */
- (float)progressForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns section title for a given section.
 */
- (NSString *)itemSectionTitle:(NSInteger)section;

/**
 * Checks if upload for item at given index path is completed.
 * @param indexPath Index path of the item.
 * @return YES if upload is completed, NO otherwise.
 */
- (BOOL)uploadCompletedForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns SKYItem path for item at given index path.
 * @param indexPath Index path of the item.
 * @return SKYItem path.
 */
- (NSString *)pathForItemAtIndexPath:(NSIndexPath *)indexPath;

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

@end

/**
 * Protocol of pending uploads view.
 */
@protocol SKYPendingUploadsView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYPendingUploadsViewInteractionDelegate> interactionDelegate;

/**
 * Data source.
 */
@property (nonatomic, weak) id <SKYPendingUploadsViewDataSource> pendingUploadsDataSource;

/**
 * Master table which presents this view.
 */
@property (nonatomic, weak) UITableView *presentingTableView;

@end
