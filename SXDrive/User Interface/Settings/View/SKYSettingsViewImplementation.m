//
//  SKYSettingsViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSettingsViewImplementation.h"

#import "SKYConfig.h"
#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"
#import "NSByteCountFormatter+Extras.h"
#import <LocalAuthentication/LocalAuthentication.h>

/**
 * Passcode section index.
 */
static NSInteger const SKYSettingsViewPasscodeSectionIndex = 0;

/**
 * Logout section index.
 */
static NSInteger const SKYSettingsViewLogoutSectionIndex = 1;

/**
 * Cache limit section index.
 */
static NSInteger const SKYSettingsViewCacheLimitSectionIndex = 3;

/**
 * Cache limit section index.
 */
static NSInteger const SKYSettingsViewBigFilesWarningSectionIndex = 4;

/**
 * Links section index.
 */
static NSInteger const SKYSettingsViewLinksSectionIndex = 2;

/**
 * Disk usage section index.
 */
static NSInteger const SKYSettingsViewDiskUsageSectionIndex = 5;

/**
 * Background upload settings section index.
 */
static NSInteger const SKYSettingsViewBackgroundUploadSettingsSectionIndex = 6;

/**
 * Advanced settings section index.
 */
static NSInteger const SKYSettingsViewAdvancedSettingsSectionIndex = 7;

@interface SKYSettingsViewImplementation () <UITableViewDelegate, UITableViewDataSource>

/**
 * Max cache label for easy refresh.
 */
@property (nonatomic, weak) UILabel *maxCacheLabel;

/**
 * Touch ID switch for easy update.
 */
@property (nonatomic, weak) UISwitch *touchIDSwitch;

/**
 * Called when user uses the stepper.
 * @param stepper Stepper.
 */
- (void)cacheLimitStepperChanged:(UIStepper *)stepper;

/**
 * Called when user uses the switch.
 * @param aSwitch Switch.
 */
- (void)bigFilesWarningSwitchChanged:(UISwitch *)aSwitch;

/**
 * Called when user uses the switch.
 * @param aSwitch Switch.
 */
- (void)touchIDSwitchChanged:(UISwitch *)aSwitch;

/**
 * Checks if touch ID can be used.
 * @return YES, if touch ID can be used, NO otherwise.
 */
- (BOOL)canUseTouchID;

@end

@implementation SKYSettingsViewImplementation

@synthesize interactionDelegate = _interactionDelegate;
@synthesize settingsDataSource = _settingsDataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	
	if (self) {
		self.delegate = self;
		self.dataSource = self;
		self.rowHeight = 44; // We are doing this because otherwise cells perform strange shrinking by themselves.
	}
	
	return self;
}

- (void)refreshPasscodeCell {
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([self.settingsDataSource isPasscodeEnabled] && [self canUseTouchID]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want to use Touch ID?", @"Touch ID on settings screen.") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Generic yes")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              self.touchIDSwitch.on = YES;
                                                              [self touchIDSwitchChanged:self.touchIDSwitch];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Generic no")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              self.touchIDSwitch.on = NO;
                                                              [self touchIDSwitchChanged:self.touchIDSwitch];
                                                          }]];
        [(NSObject *)self.interactionDelegate performSelector:@selector(showAlert:) withObject:alertController afterDelay:0.5];
    }
}

- (void)refreshDiskUsageSection
{
	[self reloadSections:[NSIndexSet indexSetWithIndex:SKYSettingsViewDiskUsageSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)cacheLimitStepperChanged:(UIStepper *)stepper
{
    if(stepper.value >= 1000000000)
        stepper.stepValue = 500000000;
    else if(stepper.value >= 500000000)
        stepper.stepValue = 250000000;
    else if(stepper.value >= 200000000)
        stepper.stepValue = 100000000;
    else
        stepper.stepValue = 50000000;

	[self.interactionDelegate userWantsToChangeMaxCacheValue:stepper.value];
}

- (void)refreshMaxCacheLabel
{
	self.maxCacheLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsDataSource maxCacheSize]];
}

- (void)bigFilesWarningSwitchChanged:(UISwitch *)aSwitch
{
	[self.interactionDelegate userWantsToChangeBigFilesWarningEnabled:aSwitch.on];
}

- (void)touchIDSwitchChanged:(UISwitch *)aSwitch {
    [SKYConfig setTouchIDEnabled:aSwitch.on];
}

