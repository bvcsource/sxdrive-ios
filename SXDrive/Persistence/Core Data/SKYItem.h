//
//  SKYItem.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;
@import CoreData;

/**
 * Item object stored in data base.
 * Either directory or file.
 * If directory, path ends with "/".
 */
@interface SKYItem : NSManagedObject

/**
 * Path of the directory containing the item.
 * Root directory is "/".
 */
@property (nonatomic, strong) NSString *path;

/**
 * Name of the item.
 */
@property (nonatomic, strong) NSString *name;

/**
 * @YES if the item is directory.
 * @NO otherwise.
 */
@property (nonatomic, strong) NSNumber *isDirectory;

/**
 * Last update date of the item.
 */
@property (nonatomic, strong) NSDate *updateDate;

/**
 * @YES if user marked this item as a favoruite.
 */
@property (nonatomic, strong) NSNumber *isFavourite;

/**
 * Size of the file in bytes.
 */
@property (nonatomic, strong) NSNumber *fileSize;

/**
 * String identifying the status of synchronization, like pending delete from the cloud, pending to be uploaded to the cloud, status of upload etc.
 */
@property (nonatomic, strong) NSString *pendingSync;

/**
 * Revision of the file, contains modified date string and random hash.
 */
@property (nonatomic, strong) NSString *revision;

/**
 * Additional properties used to store information for sync and persistence.
 * Don't use this property directly, use helper methods in Extras category.
 */
@property (nonatomic, strong) NSString *properties;

/**
 * Name of the temporary file.
 */
@property (nonatomic, strong) NSString *tmpName;

/**
 * @YES if user uploaded this item as via application.
 */
@property (nonatomic, strong) NSNumber *addedThruApp;

@end

/**
 * Mock of SKYItem, for the purpose of unit testing.
 * Keep in sync with SKYItem.
 */
@protocol SKYItemMock <NSObject>

/**
 * Path of the item.
 */
@property (nonatomic, strong) NSString *path;

/**
 * Name of the item.
 */
@property (nonatomic, strong) NSString *name;

/**
 * @YES if the item is directory.
 * @NO otherwise.
 */
@property (nonatomic, strong) NSNumber *isDirectory;

/**
 * Last update date of the item.
 */
@property (nonatomic, strong) NSDate *updateDate;

/**
 * @YES if user marked this item as a favoruite.
 */
@property (nonatomic, strong) NSNumber *isFavourite;

/**
 * Size of the file in bytes.
 */
@property (nonatomic, strong) NSNumber *fileSize;

/**
 * String identifying the status of synchronization, like pending delete from the cloud, pending to be uploaded to the cloud, status of upload etc.
 */
@property (nonatomic, strong) NSString *pendingSync;

/**
 * Revision of the file, contains modified date string and random hash.
 */
@property (nonatomic, strong) NSString *revision;

/**
 * Additional properties used to store information for sync and persistence.
 * Don't use this property directly, use helper methods in Extras category.
 */
@property (nonatomic, strong) NSString *properties;

/**
 * Name of the temporary file.
 */
@property (nonatomic, strong) NSString *tmpName;

@end
