//
//  SKYDiskManager.h
//  SXDrive
//
//  Created by Skylable on 29/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Protocol of disk manager.
 * @note Size properties are read and write able. If you know the difference in bytes you can adjust it manually without the need of slow recalculation.
 */
@protocol SKYDiskManager <NSObject>

/**
 * Checks if currently disk manager is calculating when the size variables may contain incorrect or zero value.
 */
@property (atomic, readonly) BOOL isCalculating;

/**
 * Total size of application data.
 */
@property (readonly) unsigned long long totalDiskUsage;

/**
 * Size of pending uploads.
 */
@property (atomic) unsigned long long pendingUploadsDiskUsage;

/**
 * Size of index (database).
 */
@property (atomic) unsigned long long indexDiskUsage;

/**
 * Size of cache (excluding index and favourites).
 */
@property (atomic) unsigned long long cacheDiskUsage;

/**
 * Size of favourites files.
 */
@property (atomic) unsigned long long favouritesDiskUsage;

/**
 * Asynchronously recalculates disk usage properties.
 */
- (void)recalculateDiskUsage;

/**
 * Removes cache.
 */
- (void)removeCache;

/**
 * Removes cache aboves the limit.
 */
- (void)removeCacheAboveLimit;

@end
