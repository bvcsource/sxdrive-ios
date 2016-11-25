//
//  SKYSyncService.h
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import CoreData;
@import Foundation;

@class SKYItem;

/**
 * Protocol of sync service.
 * This service is responsible for monitoring pending changes and starting responsbile handlers to sync each changes.
 */
@protocol SKYSyncService <NSObject>

/**
 * Syncs the given item.
 * @note for file - it downloads it, for directory - syncs content, for null - syncs volumes.
 * @param item Item to sync.
 * @param favourites If YES download file actions will be allocated as SKYSyncFavouriteDownloadFileAction subclasses.
 */
- (void)syncItem:(SKYItem *)item favourites:(BOOL)favourites;

/**
 * Stops downloading the item.
 * @param item Item to stop download.
 */
- (void)stopDownloadingItem:(SKYItem *)item;

/**
 * Stops uploading item (or creating the folder).
 * @param item Item to cancel its upload.
 */
- (void)cancelUpload:(SKYItem *)item;

/**
 * Adds item to be kept in sync.
 * @param item Item.
 * @note Pass nil to keep volumes in sync.
 */
- (void)addItemToKeepInSync:(SKYItem *)item;

/**
 * Removes item so it's no longer kept in sync.
 * @param item Item.
 * @note Pass nil to stop keeping volumes in sync.
 */
- (void)removeItemFromKeepInSync:(SKYItem *)item;

@end
