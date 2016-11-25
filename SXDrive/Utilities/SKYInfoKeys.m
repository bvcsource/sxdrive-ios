//
//  SKYInfoKeys.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYInfoKeys.h"

NSString * const SKYCloudSKYPrefix = @"SKY ";
NSString * const SKYInfoKeyForPath = @"SKYInfoKeyForPath";
NSString * const SKYInfoKeyForDownloadProgress = @"SKYInfoKeyForDownloadProgress";
NSString * const SKYInfoKeyForUploadProgress = @"SKYInfoKeyForUploadProgress";
NSString * const SKYInfoKeyShowFavourites = @"SKYInfoKeyShowFavourites";
NSString * const SKYInfoKeyForItem = @"SKYInfoKeyForItem";
NSString * const SKYInfoKeyForItemDirectory = @"SKYInfoKeyForItemDirectory";
NSString * const SKYInfoKeyForItems = @"SKYInfoKeyForItems";
NSString * const SKYInfoKeyForURL = @"SKYInfoKeyForURL";
NSString * const SKYInfoKeyForFileURL = @"SKYInfoKeyForFileURL";
NSString * const SKYInfoKeyForImage = @"SKYInfoKeyForImage";
NSString * const SKYInfoKeyForImageType = @"SKYInfoKeyForImageType";
NSString * const SKYInfoKeyForAssetDate = @"SKYInfoKeyForAssetDate";
NSString * const SKYInfoKeyForMovieURL = @"SKYInfoKeyForMovieURL";
NSString * const SKYInfoKeyManagedObjectContext = @"SKYInfoKeyManagedObjectContext";
NSString * const SKYInfoKeyForApplicationMainWindow = @"SKYInfoKeyForApplicationMainWindow";
NSString * const SKYInfoKeyForPasscodeStage = @"SKYInfoKeyForPasscodeStage";
NSString * const SKYInfoKeyForBrowserMode = @"SKYInfoKeyForBrowserMode";
NSString * const SKYInfoKeyForImpoerFileControllerReference = @"SKYInfoKeyForImpoerFileControllerReference";
NSString * const SKYInfoKeyForBackgroundUploadSettingsControllerReference = @"SKYInfoKeyForBackgroundUploadSettingsControllerReference";
NSString * const SKYInfoKeyForFileName = @"SKYInfoKeyForFileName";
NSString * const SKYInfoKeyForImportFile = @"SKYInfoKeyForImportFile";
NSString * const SKYInfoKeyForAnimation = @"SKYInfoKeyForAnimation";

#pragma mark - SKYCloud keys

NSString * const SKYCloudUploadTokenKey = @"uploadToken";
NSString * const SKYCloudUploadData = @"uploadData";
NSString * const SKYCloudRequestId = @"requestId";
NSString * const SKYCloudRequestStatus = @"requestStatus";
NSString * const SKYCloudMaxPollInterval = @"maxPollInterval";
NSString * const SKYCloudMinPollInterval = @"minPollInterval";
NSString * const SKYCloudVolumeList = @"volumeList";
NSString * const SKYCloudFileList = @"fileList";
NSString * const SKYCloudFileData = @"fileData";
NSString * const SKYCloudFileBlockSize = @"blockSize";
NSString * const SKYCloudFileRevision = @"fileRevision";
NSString * const SKYCloudCreatedAt = @"createdAt";
NSString * const SKYCloudFileSize = @"fileSize";
NSString * const SKYCloudUsedSize = @"usedSize";
NSString * const SKYCloudFileNodeList = @"nodeList";
NSString * const SKYCloudVolumeVolumeMeta = @"volumeMeta";
NSString * const SKYCloudVolumeFilterActive = @"filterActive";
NSString * const SKYCloudFilePath = @"path";
NSString * const SKYCloudUserAccessKey = @"access_key";
NSString * const SKYCloudLinkExpireTime = @"expire_time";
NSString * const SKYCloudLinkPassword = @"password";
NSString * const SKYCloudLinkNotify = @"notify";
NSString * const SKYCloudSXClusterHeader = @"SX-Cluster";

