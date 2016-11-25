//
//  SKYInfoKeys.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * `SKY` prefix used in authentication key followed by the space character.
 */
extern NSString * const SKYCloudSKYPrefix;

/**
 * Key for storing path, holds NSString object.
 */
extern NSString * const SKYInfoKeyForPath;

/**
 * Key for storing download progress, holds NSNumber object.
 */
extern NSString * const SKYInfoKeyForDownloadProgress;

/**
 * Key for storing upload progress, holds NSNumber object.
 */
extern NSString * const SKYInfoKeyForUploadProgress;

/**
 * Key for storing info if favourites is the source location, holds NSObject (to be casted to bool).
 */
extern NSString * const SKYInfoKeyShowFavourites;

/**
 * Key for storing item, holds SKYItem object.
 */
extern NSString * const SKYInfoKeyForItem;

/**
 * Key for storing directory (Item), holds SKYItem object.
 */
extern NSString * const SKYInfoKeyForItemDirectory;

/**
 * Key for storing items, holds NSArray of SKYItem objects.
 */
extern NSString * const SKYInfoKeyForItems;

/**
 * Key for storing URL, holds NSURL object.
 */
extern NSString * const SKYInfoKeyForURL;

/**
 * Key for storing file URL, holds NSURL object.
 */
extern NSString * const SKYInfoKeyForFileURL;

/**
 * Key for storing image, holds UIImage object.
 */
extern NSString * const SKYInfoKeyForImage;

/**
 * Key for storing image type, holds NSString object.
 */
extern NSString * const SKYInfoKeyForImageType;

/**
 * Key for storing image or video date, holds NSDate object.
 */
extern NSString * const SKYInfoKeyForAssetDate;

/**
 * Key for storing movie URL, holds NSURL object.
 */
extern NSString * const SKYInfoKeyForMovieURL;

/**
 * Key for storing managed object context, holds NSManagedObjectContext object.
 */
extern NSString * const SKYInfoKeyManagedObjectContext;

/**
 * Key for storing application's main window, holds UIWindow object.
 */
extern NSString * const SKYInfoKeyForApplicationMainWindow;

/**
 * Key for storing passcode stage, holds SKYPasscodeStage wrapped in NSNumber object.
 */
extern NSString * const SKYInfoKeyForPasscodeStage;

/**
 * Key for storing browser mode, holds NSString object.
 */
extern NSString * const SKYInfoKeyForBrowserMode;

/**
 * Key for storing import file controller reference, holds id<SKYImportFileBehaviourPresenter> object.
 */
extern NSString * const SKYInfoKeyForImpoerFileControllerReference;

/**
 * Key for storing background upload settings controller reference, holds SKYBackgroundUploadSettingsController object.
 */
extern NSString * const SKYInfoKeyForBackgroundUploadSettingsControllerReference;

/**
 * Key for storing file name while import file, hold NSString object.
 */
extern NSString * const SKYInfoKeyForFileName;

/**
 * Key for storing import file, hold NSDictionary object.
 */
extern NSString * const SKYInfoKeyForImportFile;

/**
 * Key for storing bool value that enables/disables animation, hold NSNumber object.
 */
extern NSString * const SKYInfoKeyForAnimation;

#pragma mark - SKYCloud keys

/**
 * Key for `uploadToken`, holds NSString object.
 */
extern NSString * const SKYCloudUploadTokenKey;

/**
 * Key for `uploadData`, hold NSDictionary object.
 */
extern NSString * const SKYCloudUploadData;

/**
 * Key for `requestId`, holds NSString object.
 */
extern NSString * const SKYCloudRequestId;

/**
 * Key for `requestStatus`, holds NSString object.
 */
extern NSString * const SKYCloudRequestStatus;

/**
 * Key for `maxPollInterval`, holds NSNumber object.
 */
extern NSString * const SKYCloudMaxPollInterval;

/**
 * Key for `minPollInterval`, holds NSNumber object.
 */
extern NSString * const SKYCloudMinPollInterval;

/**
 * Key for `volumeList`, holds NSDictionary object.
 */
extern NSString * const SKYCloudVolumeList;

/**
 * Key for `fileList`, holds NSDictionary object.
 */
extern NSString * const SKYCloudFileList;

/**
 * Key for `fileData`, holds NSArray object.
 */
extern NSString * const SKYCloudFileData;

/**
 * Key for `blockSize`, holds NSNumber object.
 */
extern NSString * const SKYCloudFileBlockSize;

/**
 * Key for `fileRevision`, holds NSString object.
 */
extern NSString * const SKYCloudFileRevision;

/**
 * Key for `createdAt`, holds NSNumber object.
 */
extern NSString * const SKYCloudCreatedAt;

/**
 * Key for `fileSize`, holds NSNumber object.
 */
extern NSString * const SKYCloudFileSize;

/**
 * Key for `usedSize`, holds NSNumber object.
 */
extern NSString * const SKYCloudUsedSize;

/**
 * Key for `nodeList`, holds NSArray of NSString object.
 */
extern NSString * const SKYCloudFileNodeList;

/**
 * Key for `volumeMeta`, holds NSDictionary object.
 */
extern NSString * const SKYCloudVolumeVolumeMeta;

/**
 * Key for `filterActive`, holds NSString object.
 */
extern NSString * const SKYCloudVolumeFilterActive;

/**
 * Key for `path`, holds NSString object.
 */
extern NSString * const SKYCloudFilePath;

/**
 * Key for `access_key`, holds NSString object.
 */
extern NSString * const SKYCloudUserAccessKey;

/**
 * Key for `expire_time`, holds NSNumber object.
 */