-(BOOL)canUseTouchID {
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 0;
	
	if (section == SKYSettingsViewPasscodeSectionIndex) {
        if ([self.settingsDataSource isPasscodeEnabled] && [self canUseTouchID]) {
            rows = 2;
        } else {
            rows = 1;
        }
	}
	else if (section == SKYSettingsViewLogoutSectionIndex) {
		rows = 1;
	}
	else if (section == SKYSettingsViewLinksSectionIndex) {
		rows = 2;
	}
	else if (section == SKYSettingsViewDiskUsageSectionIndex) {
		rows = 1;
	}
	else if (section == SKYSettingsViewCacheLimitSectionIndex) {
		rows = 1;
	}
	else if (section == SKYSettingsViewBigFilesWarningSectionIndex) {
		rows = 1;
    }
    else if (section == SKYSettingsViewBackgroundUploadSettingsSectionIndex) {
        rows = 1;
    }
    else if (section == SKYSettingsViewAdvancedSettingsSectionIndex) {
        rows = 1;
    }
	
	return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
		cell.textLabel.font = [UIFont fontForStandardCellLabels];
		cell.detailTextLabel.font = [UIFont fontForDetailCellLabels];
	}
	
	cell.textLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.text = @"";
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryView = nil;
	
	if (self.maxCacheLabel == cell.textLabel) {
		self.maxCacheLabel = nil;
	}
	
	if (indexPath.section == SKYSettingsViewPasscodeSectionIndex) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"PIN code", @"PIN code on settings screen.");
		
            if ([self.settingsDataSource isPasscodeEnabled] == YES) {
                cell.detailTextLabel.text = NSLocalizedString(@"on", @"On state information next to passcode cell text.");
            }
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Use Touch ID", @"Touch ID on settings screen.");
            
            UISwitch *aSwitch = [UISwitch new];
            aSwitch.on = [self.settingsDataSource isTouchIDEnabled];
            [aSwitch addTarget:self action:@selector(touchIDSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = aSwitch;
            self.touchIDSwitch = (UISwitch *)cell.accessoryView;
        }
	}
	else if (indexPath.section == SKYSettingsViewLogoutSectionIndex) {
		cell.textLabel.textColor = [UIColor skyColorForLogoutText];
		cell.textLabel.text = NSLocalizedString(@"Logout", @"Logout on settings screen.");
	}
	else if (indexPath.section == SKYSettingsViewLinksSectionIndex) {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"About us", @"About us link on settings screen.");
		}
		else {
			cell.textLabel.text = NSLocalizedString(@"Tech support", @"Tech support link on settings screen.");
		}
	}
	else if (indexPath.section == SKYSettingsViewDiskUsageSectionIndex) {
        cell.textLabel.text = NSLocalizedString(@"Total disk usage", @"Total disk usage cell on settings screen.");
        cell.detailTextLabel.text = [self.settingsDataSource totalSizeFormatted];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == SKYSettingsViewCacheLimitSectionIndex) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		self.maxCacheLabel = cell.textLabel;
		
		[self refreshMaxCacheLabel];
		UIStepper *stepper = [UIStepper new];
		stepper.minimumValue = SKYConfigMinMaxCacheSize;
		stepper.maximumValue = SKYConfigMaxMaxCacheSize;
        stepper.stepValue = 50000000;
		stepper.value = [self.settingsDataSource maxCacheSize];
		[stepper addTarget:self action:@selector(cacheLimitStepperChanged:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = stepper;
	}
	else if (indexPath.section == SKYSettingsViewBigFilesWarningSectionIndex) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = NSLocalizedString(@"Warn when on cellular", @"Title for setting toggle to display warning when using cellular network.");
		
		UISwitch *aSwitch = [UISwitch new];
		aSwitch.on = [self.settingsDataSource bigFilesWarningEnabled];
		[aSwitch addTarget:self action:@selector(bigFilesWarningSwitchChanged:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = aSwitch;
	}
    else if (indexPath.section == SKYSettingsViewBackgroundUploadSettingsSectionIndex) {
        cell.textLabel.text = NSLocalizedString(@"Auto sync Camera Roll", @"Title for auto sync camera roll settings on settings screen.");
    }
    else if (indexPath.section == SKYSettingsViewAdvancedSettingsSectionIndex) {
        cell.textLabel.text = NSLocalizedString(@"Advanced Settings", @"Title for advanced settings on settings screen.");
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == SKYSettingsViewPasscodeSectionIndex && indexPath.row == 0) {
		[self.interactionDelegate userWantsToEditPasscode];
	}
	else if (indexPath.section == SKYSettingsViewLogoutSectionIndex) {
		[self.interactionDelegate userWantsToLogOut];
	}
	else if (indexPath.section == SKYSettingsViewLinksSectionIndex) {
		if (indexPath.row == 0) {
			[self.interactionDelegate userWantsToSeeAbout];
		}
		else {
			[self.interactionDelegate userWantsToSeeTechSupport];
		}
	}
    else if (indexPath.section == SKYSettingsViewBackgroundUploadSettingsSectionIndex) {
        [self.interactionDelegate userWantsToGoToBackgroundUploadSettings];
    }
    else if (indexPath.section == SKYSettingsViewAdvancedSettingsSectionIndex) {
        [self.interactionDelegate userWantsToGoToAdvancedSettings];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *titleToReturn = nil;
	
	if (section == SKYSettingsViewCacheLimitSectionIndex) {
		titleToReturn = NSLocalizedString(@"Cache limit", @"Title of cache limit section on settings screen.");
	}
	
	return titleToReturn;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *titleToReturn = nil;
	
	if (section == SKYSettingsViewLinksSectionIndex) {
		titleToReturn = [self.settingsDataSource softwareVersion];
	}
	else if (section == SKYSettingsViewCacheLimitSectionIndex) {
		titleToReturn = NSLocalizedString(@"Favourite files don't sum to this limit.", @"Info for cache limit section on settings screen.");
	}
	else if (section == SKYSettingsViewBigFilesWarningSectionIndex) {
		titleToReturn = NSLocalizedString(@"If enabled, you will be asked for confirmation before downloading or uploading files bigger then 20MB on cellular network.", @"Info for cellular warning section on settings screen.");
	}
	
	return titleToReturn;
}

@end
