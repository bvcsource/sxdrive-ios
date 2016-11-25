//
//  SKYItem+Extras.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYItem.h"

/**
 * Name of the SKYItem entity.
 */
extern NSString * const SKYItemEntityName;

/**
 * Name of SKYItem's `name` attribute.
 */
extern NSString * const SKYItemNameAttributeName;

/**
 * Name of SKYItem's `updateDate` attribute.
 */
extern NSString * const SKYItemUpdateDateAttributeName;

/**
 * Name of SKYItem's `path` attribute.
 */
extern NSString * const SKYItemPathAttributeName;

/**
 * Name of SKYItem's `pendingSync` attribute.
 */
extern NSString * const SKYItemPendingSyncAttributeName;

/**
 * Name of SKYItem's `revision` attribute.
 */
extern NSString * const SKYItemRevisionAttributeName;

/**
 * Name of SKYItem's `isFavourite` attribute.
 */
extern NSString * const SKYItemIsFavouriteAttributeName;

/**
 * Name of SKYItem's `isDirectory` attribute.
 */
extern NSString * const SKYItemIsDirectoryAttributeName;

/**
 * Name of SKYItem's `addedThruApp` attribute.
 */
extern NSString * const SKYItemAddedThruAppAttributeName;

/**
 * Name of SKYItem's `uploadStatus` transient property.
 */
extern NSString * const SKYItemUploadStatusTransientProperty;

/**
 * Upload status for in progress uploads.
 */
extern NSString * const SKYItemUploadInProgressStatus;

/**
 * Upload status for completed uploads.
 */
extern NSString * const SKYItemUploadCompletedStatus;

/**
 * Category providing additional features for SKYItem entity.
 */
@interface SKYItem (Extras)

/**
 * Volume name.
 */
@property (nonatomic, readonly) NSString *volumeName;

/**
 * Full path.
 * @note path ends with `/` for the directory.
 */
@property (nonatomic, readonly) NSString *fullPath;

/**
 * Returns the same SKYItem object but synced from different context.
 * Useful method which allows you to modify/delete the object on different thread.
 * @param context Context to retrieve the same object from.
 * @return Receiver but in different context.
 */
- (instancetype)sameItemInContext:(NSManagedObjectContext *)context;

/**
 * Returns path where file should be located.
 * @return Path where file should be located.
 */
- (NSString *)expectedFileLocation;

/**
 * Returns url where file should be located.
 * @return URL where file should be located.
 */
- (NSURL *)expectedFileURL;

/**
 * Creates dictionary from `properties`.
 * @return Dictionary of properties.
 */
- (NSDictionary *)propertiesDictionary;

/**
 * Sets (or updates) the property value for given name.
 * @note To delete the property pass nil as a value.
 * @param value         Value of the property (string, number, array, dictionary, nil, NULL).
 * @param propertyName  Name of the property.
 */
- (void)setPropertyValue:(id)value name:(NSString *)propertyName;

/**
 * Returns the value associated with given name or nil.
 * @param propertyName Property name.
 * @return Value of the property or nil.
 */
- (id)propertyValueForName:(NSString *)propertyName;

/**
 * Checks if item has the given property.
 * @param propertyName Name of the property.
 * @return YES if item has given property, NO otherwise.
 */
- (BOOL)hasProperty:(NSString *)propertyName;

/**
 * Transient property based on 'pendingSync' attribute.
 */
@property (nonatomic, readonly) NSString *uploadStatus;

/**
 * Checks if upload is in progress or completed.
 * @return YES if upload is completed, NO otherwise.
 */
- (BOOL)isUploadCompleted;

@end
