//
//  NSFileManager+Extras.m
//  SXDrive
//
//  Created by Skylable on 10/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSFileManager+Extras.h"

/**
 * Name of the directory where files waiting to be uploaded are kept.
 */
static NSString * SKYPendingUploadDirectoryName = @"SKYPendingUploadDirectory";

/**
 * Name of the directory where downloaded files are stored (not favourite).
 */
static NSString * SKYOrdinaryFilesDirectoryName = @"SKYOrdinaryFilesDirectory";

/**
 * Name of the directory where favourite files are stored.
 */
static NSString * SKYFavouriteFilesDirectoryName = @"SKYFavouriteFilesDirectory";

/**
 * Name of the directory where temporary files are stored.
 */
static NSString * SKYTemporaryFilesDirectoryName = @"SKYTemporaryFilesDirectory";

@implementation NSFileManager (Extras)

+ (unsigned long long)sizeOfFileAtPath:(NSString *)path
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
	return [attributes[NSFileSize] unsignedLongLongValue];
}

+ (unsigned long long)sizeOfFileAtURL:(NSURL *)url
{
	return [self sizeOfFileAtPath:[url filePathURL].path];
}

+ (NSString *)databasePath
{
	return [[NSFileManager libraryCachesPath] stringByAppendingPathComponent:@"Base.sqlite"];
}

+ (NSString *)libraryCachesPath
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)pathToPendingUploadDirectory
{
	NSString *path = [[self libraryCachesPath] stringByAppendingPathComponent:SKYPendingUploadDirectoryName];
	[[NSFileManager defaultManager] createDirectoryIfNeededAtPath:path];
	
	return path;
}

+ (NSURL *)urlToPendingUploadDirectory
{
	return [NSURL fileURLWithPath:[self pathToPendingUploadDirectory]];
}

+ (NSString *)tmpPath
{
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:SKYTemporaryFilesDirectoryName];
	[[NSFileManager defaultManager] createDirectoryIfNeededAtPath:path];
	
	return path;
}

+ (NSString *)pathToOrdinaryFiles
{
	NSString *path = [[self libraryCachesPath] stringByAppendingPathComponent:SKYOrdinaryFilesDirectoryName];
	[[NSFileManager defaultManager] createDirectoryIfNeededAtPath:path];
	
	return path;
}

+ (NSString *)pathToFavouriteFiles
{
	NSString *path = [[self libraryCachesPath] stringByAppendingPathComponent:SKYFavouriteFilesDirectoryName];
	[[NSFileManager defaultManager] createDirectoryIfNeededAtPath:path];
	
	return path;
}

- (void)createDirectoryIfNeededAtPath:(NSString *)path
{
	BOOL isDirectory;
	BOOL directoryExists = [self fileExistsAtPath:path isDirectory:&isDirectory];

	if (directoryExists == YES && isDirectory == NO) {
		[self removeItemAtPath:path error:NULL];
		directoryExists = NO;
	}
	
	if (directoryExists == NO) {
		[self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
	}
}

+ (NSArray *)imageExtensions
{
	return @[@"png", @"jpeg", @"jpg", @"tiff", @"tif", @"gif", @"bmp", @"bmpf", @"ico", @"cur", @"xbm"];
}

+ (NSArray *)movieExtensions
{
	return @[@"mov", @"mp4", @"avi", @"mkv", @"ogv", @"qt", @"wmv", @"rmvb", @"mpg", @"mpeg", @"m4v", @"3gp"];
}

+ (NSArray *)musicExtensions
{
	return @[@"mp3", @"aiff", @"aac", @"m4a", @"ogg", @"oga", @"wav", @"wma", @"wv"];
}

+ (BOOL)isFileOfImageType:(NSString *)path
{
	NSString *lowercaseExtension = [path pathExtension].lowercaseString;
	
	return ([[self imageExtensions] containsObject:lowercaseExtension] == YES);
}

+ (BOOL)isFileOfMovieType:(NSString *)path
{
	NSString *lowercaseExtension = [path pathExtension].lowercaseString;
	
	return ([[self movieExtensions] containsObject:lowercaseExtension] == YES);
}

+ (BOOL)isFileOfMusicType:(NSString *)path
{
	NSString *lowercaseExtension = [path pathExtension].lowercaseString;
	
	return ([[self musicExtensions] containsObject:lowercaseExtension] == YES);
}

+ (void)removeAllCachedAndTemporaryFiles
{
	[[self defaultManager] removeItemAtPath:[self pathToOrdinaryFiles] error:NULL];
	[[self defaultManager] removeItemAtPath:[self pathToFavouriteFiles] error:NULL];
	[[self defaultManager] removeItemAtPath:[self pathToPendingUploadDirectory] error:NULL];
}

+ (void)calculateSizeOfDirectoryAtPath:(NSString *)path completion:(void (^)(unsigned long long size))completion
{
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		unsigned long long totalSize = [self sizeOfDirectoryAtPath:path];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			completion(totalSize);
		});
	});
}

+ (unsigned long long)sizeOfDirectoryAtPath:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *listing = [fileManager contentsOfDirectoryAtPath:path error:NULL];
	
	unsigned long long size = 0;
	
	for (NSString *file in listing) {
		NSString *subpath = [path stringByAppendingPathComponent:file];
		
		BOOL isDirectory = NO;
		if ([fileManager fileExistsAtPath:subpath isDirectory:&isDirectory] == YES) {
			if (isDirectory == YES) {
				size += [self sizeOfDirectoryAtPath:subpath];
			}
			else {
				NSDictionary *attributes = [fileManager attributesOfItemAtPath:subpath error:NULL];
				size += attributes.fileSize;
			}
		}
		else {
			NSAssert(NO, @"Strange error");
		}
	}
	
	return size;
}

+ (NSArray *)allFilePathsInDirectoryAtPath:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *listing = [fileManager contentsOfDirectoryAtPath:path error:NULL];
	
	NSMutableArray *paths = [NSMutableArray array];
	
	for (NSString *file in listing) {
		NSString *subpath = [path stringByAppendingPathComponent:file];
		
		BOOL isDirectory = NO;
		if ([fileManager fileExistsAtPath:subpath isDirectory:&isDirectory] == YES) {
			if (isDirectory == YES) {
				[paths addObjectsFromArray:[self allFilePathsInDirectoryAtPath:subpath]];
			}
			else {
				[paths addObject:subpath];
			}
		}
		else {
			NSAssert(NO, @"Strange error");
		}
	}
	
	return paths;
}

+ (void)removeOrdinaryFiles
{
	[[self defaultManager] removeItemAtPath:[self pathToOrdinaryFiles] error:NULL];
}

@end
