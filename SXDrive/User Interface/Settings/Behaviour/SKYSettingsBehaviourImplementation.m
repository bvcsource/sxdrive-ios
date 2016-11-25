//
//  SKYSettingsBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSettingsBehaviourImplementation.h"

#import "SKYConfig.h"
#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"
#import "SKYPasscodeStageEnum.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"

@interface SKYSettingsBehaviourImplementation ()

@end

@implementation SKYSettingsBehaviourImplementation

@synthesize user = _user;
@synthesize networkManager = _networkManager;
@synthesize diskManager = _diskManager;
@synthesize persistence = _persistence;

- (void)processInfo:(NSDictionary *)info
{
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYUserPasscodeDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		[self.presenter updatePasscodeStateWithNewEnabled:[self.user isPasscodeProtected]];
	}];
}

- (NSString *)softwareVersion
{
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *localizedVersion = NSLocalizedString(@"Version", @"Version on settings screen.");
	NSString *versionString = [NSString stringWithFormat:@"%@: %@ (%@)", localizedVersion, appVersion, appBuild];
	
	return versionString;
}

- (NSNumber *)totalDataSizeUploaded
{
	return [NSNumber numberWithUnsignedLongLong:[self.networkManager requestsTotalSize]];
}

- (NSNumber *)totalDataSizeDownloaded
{
	return [NSNumber numberWithUnsignedLongLong:[self.networkManager responsesTotalSize]];
}

- (NSNumber *)pendingUploadSize
{
	[self.diskManager recalculateDiskUsage];
	
	return [NSNumber numberWithUnsignedLongLong:[self.diskManager pendingUploadsDiskUsage]];
}

- (NSNumber *)favouritesSize
{
	[self.diskManager recalculateDiskUsage];
	
	return [NSNumber numberWithUnsignedLongLong:[self.diskManager favouritesDiskUsage]];
}

- (NSNumber *)ordinarySize
{
	[self.diskManager recalculateDiskUsage];
	
	return [NSNumber numberWithUnsignedLongLong:[self.diskManager cacheDiskUsage]];
}

- (NSNumber *)indexSize
{
	[self.diskManager recalculateDiskUsage];
	
	return [NSNumber numberWithUnsignedLongLong:[self.diskManager indexDiskUsage]];
}

- (NSNumber *)totalSize
{
	[self.diskManager recalculateDiskUsage];
	
	return [NSNumber numberWithUnsignedLongLong:[self.diskManager totalDiskUsage]];
}

- (void)logOutUser
{
	[self.user logoutUser];
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeLogin];
}

- (BOOL)isPasscodeEnabled
{
	return ([self.user isPasscodeProtected] == YES);
}

- (BOOL)isTouchIDEnabled {
    return [self.user isTouchIDEnabled];
}

- (void)createPasscode
{
	NSDictionary *info = @{SKYInfoKeyForPasscodeStage: @(SKYPasscodeStageCreate)};
	
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypePasscode info:info];
}

- (void)changePasscode
{
	NSDictionary *info = @{SKYInfoKeyForPasscodeStage: @(SKYPasscodeStageChange)};
	
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypePasscode info:info];
}

- (void)deletePasscode
{
	NSDictionary *info = @{SKYInfoKeyForPasscodeStage: @(SKYPasscodeStageDelete)};
	
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypePasscode info:info];
}

- (void)resetNetworkStatistics
{
	[self.networkManager resetStatistics];
}

- (void)showAboutWebsite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skylable.com/company"]];
}

- (void)showTechSupportWebsite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skylable.com/support"]];
}

- (void)removeCache
{
	[self.diskManager removeCache];
}

- (void)setMaxCacheSize:(double)cacheSize
{
	[SKYConfig setMaxCacheSize:cacheSize];
}

- (double)maxCacheSize
{
	return [SKYConfig maxCacheSize];
}

- (void)goToBackgroundUploadSettings {
    [self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeBackgroundUploadSettings];
}

- (void)goToAdvancedSettings {
    [self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeAdvancedSettings];
}

- (void)chooseDifferentDirectory:(UIViewController *)fromVC {
    [self.viewNavigator navigateFromBackgroundUploadSettingsControllerToVolumesController:fromVC];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
