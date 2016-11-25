//
//  SKYSettingsBehaviour.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYDiskManager.h"
#import "SKYUser.h"
#import "SKYNetworkManager.h"
#import "SKYPersistence.h"

/**
 * Presenter for the settings behaviour.
 */
@protocol SKYSettingsBehaviourPresenter <SKYBaseBehaviourPresenter>

@optional
/**
 * Asks the presenter to update passcode presentation.
 *
 * @param enabled YES if passcode is now enabled, NO otherwise.
 */
- (void)updatePasscodeStateWithNewEnabled:(BOOL)enabled;

@end

/**
 * Protocol of settings behaviour.
 */
@protocol SKYSettingsBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the settings behaviour.
 */
@property (nonatomic, weak) id <SKYSettingsBehaviourPresenter> presenter;

/**
 * User.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Network manager.
 */
@property (nonatomic, strong) id <SKYNetworkManager> networkManager;

/**
 * Disk manager.
 */
@property (nonatomic, strong) id <SKYDiskManager> diskManager;

@optional
/**
 * Returns software version.
 * @return Software version.
 */
- (NSString *)softwareVersion;

/**
 * Returns total size of uploaded data.
 * @return Total size of uploaded data.
 */
- (NSNumber *)totalDataSizeUploaded;

/**
 * Returns total size of downloaded data.
 * @return Total size of downloaded data.
 */
- (NSNumber *)totalDataSizeDownloaded;

/**
 * Returns size of pending upload files.
 * @return Size of pending upload files.
 */
- (NSNumber *)pendingUploadSize;

/**
 * Returns Size of favourites upload files.
 * @return Size of favourites upload files.
 */
- (NSNumber *)favouritesSize;

/**
 * Returns size of ordinary upload files.
 * @return Size of ordinary upload files.
 */
- (NSNumber *)ordinarySize;

/**
 * Returns size of index.
 * @return Size of index.
 */
- (NSNumber *)indexSize;

/**
 * Returns total size.
 * @return Total size.
 */
- (NSNumber *)totalSize;

/**
 * Returns passcode enabled state.
 *
 * @return YES if passcode is enabled, NO otherwise.
 */
- (BOOL)isPasscodeEnabled;

/**
 * Returns touch ID enabled state.
 * @return YES if touch ID is enabled, NO otherwise.
 */
- (BOOL)isTouchIDEnabled;

/**
 * Logs out user.
 */
- (void)logOutUser;

/**
 * Called when user wants to create passcode.
 */
- (void)createPasscode;

/**
 * Called when user wants to change the passcode.
 */
- (void)changePasscode;

/**
 * Called when user wants to disable the passcode.
 */
- (void)deletePasscode;

/**
 * Resets network statistics.
 */
- (void)resetNetworkStatistics;

/**
 * Presents about website in external window.
 */
- (void)showAboutWebsite;

/**
 * Presents tech support website in external window.
 */
- (void)showTechSupportWebsite;

/**
 * Removes cache.
 */
- (void)removeCache;

/**
 * Sets max cache size.
 * @param cacheSize New max cache size.
 */
- (void)setMaxCacheSize:(double)cacheSize;

/**
 * Returns max cache size.
 * @return Max cache size.
 */
- (double)maxCacheSize;

/**
 * Sends user to auto sync camera roll settings
 */
- (void)goToBackgroundUploadSettings;

/**
 * Sends user to advanced settings
 */
- (void)goToAdvancedSettings;

/**
 * Choose a different directory for media background upload.
 * @param viewController BackgroundUploadSettingsViewController instance.
 */
- (void)chooseDifferentDirectory:(UIViewController *)fromVC;

@end
