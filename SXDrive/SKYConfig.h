//
//  SKYConfig.h
//  SXDrive
//
//  Created by Skylable on 02/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPersistence.h"

/**
 * Enumeration of different sorting types.
 */
typedef NS_ENUM(NSUInteger, SKYConfigSortingType) {
	/**
	 * Sort a-z, default.
	 */
	SKYConfigSortingTypeByNameAscending,
	/**
	 * Sort z-a.
	 */
	SKYConfigSortingTypeByNameDescending,
	/**
	 * Sort by modification date, first oldest.
	 */
	SKYConfigSortingTypeByModificationDateAscending,
	/**
	 * Sort by modification date, first newest.
	 */
	SKYConfigSortingTypeByModificationDateDescending
};

@import Foundation;

/**
 * Sets the time interval after which the paths that should be kept in sync are refreshed.
 */
extern NSTimeInterval const SKYConfigRefreshKeptInSyncPathTimeInterval;

/**
 * Sets the time interval after which the favourite items are refreshed.
 */
extern NSTimeInterval const SKYConfigRefreshFavouritesTimeInterval;

/**
 * Time interval for passcode reentry (to protect the app when it was long in the background).
 */
extern NSTimeInterval const SKYConfigTimeIntervalForPasscodeReentry;

/**
 * Time interval for no internet smart alert (so not to spam user with alert when he is browsing offline).
 */
extern NSTimeInterval const SKYConfigMinimumTimeIntervalForNoInternetSmartAlert;

/**
 * Default max cache size in bytes.
 */
extern double const SKYConfigDefaultMaxCacheSize;

/**
 * Maximum value for max cache size in bytes.
 */
extern double const SKYConfigMaxMaxCacheSize;

/**
 * Minimum value for max cache size in bytes.
 */
extern double const SKYConfigMinMaxCacheSize;

@interface SKYConfig : NSObject

/**
 * Returns sorting type.
 * @return Sorting type.
 */
+ (SKYConfigSortingType)prefferedSortingType;

/**
 * Changes sorting type.
 * @param sortingType Sorting type to appy.
 */
+ (void)setPreferredSortingType:(SKYConfigSortingType)sortingType;

/**
 * Sets max cache size.
 * @param cacheSize Cache size.
 */
+ (void)setMaxCacheSize:(double)cacheSize;

/**
 * Returns max cache size.
 * @return Max cache size.
 */
+ (double)maxCacheSize;

/**
 * Returns big files warning enabled setting.
 * @return Big files warning enabled setting.
 */
+ (BOOL)bigFilesWarningEnabled;

/**
 * Enables or disables big files warning.
 * @param enabled Enable or disable.
 */
+ (void)setBigFilesWarningEnabled:(BOOL)enabled;

/**
 * Returns log enabled setting.
 * @return Log enabled setting.
 */
+ (BOOL)logEnabled;

/**
 * Enables or disables log.
 * @param enabled Enable or disable.
 */
+ (void)setLogEnabled:(BOOL)enabled;

/**
 * Returns show password enabled setting.
 * @return show password enabled setting.
 */
+ (BOOL)showPasswordEnabled;

/**
 * Enables or disables show password.
 * @param enabled Enable or disable.
 */
+ (void)setShowPasswordEnabled:(BOOL)enabled;

/**
 * Stores import file URL.
 * @return import file URL.
 */
+ (NSURL *)importFileURL;

/**
 * Sets import file URL.
 * @param url import file URL.
 */
+ (void)setImportFileURL:(NSURL *)url;

/**
 * Removes import file URL.
 */
+ (void)removeImportFileURL;

/**
 * Stores SKYItem object URIs that define a destination path where the last successful import file happened.
 * @return import file items URI array.
 */
+ (NSArray *)importFileItemsURIArray;

/**
 * Sets a destination path where the last successful import file happened.
 * @param array SKYItem object URIs.
 */
+ (void)setImportFileItemsURIArray:(NSArray *)array;

/*
 * Stores application launch date.
 * @return application launch date.
 */
+ (NSDate *)applicationLaunchDate;

/**
 * Sets application launch date.
 * @param date launch date.
 */
+ (void)setApplicationLaunchDate:(NSDate *)date;

/**
 * Stores touch ID enabled value.
 * @return YES if the user has touch ID enabled, NO otherwise.
 */
+ (BOOL)touchIDEnabled;

/**
 * Sets touch ID enabled value.
 * @param enabled value.
 */
+ (void)setTouchIDEnabled:(BOOL)enabled;

/*
 * Stores application installation date.
 * @return application installation date.
 */
+ (NSDate *)applicationInstallationDate;

/**
 * Sets application installation date.
 * @param date installation date.
 */
+ (void)setApplicationInstallationDate:(NSDate *)date;

/**
 * Stores background media upload enabled value.
 * @return YES if background media upload is enabled, NO otherwise.
 */
+ (BOOL)mediaUploadEnabled;

/**
 * Sets background media upload enabled value.
 * @param enabled value.
 */
+ (void)setMediaUploadEnabled:(BOOL)enabled;

/*
 * Stores last media file upload date.
 * @return media file upload date.
 */
+ (NSDate *)lastMediaUploadDate;

/**
 * Sets last media file upload date.
 * @param media file upload date.
 */
+ (void)setLastMediaUploadDate:(NSDate *)date;

/**
 * Stores NSString object that defines a destination path where background media file upload should happen.
 * @return NSString object.
 */
+ (NSString *)mediaUploadDestinationPath;

/**
 * Sets destination path where background media file upload should happen.
 * @param path value.
 */
+ (void)setMediaUploadDestinationPath:(NSString *)path;

/**
 * Stores photo upload on cellular enabled value.
 * @return YES if photo upload on cellular is enabled, NO otherwise.
 */
+ (BOOL)photoUploadOnCellularEnabled;

/**
 * Sets photo upload on cellular enabled value.
 * @param enabled value.
 */
+ (void)setPhotoUploadOnCellularEnabled:(BOOL)enabled;

/**
 * Stores video upload on cellular enabled value.
 * @return YES if video upload on cellular is enabled, NO otherwise.
 */
+ (BOOL)videoUploadOnCellularEnabled;

/**
 * Sets video upload on cellular enabled value.
 * @param enabled value.
 */
+ (void)setVideoUploadOnCellularEnabled:(BOOL)enabled;

@end
