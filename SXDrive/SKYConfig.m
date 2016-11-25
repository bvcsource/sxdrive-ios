//
//  SKYConfig.m
//  SXDrive
//
//  Created by Skylable on 02/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYConfig.h"

#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"

NSTimeInterval const SKYConfigRefreshKeptInSyncPathTimeInterval = 60.f;
NSTimeInterval const SKYConfigRefreshFavouritesTimeInterval = 30.f;
NSTimeInterval const SKYConfigTimeIntervalForPasscodeReentry = 5.f;
NSTimeInterval const SKYConfigMinimumTimeIntervalForNoInternetSmartAlert = 60.f;
double const SKYConfigDefaultMaxCacheSize = 50000000;
double const SKYConfigMaxMaxCacheSize = 4000000000;
double const SKYConfigMinMaxCacheSize = 0;

@implementation SKYConfig

+ (void)load
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SKYFirstSetupDone"] == NO) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SKYFirstSetupDone"];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SKYUserDefaultsBigFilesWarningEnabled];
        [[NSUserDefaults standardUserDefaults] setDouble:SKYConfigDefaultMaxCacheSize forKey:SKYUserDefaultsForConfigCacheSize];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SKYUserDefaultsLogEnabled];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SKYUserDefaultsShowPassword];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (SKYConfigSortingType)prefferedSortingType;
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:SKYUserDefaultsForConfigSortingType];
}

+ (void)setPreferredSortingType:(SKYConfigSortingType)sortingType
{
	[[NSUserDefaults standardUserDefaults] setInteger:sortingType forKey:SKYUserDefaultsForConfigSortingType];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYSortingTypeDidChangeNotification object:nil];
}

+ (void)setMaxCacheSize:(double)cacheSize
{
	if (cacheSize < SKYConfigMinMaxCacheSize) {
		cacheSize = SKYConfigMinMaxCacheSize;
	}
    if (cacheSize > SKYConfigMaxMaxCacheSize) {
        cacheSize = SKYConfigMaxMaxCacheSize;
    }
	
	[[NSUserDefaults standardUserDefaults] setDouble:cacheSize forKey:SKYUserDefaultsForConfigCacheSize];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (double)maxCacheSize
{
	double cacheSize = [[NSUserDefaults standardUserDefaults] doubleForKey:SKYUserDefaultsForConfigCacheSize];
	
	return cacheSize;
}

+ (BOOL)bigFilesWarningEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsBigFilesWarningEnabled];
}

+ (void)setBigFilesWarningEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsBigFilesWarningEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)logEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsLogEnabled];
}

+ (void)setLogEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsLogEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)showPasswordEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsShowPassword];
}

+ (void)setShowPasswordEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsShowPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSURL *)importFileURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:SKYUserDefaultsImportFileURL];
}

+ (void)setImportFileURL:(NSURL *)url {
    [[NSUserDefaults standardUserDefaults] setURL:url forKey:SKYUserDefaultsImportFileURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeImportFileURL {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:SKYUserDefaultsImportFileURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)importFileItemsURIArray {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *uriString in [[NSUserDefaults standardUserDefaults] objectForKey:SKYUserDefaultsImportFileItemsURIArray]) {
        [tempArray addObject:[NSURL URLWithString:uriString]];
    }
    return tempArray;
}

+ (void)setImportFileItemsURIArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSURL *uri in array) {
        [tempArray addObject:[uri absoluteString]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:SKYUserDefaultsImportFileItemsURIArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)applicationLaunchDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SKYUserDefaultsLaunchDate];
}

+ (void)setApplicationLaunchDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:SKYUserDefaultsLaunchDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)touchIDEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsTouchIDEnabled];
}

+ (void)setTouchIDEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsTouchIDEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)applicationInstallationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SKYUserDefaultsInstallationDate];
}

+ (void)setApplicationInstallationDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:SKYUserDefaultsInstallationDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)mediaUploadEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsMediaUploadEnabled];
}

+ (void)setMediaUploadEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsMediaUploadEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)lastMediaUploadDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SKYUserDefaultsLastMediaUploadDate];
}

+ (void)setLastMediaUploadDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:SKYUserDefaultsLastMediaUploadDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)mediaUploadDestinationPath {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SKYUserDefaultsMediaUploadDestinationItem];
}

+ (void)setMediaUploadDestinationPath:(NSString *)path {
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:SKYUserDefaultsMediaUploadDestinationItem];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)photoUploadOnCellularEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsPhotoUploadOnCellularEnabled];
}

+ (void)setPhotoUploadOnCellularEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsPhotoUploadOnCellularEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)videoUploadOnCellularEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsVideoUploadOnCellularEnabled];
}

+ (void)setVideoUploadOnCellularEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SKYUserDefaultsVideoUploadOnCellularEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end