extern NSString * const SKYCloudLinkExpireTime;

/**
 * Key for `password`, holds NSString object.
 */
extern NSString * const SKYCloudLinkPassword;

/**
 * Key for `notify`, holds NSString object.
 */
extern NSString * const SKYCloudLinkNotify;

/**
 * Key for `SX-Cluster` header, holds NSString object.
 */
extern NSString * const SKYCloudSXClusterHeader;

#pragma mark - Property names

/**
 * Property for access rights, holds NSArray object (of strings).
 */
extern NSString * const SKYPropertyNameAccessRights;

/**
 * Property for keeping information if item has been ever synced.
 * @note Currently used only for directories.
 */
extern NSString * const SKYPropertyNameEverSynced;

/**
 * Property for keeping information if item is currently being loaded.
 * @note Currently used only for directories.
 */
extern NSString * const SKYPropertyNameLoading;

/**
 * Filter UUID for encrypted volumes.
 * If nil, then volume is not encrypted.
 */
extern NSString * const SKYPropertyNameFilterActive;

/**
 * File public link.
 * If nil, then public link is not generated yet.
 */
extern NSString * const SKYPropertyNamePublicLink;

#pragma mark - Constants

/**
 * GET method constant.
 */
extern NSString * const SKYConstantMethodGET;

/**
 * PUT method constant.
 */
extern NSString * const SKYConstantMethodPUT;

/**
 * DELETE method constant.
 */
extern NSString * const SKYConstantMethodDELETE;

/**
 * POST method constant.
 */
extern NSString * const SKYConstantMethodPOST;

/**
 * Read access right constant.
 */
extern NSString * const SKYConstantReadAccessRight;

/**
 * Write access right constant.
 */
extern NSString * const SKYConstantWriteAccessRight;

/**
 * Name of the invisible file added to mimic presence of dictionaries.
 */
extern NSString * const SKYConstantNewDirectoryHiddenFile;

/**
 * Name of the `to_be_uploaded` pending sync.
 */
extern NSString * const SKYConstantPendingSyncToBeUploaded;

/**
 * Name of the `to_be_deleted` pending sync.
 */
extern NSString * const SKYConstantPendingSyncToBeDeleted;

/**
 * Name of the photo files added from library.
 * @note There is no such thing like original photo filename.
 * @note The extension will be added to that name.
 */
extern NSString * const SKYConstantPhotoFilename;

/**
 * Name of the movie files added from library.
 * @note There is no such thing like original movie filename.
 * @note The extension will be added to that name.
 */
extern NSString * const SKYConstantMovieFilename;

/**
 * Name of the `OK` status.
 */
extern NSString * const SKYConstantStatusOK;

#pragma mark - User defaults

/**
 * Name of the entry in user details where sorting preference is stored.
 */
extern NSString * const SKYUserDefaultsForConfigSortingType;

/**
 * Name of the entry in user details where max cache size is stored.
 */
extern NSString * const SKYUserDefaultsForConfigCacheSize;

/**
 * Name of the entry in user details where application stores if user has ever been logged into this app installation.
 * @note This is needed because Keychain persists even when app is uninstalled.
 */
extern NSString * const SKYUserDefaultsHasEverLoggedIn;

/**
 * Name of the entry in user details where big files warning is stored.
 */
extern NSString * const SKYUserDefaultsBigFilesWarningEnabled;

/**
 * Name of the entry in user details where log enabled is stored.
 */
extern NSString * const SKYUserDefaultsLogEnabled;

/**
 * Name of the entry in user details where show password is stored.
 */
extern NSString * const SKYUserDefaultsShowPassword;

/**
 * Name of the entry in user details where import file URL is stored.
 */
extern NSString * const SKYUserDefaultsImportFileURL;

/**
 * Name of the entry in user details where import file destination path is stored.
 */
extern NSString * const SKYUserDefaultsImportFileItemsURIArray;

/**
 * Name of the entry in user details where application launch date is stored.
 */
extern NSString * const SKYUserDefaultsLaunchDate;

/**
 * Name of the entry in user details where touch ID enabled value is stored.
 */
extern NSString * const SKYUserDefaultsTouchIDEnabled;

/**
 * Name of the entry in user details where application installation date values is stored.
 */
extern NSString * const SKYUserDefaultsInstallationDate;

/**
 * Name of the entry in user details where background media upload enabled values is stored.
 */
extern NSString * const SKYUserDefaultsMediaUploadEnabled;

/**
 * Name of the entry in user details where date value of the last uploaded photo or movie is stored.
 */
extern NSString * const SKYUserDefaultsLastMediaUploadDate;

/**
 * Name of the entry in user details where media uploads destination SKYItem object is stored.
 */
extern NSString * const SKYUserDefaultsMediaUploadDestinationItem;

/**
 * Name of the entry in user details where background photo upload on cellular enabled value is stored.
 */
extern NSString * const SKYUserDefaultsPhotoUploadOnCellularEnabled;

/**
 * Name of the entry in user details where background video upload on cellular enabled value is stored.
 */
extern NSString * const SKYUserDefaultsVideoUploadOnCellularEnabled;

#pragma mark - Browser modes

/*
 * Default browser mode.
 */
extern NSString * const SKYBrowserModeDefault;

/*
 * Browser mode that allows to choose directory.
 */
extern NSString * const SKYBrowserModeChooseDirectory;

#pragma mark - Uploads modes

/*
 * Default uploads mode. Controller is built into SKYBrowseDirectoryController.
 */
extern NSString * const SKYUploadsModeBuiltIn;

/*
 * Standalone uploads summary represented at the second tab in the main screen.
 */
extern NSString * const SKYUploadsModeSummary;