#pragma mark - Property names

NSString * const SKYPropertyNameAccessRights = @"accessRights";
NSString * const SKYPropertyNameEverSynced = @"everSynced";
NSString * const SKYPropertyNameLoading = @"loading";
NSString * const SKYPropertyNameFilterActive = @"filterActive";
NSString * const SKYPropertyNamePublicLink = @"publicLink";

#pragma mark - Constants

NSString * const SKYConstantMethodGET = @"GET";
NSString * const SKYConstantMethodPUT = @"PUT";
NSString * const SKYConstantMethodDELETE = @"DELETE";
NSString * const SKYConstantMethodPOST = @"POST";
NSString * const SKYConstantReadAccessRight = @"read";
NSString * const SKYConstantWriteAccessRight = @"write";
NSString * const SKYConstantNewDirectoryHiddenFile = @".sxnewdir";
NSString * const SKYConstantPendingSyncToBeUploaded = @"to_be_uploaded";
NSString * const SKYConstantPendingSyncToBeDeleted = @"to_be_deleted";
NSString * const SKYConstantPhotoFilename = @"Photo";
NSString * const SKYConstantMovieFilename = @"Movie";
NSString * const SKYConstantStatusOK = @"OK";

#pragma mark - User defaults

NSString * const SKYUserDefaultsForConfigSortingType = @"SKYUserDefaultsForConfigSortingType";
NSString * const SKYUserDefaultsForConfigCacheSize = @"SKYUserDefaultsForConfigCacheSize";
NSString * const SKYUserDefaultsHasEverLoggedIn = @"SKYUserDefaultsHasEverLoggedIn";
NSString * const SKYUserDefaultsBigFilesWarningEnabled = @"SKYUserDefaultsBigFilesWarningEnabled";
NSString * const SKYUserDefaultsLogEnabled = @"SKYUserDefaultsLogEnabled";
NSString * const SKYUserDefaultsShowPassword = @"SKYUserDefaultsShowPassword";
NSString * const SKYUserDefaultsImportFileURL = @"SKYUserDefaultsImportFileURL";
NSString * const SKYUserDefaultsImportFileItemsURIArray = @"SKYUserDefaultsImportFileItemsURIArray";
NSString * const SKYUserDefaultsLaunchDate = @"SKYUserDefaultsLaunchDate";
NSString * const SKYUserDefaultsTouchIDEnabled = @"SKYUserDefaultsTouchIDEnabled";
NSString * const SKYUserDefaultsInstallationDate = @"SKYUserDefaultsInstallationDate";
NSString * const SKYUserDefaultsMediaUploadEnabled = @"SKYUserDefaultsMediaUploadEnabled";
NSString * const SKYUserDefaultsLastMediaUploadDate = @"SKYUserDefaultsLastMediaUploadDate";
NSString * const SKYUserDefaultsMediaUploadDestinationItem = @"SKYUserDefaultsMediaUploadDestinationItem";
NSString * const SKYUserDefaultsPhotoUploadOnCellularEnabled = @"SKYUserDefaultsPhotoUploadOnCellularEnabled";
NSString * const SKYUserDefaultsVideoUploadOnCellularEnabled = @"SKYUserDefaultsVideoUploadOnCellularEnabled";

#pragma mark - Browser modes

NSString * const SKYBrowserModeDefault = @"SKYBrowserModeDefault";
NSString * const SKYBrowserModeChooseDirectory = @"SKYBrowserModeChooseDirectory";

#pragma mark - Uploads modes

NSString * const SKYUploadsModeBuiltIn = @"SKYUploadsModeBuiltIn";
NSString * const SKYUploadsModeSummary = @"SKYUploadsModeSummary";
