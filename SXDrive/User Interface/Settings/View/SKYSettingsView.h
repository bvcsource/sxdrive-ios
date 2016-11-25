//
//  SKYSettingsView.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

/**
 * Delegate for handling view events.
 */
@protocol SKYSettingsViewInteractionDelegate <NSObject>

/**
 * Called when user wants to log out.
 */
- (void)userWantsToLogOut;

/**
 * Called when user wants to edit passcode (create it, change it or delete it).
 */
- (void)userWantsToEditPasscode;

/**
 * Called when user presses about cell.
 */
- (void)userWantsToSeeAbout;

/**
 * Called when user press tech support cell.
 */
- (void)userWantsToSeeTechSupport;

/**
 * Called when user presses reset network statistics cell.
 */
- (void)userWantsToResetNetworkStatistics;

/**
 * Called when user changes the max cache value.
 * @param value Requested value.
 */
- (void)userWantsToChangeMaxCacheValue:(double)value;

/**
 * Called when user changes the big files warning.
 * @param enabled Enabled/Disabled.
 */
- (void)userWantsToChangeBigFilesWarningEnabled:(BOOL)enabled;

/**
 * Called when user presses auto sync camera roll settings cell.
 */
- (void)userWantsToGoToBackgroundUploadSettings;

/**
 * Called when user presses advanced settings cell.
 */
- (void)userWantsToGoToAdvancedSettings;

/**
 * Called in order to show alert controller.
 */
- (void)showAlert:(UIAlertController *)alertController;

@end

/**
 * Data source for settings view.
 */
@protocol SKYSettingsViewDataSource <NSObject>

/**
 * Tells if passcode is enabled.
 * @return YES if passcode is enabled, NO otherwise.
 */
- (BOOL)isPasscodeEnabled;

/**
 * Tells if touch ID is enabled.
 * @return YES if touch ID is enabled, NO otherwise.
 */
- (BOOL)isTouchIDEnabled;

/**
 * Returns software version.
 * @return Software version.
 */
- (NSString *)softwareVersion;

/**
 * Returns formatted total size of uploaded data.
 * @return Formatted total size of uploaded data.
 */
- (NSString *)totalDataSizeUploadedFormatted;

/**
 * Returns formatted total size of downloaded data.
 * @return Formatted total size of downloaded data.
 */
- (NSString *)totalDataSizeDownloadedFormatted;

/**
 * Returns formatted size of pending upload files.
 * @return Formatted size of pending upload files.
 */
- (NSString *)pendingUploadSizeFormatted;

/**
 * Returns formatted size of favourites upload files.
 * @return Formatted size of favourites upload files.
 */
- (NSString *)favouritesSizeFormatted;

/**
 * Returns formatted size of ordinary upload files.
 * @return Formatted size of ordinary upload files.
 */
- (NSString *)ordinarySizeFormatted;

/**
 * Returns formatted size of index.
 * @return Formatted size of index.
 */
- (NSString *)indexSizeFormatted;

/**
 * Returns total formatted size.
 * @return Total formatted size.
 */
- (NSString *)totalSizeFormatted;

/**
 * Returns max cache size.
 * @return Max cache size.
 */
- (double)maxCacheSize;

/**
 * Returns state for big files warning enabled.
 * @return State for big files warning enabled.
 */
- (BOOL)bigFilesWarningEnabled;

@end

/**
 * Protocol of settings view.
 */
@protocol SKYSettingsView <SKYBaseTableView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYSettingsViewInteractionDelegate> interactionDelegate;

/**
 * Data source.
 */
@property (nonatomic, weak) id <SKYSettingsViewDataSource> settingsDataSource;

/**
 * Refreshes pascode cell.
 */
- (void)refreshPasscodeCell;

/**
 * Refreshes disk usage section.
 */
- (void)refreshDiskUsageSection;

/**
 * Refreshes max cache label.
 */
- (void)refreshMaxCacheLabel;

@end
