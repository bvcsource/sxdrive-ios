//
//  SKYPersistence.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import CoreData;
@import Foundation;

@class SKYItem;

/**
 * Block for notifying about changes to particular file.
 * @param info Information about file location, download/upload progress etc.
 */
typedef void (^SKYPersistenceFileNotifyBlock)(NSDictionary *info);

/**
 * Protocol of persistence.
 */
@protocol SKYPersistence <NSObject>

/**
 * Managed Object Context for Core Data.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 * Checks if user has write access right for given volume.
 *
 * @param volumeName Name of the volume.
 *
 * @return YES if user has write access right, NO otherwise.
 */

- (BOOL)canModifyVolumeWithName:(NSString *)volumeName;

/**
 * Adds directory at given path.
 * It will be uploaded to the cloud soon.
 * @param path       Path of the directory.
 */
- (void)addDirectoryAtPath:(NSString *)path;

/**
 * Removes item (directory or file) at given path.
 * It will be deleted from the cloud soon.
 * @param item       Item to delete.
 * @return YES if success, NO if failure.
 */
- (BOOL)removeItem:(SKYItem *)item;

/**
 * Adds new file at given path.
 * It will be uploaded to the cloud soon.
 * @param path       Path of the file or nil.
 * @param content    Location as NSURL object or the file data as NSData object.
 */
- (void)addFileAtPath:(NSString *)path content:(id)content;

//TODO: possibly here also item not path
/**
 * Returns contents of directory at given path.
 * To populate the file listing use fetchedResultsControllerForDirectoryAtPath:includeDirectories:.
 * @param path Path.
 * @return Array of SKYItem objects.
 */
- (NSArray *)listingOfDirectoryAtPath:(NSString *)path;

/**
 * Returns all favourited items.
 * To populate the file listing use fetchedResultsControllerForFavourites.
 * @return Array of SKYItem objects.
 */
- (NSArray *)favouriteItems;

/**
 * Returns prefered sort descriptors (by modification date or name).
 * @return Prefered sort descriptors.
 */
- (NSArray *)preferedSortDescriptors;

/**
 * Returns fetched results controller which monitors the given item (directory).
 * @param item               Item to monitor.
 * @param includeDirectories YES to displays both files and directories, NO to display only files.
 * @return Fetched results controller configured for the given item.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForDirectory:(SKYItem *)item includeDirectories:(BOOL)includeDirectories;

/**
 * Returns fetched results controller which monitors the given item (directory) pending changes.
 * @param item Item to monitor.
 * @return Fetched results controller configured for pending changes in the given item.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForPendingChangesInDirectory:(SKYItem *)item;

/**
 * Returns fetched results controller which monitors all completed and optionally pending changes.
 * @param includePendingItems Include pending items.
 * @return Fetched results controller configured for all completed and optionally pending changes.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForCompletedChangesIncludePendingItems:(BOOL)includePendingItems;

/**
 * Returns fetched results controller for volumes.
 * @return Fetched results controller configured for volumes.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForVolumes;

/**
 * Returns fetched results controller which monitors the favourites.
 * @return Fetched results controller configured for favourites.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForFavourites;

/**
 * Returns fetched results controller which monitor the given item.
 * @param item Item to monitor.
 * @return Fetched results controller for single item.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForItem:(SKYItem *)item;

/**
 * Add item to favourites.
 * @param item Item to favourite.
 */
- (void)addFavouriteFlagToItem:(SKYItem *)item;

/**
 * Remove item from favourites.
 * @param item Item to unfavourite.
 */
- (void)removeFavouriteFlagToItem:(SKYItem *)item;

/**
 * Tells if the file is downloaded so it can be presented or shared.
 * @param item Item.
 * @return YES if file is downloaded, NO otherwise.
 */
- (BOOL)isItemDownloaded:(SKYItem *)item;

/**
 * Sets download progress for item.
 * @note This method is used to avoid saving the database for every change of progress to have the application responsive.
 * @param progress Progress (0.0 - 1.0).
 * @param item     Item.
 */
- (void)setDownloadProgress:(float)progress forItem:(SKYItem *)item;

/**
 * Returns download progress for item.
 * @param item Item.
 * @return Download progress (0.0 - 1.0 or 0.0 if progress for this item doesn't exist).
 */
- (float)downloadProgressForItem:(SKYItem *)item;

/**
 * Sets upload progress for item.
 * @note This method is used to avoid saving the database for every change of progress to have the application responsive.
 * @param progress Progress (0.0 - 1.0).
 * @param item     Item.
 */
- (void)setUploadProgress:(float)progress forItem:(SKYItem *)item;

/**
 * Returns upload progress for item.
 * @param item Item.
 * @return Upload progress (0.0 - 1.0 or 0.0 if progress for this item doesn't exist).
 */
- (float)uploadProgressForItem:(SKYItem *)item;

/**
 * Deletes all entries in core data, useful if user has logged out.
 */
- (void)deleteAllEntries;

/**
 * Reset Core Data in memory.
 */
- (void)reset;

/**
 * Retrieves SKYItem object for a defined URI.
 * @param  uri URI of SKYItem object.
 * @return SKYItem object, if exists or nil otherwise.
 */
- (SKYItem *)itemForURIRepresentation:(NSURL *)uri;

/**
 * Obtains permanent IDs for SKYItem objects, so they do not change between application sessions
 * @param  items SKYItem objects.
 * @return YES, if succeed, NO otherwise.
 */
- (BOOL)obtainPermanentIDsForItems:(NSArray *)items;

@end
