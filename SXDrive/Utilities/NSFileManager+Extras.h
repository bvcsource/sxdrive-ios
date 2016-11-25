//
//  NSFileManager+Extras.h
//  SXDrive
//
//  Created by Skylable on 10/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Extra extensions to NSFileManager class.
 */
@interface NSFileManager (Extras)

/**
 * Returns size of the given file.
 * @param path Path to the file.
 * @return Size in bytes.
 */
+ (unsigned long long)sizeOfFileAtPath:(NSString *)path;

/**
 * Returns size of the given file.
 * @param url URL to the file.
 * @return Size in bytes.
 */
+ (unsigned long long)sizeOfFileAtURL:(NSURL *)url;

/**
 * Path to the database file.
 * @return Path to the database file.
 */
+ (NSString *)databasePath;

/**
 * Path to store all the data that can be recreated from the cloud.
 * @return Path to the library->caches directory.
 */
+ (NSString *)libraryCachesPath;

/**
 * Path to pending upload directory.
 * If the directory doesn't exist it will be created.
 * @return Path to pending upload directory.
 */
+ (NSString *)pathToPendingUploadDirectory;

/**
 * URL to pending upload directory.
 * If the directory doesn't exist it will be created.
 * @return Path to pending upload directory.
 */
+ (NSURL *)urlToPendingUploadDirectory;

/**
 * Path to store all the temporary data.
 * @return Path to the tmp directory.
 */
+ (NSString *)tmpPath;

/**
 * Path to ordinary files directory.
 * If the directory doesn't exist it will be created.
 * @return Path to pending upload directory.
 */
+ (NSString *)pathToOrdinaryFiles;

/**
 * Path to favourite files directory.
 * If the directory doesn't exist it will be created.
 * @return Path to pending upload directory.
 */
+ (NSString *)pathToFavouriteFiles;

/**
 * Checks if there is directory at given path, if not it creates it.
 * If the item at given path is the file, it's replaced with directory.
 * @param path Path.
 */
- (void)createDirectoryIfNeededAtPath:(NSString *)path;

/**
 * Returns image extensions.
 * @return Image extensions.
 */
+ (NSArray *)imageExtensions;

/**
 * Returns movie extensions.
 * @return Movie extensions.
 */
+ (NSArray *)movieExtensions;

/**
 * Returns music extensions.
 * @return Music extensions.
 */
+ (NSArray *)musicExtensions;

/**
 * Checks if the extension of the file is one of the image extensions.
 * @param path Path to check the extension.
 * @return YES if file is the image, NO otherwise.
 */
+ (BOOL)isFileOfImageType:(NSString *)path;

/**
 * Checks if the extension of the file is one of the movie extensions.
 * @param path Path to check the extension.
 * @return YES if file is the movie, NO otherwise.
 */
+ (BOOL)isFileOfMovieType:(NSString *)path;

/**
 * Checks if the extension of the file is one of the music extensions.
 * @param path Path to check the extension.
 * @return YES if file is the music, NO otherwise.
 */
+ (BOOL)isFileOfMusicType:(NSString *)path;

/**
 * Removes the ordinary, favourite and pending sync directories with their contents.
 */
+ (void)removeAllCachedAndTemporaryFiles;

/**
 * Calculates asynchronously size of the directory.
 * @param completion Completion block containing size of the directory.
 */
+ (void)calculateSizeOfDirectoryAtPath:(NSString *)path completion:(void (^)(unsigned long long size))completion;

/**
 * Returns size of directory at given path.
 * @note This method may execute very long, avoid using it on UI thread.
 * @param path Path to the directory.
 * @return Size of the directory.
 */
+ (unsigned long long)sizeOfDirectoryAtPath:(NSString *)path;

/**
 * Returns paths of all items in directory at given path and subfolders.
 * @note This method may execute very long, avoid using it on UI thread.
 * @param path Path to the directory.
 * @return Array of paths.
 */
+ (NSArray *)allFilePathsInDirectoryAtPath:(NSString *)path;

/**
 * Removes ordinary files.
 */
+ (void)removeOrdinaryFiles;

@end
