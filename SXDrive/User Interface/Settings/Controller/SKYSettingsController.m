//
//  SKYSettingsController.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSettingsController.h"

#import "NSByteCountFormatter+Extras.h"
#import "SKYConfig.h"
#import "SKYNotificationNames.h"
#import "UIDevice+ScreenSize.h"

@interface SKYSettingsController () <UIActionSheetDelegate>

/**
 * Network usage observer.
 */
@property (nonatomic, weak) NSObject *networkUsageObserver;

/**
 * Disk usage observer.
 */
@property (nonatomic, weak) NSObject *diskUsageObserver;

/**
 * Property for accessing the settings view.
 */
@property (weak, nonatomic, readonly) UITableView <SKYSettingsView> *settingsView;

/**
 * Property for accessing the settings behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYSettingsBehaviour> settingsBehaviour;

/**
 * Max cache label for easy reload.
 */
@property (nonatomic, weak) UILabel *maxCacheLabel;

@end

@implementation SKYSettingsController

- (instancetype)initWithSettingsView:(UITableView <SKYSettingsView> *)settingsView settingsBehaviour:(id <SKYSettingsBehaviour>)settingsBehaviour
{
	self = [super initWithView:settingsView behaviour:settingsBehaviour];
	
	if (self) {
		self.navigationItem.title = NSLocalizedString(@"Settings", @"Title for settings screen.");
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeSettings;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.settingsView refreshDiskUsageSection];
	self.diskUsageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SKYDiskUsageDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		[self.settingsView refreshDiskUsageSection];
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self.networkUsageObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:self.diskUsageObserver];
}

#pragma mark - SKYSettingsBehaviourPresenter

- (void)updatePasscodeStateWithNewEnabled:(BOOL)enabled
{
	[self.settingsView refreshPasscodeCell];
}

#pragma mark - SKYSettingsViewDataSource

- (BOOL)isPasscodeEnabled
{
	return [self.settingsBehaviour isPasscodeEnabled];
}

- (BOOL)isTouchIDEnabled {
    return [self.settingsBehaviour isTouchIDEnabled];
}

- (NSString *)softwareVersion
{
	return [self.settingsBehaviour softwareVersion];
}

- (NSString *)totalDataSizeUploadedFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalDataSizeUploaded].unsignedLongLongValue];

}

- (NSString *)totalDataSizeDownloadedFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalDataSizeDownloaded].unsignedLongLongValue];
}

- (NSString *)pendingUploadSizeFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour pendingUploadSize].unsignedLongLongValue];
}

- (NSString *)favouritesSizeFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour favouritesSize].unsignedLongLongValue];
}

- (NSString *)ordinarySizeFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour ordinarySize].unsignedLongLongValue];
}

- (NSString *)indexSizeFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour indexSize].unsignedLongLongValue];
}

- (NSString *)totalSizeFormatted
{
	return [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalSize].unsignedLongLongValue];
}

- (double)maxCacheSize
{
	return [self.settingsBehaviour maxCacheSize];
}

- (BOOL)bigFilesWarningEnabled
{
	return [SKYConfig bigFilesWarningEnabled];
}

#pragma mark - SKYSettingsViewInteractionDelegate

- (void)userWantsToLogOut {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure you want to log out?", @"Confirmation question for logout.") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.settingsBehaviour logOutUser];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)userWantsToEditPasscode
{
	if ([self.settingsBehaviour isPasscodeEnabled] == YES) {
		NSString *editPasscodeText = NSLocalizedString(@"Change passcode", @"Title of button for changing passcode.");
		NSString *offPasscodeText = NSLocalizedString(@"Turn passcode off", @"Title of button for turning passcode off.");
		UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Generic cancel")
										  destructiveButtonTitle:nil
											   otherButtonTitles:editPasscodeText, offPasscodeText, nil];
		[as showInView:self.settingsView];
	}
	else {
		[self.settingsBehaviour createPasscode];
	}
}

- (void)userWantsToSeeAbout
{
	[self.settingsBehaviour showAboutWebsite];
	[self.settingsView deselectSelectedCellAnimated:YES];
}

- (void)userWantsToSeeTechSupport
{
	[self.settingsBehaviour showTechSupportWebsite];
	[self.settingsView deselectSelectedCellAnimated:YES];
}

- (void)userWantsToResetNetworkStatistics
{
	[self.settingsView deselectSelectedCellAnimated:YES];
	
	NSString *localizedButtonTitle = NSLocalizedString(@"Reset statistics", @"Title for reset statistics confirmation button.");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:[[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad ? UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:localizedButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self.settingsBehaviour resetNetworkStatistics];
		[self.settingsView reloadData];
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)userWantsToChangeMaxCacheValue:(double)value
{
	[self.settingsBehaviour setMaxCacheSize:value];
	[self.settingsView refreshMaxCacheLabel];
}

- (void)userWantsToChangeBigFilesWarningEnabled:(BOOL)enabled
{
	[SKYConfig setBigFilesWarningEnabled:enabled];
}

- (void)userWantsToGoToBackgroundUploadSettings {
    [self.settingsBehaviour goToBackgroundUploadSettings];
}

- (void)userWantsToGoToAdvancedSettings {
    [self.settingsBehaviour goToAdvancedSettings];
}

- (void)showAlert:(UIAlertController *)alertController {
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self.settingsBehaviour changePasscode];
	}
	else if (buttonIndex == 1) {
		[self.settingsBehaviour deletePasscode];
	}
	else {
		[self.settingsView deselectSelectedCellAnimated:YES];
	}
}

#pragma mark - Convenience accessors

- (UIView <SKYSettingsView> *)settingsView
{
	return (UIView <SKYSettingsView> *)self.baseView;
}

- (id <SKYSettingsBehaviour>)settingsBehaviour
{
	return (id <SKYSettingsBehaviour>)self.baseBehaviour;
}

@end
