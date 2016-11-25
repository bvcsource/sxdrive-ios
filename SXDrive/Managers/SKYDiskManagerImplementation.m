//
//  SKYDiskManagerImplementation.m
//  SXDrive
//
//  Created by Skylable on 29/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYDiskManagerImplementation.h"

#import "NSFileManager+Extras.h"
#import "SKYConfig.h"
#import "SKYNotificationNames.h"

@interface SKYDiskManagerImplementation ()

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic) BOOL isCalculating;

@end

@implementation SKYDiskManagerImplementation

@synthesize pendingUploadsDiskUsage = _pendingUploadsDiskUsage;
@synthesize indexDiskUsage = _indexDiskUsage;
@synthesize cacheDiskUsage = _cacheDiskUsage;
@synthesize favouritesDiskUsage = _favouritesDiskUsage;

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		[self recalculateDiskUsage];
	}
	
	return self;
}

- (void)recalculateDiskUsage
{
	if (self.isCalculating == NO) {
		self.isCalculating = YES;
		
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
			
			unsigned long long dirtyPendingUploadsDiskUsage, dirtyIndexDiskUsage, dirtyCacheDiskUsage, dirtyFavouritesDiskUsage;
			
			dirtyPendingUploadsDiskUsage = [NSFileManager sizeOfDirectoryAtPath:[NSFileManager pathToPendingUploadDirectory]];
			dirtyCacheDiskUsage = [NSFileManager sizeOfDirectoryAtPath:[NSFileManager pathToOrdinaryFiles]];
			dirtyIndexDiskUsage = [NSFileManager sizeOfFileAtPath:[NSFileManager databasePath]];
			dirtyFavouritesDiskUsage = [NSFileManager sizeOfDirectoryAtPath:[NSFileManager pathToFavouriteFiles]];
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				
				BOOL hasChanges = NO;
				
				if (_pendingUploadsDiskUsage != dirtyPendingUploadsDiskUsage) {
					_pendingUploadsDiskUsage = dirtyPendingUploadsDiskUsage;
					hasChanges = YES;
				}
				
				if (_indexDiskUsage != dirtyIndexDiskUsage) {
					_indexDiskUsage = dirtyIndexDiskUsage;
					hasChanges = YES;
				}
				
				if (_cacheDiskUsage != dirtyCacheDiskUsage) {
					_cacheDiskUsage = dirtyCacheDiskUsage;
					hasChanges = YES;
				}
				
				if (_favouritesDiskUsage != dirtyFavouritesDiskUsage) {
					_favouritesDiskUsage = dirtyFavouritesDiskUsage;
					hasChanges = YES;
				}
				self.isCalculating = NO;
				
				if (hasChanges == YES) {
					[[NSNotificationCenter defaultCenter] postNotificationName:SKYDiskUsageDidChangeNotification object:self];
				}
			});
		});
	}
}

- (unsigned long long)totalDiskUsage
{
	return self.pendingUploadsDiskUsage + self.indexDiskUsage + self.cacheDiskUsage + self.favouritesDiskUsage;
}

- (void)setPendingUploadsDiskUsage:(unsigned long long)pendingUploadsDiskUsage
{
	@synchronized(self) {
		if (_pendingUploadsDiskUsage != pendingUploadsDiskUsage) {
			_pendingUploadsDiskUsage = pendingUploadsDiskUsage;
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYDiskUsageDidChangeNotification object:self];
		}
	}
}

- (void)setIndexDiskUsage:(unsigned long long)indexDiskUsage
{
	@synchronized(self) {
		if (_indexDiskUsage != indexDiskUsage) {
			_indexDiskUsage = indexDiskUsage;
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYDiskUsageDidChangeNotification object:self];
		}
	}
}

- (void)setCacheDiskUsage:(unsigned long long)cacheDiskUsage
{
	@synchronized(self) {
		if (_cacheDiskUsage != cacheDiskUsage) {
			_cacheDiskUsage = cacheDiskUsage;
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYDiskUsageDidChangeNotification object:self];
		}
	}
}

- (void)setFavouritesDiskUsage:(unsigned long long)favouritesDiskUsage
{
	@synchronized(self) {
		if (_favouritesDiskUsage != favouritesDiskUsage) {
			_favouritesDiskUsage = favouritesDiskUsage;
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYDiskUsageDidChangeNotification object:self];
		}
	}
}

- (void)removeCache
{
	[NSFileManager removeOrdinaryFiles];
	[self recalculateDiskUsage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYMajorFileStructureDidChangeNotification object:self];
}

- (void)removeCacheAboveLimit
{
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		double cacheSize = [NSFileManager sizeOfDirectoryAtPath:[NSFileManager pathToOrdinaryFiles]];
		
		if (cacheSize > [SKYConfig maxCacheSize]) {
			NSArray *files = [NSFileManager allFilePathsInDirectoryAtPath:[NSFileManager pathToOrdinaryFiles]];
			
			NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSDictionary *first_properties  = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil];
				NSDate *first = [first_properties  objectForKey:NSFileModificationDate];
				NSDictionary *second_properties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil];
				NSDate *second = [second_properties objectForKey:NSFileModificationDate];
				
				return [first compare:second];
			}];
			
			NSMutableArray *mutableFiles = sortedFiles.mutableCopy;
			
			while (cacheSize > [SKYConfig maxCacheSize] && mutableFiles) {
				NSString *path = mutableFiles.firstObject;
				unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] fileSize];
				
				if ([[NSFileManager defaultManager] removeItemAtPath:path error:NULL]) {
					cacheSize -= fileSize;
					
				}
				[mutableFiles removeObjectAtIndex:0];
			}
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:SKYMajorFileStructureDidChangeNotification object:weakSelf];
		});
	});
}

@end
