//
//  SKYBackgroundUploadSettingsController.m
//  SXDrive
//
//  Created by Skylable on 7/29/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBackgroundUploadSettingsController.h"

#import "SKYConfig.h"
#import "UIFont+SKYFont.h"

NSString *const kUploadToggleCellReuseIdentifier = @"toggleCell";
NSString *const kDestinationCellReuseIdentifier = @"destinationCell";

@interface SKYBackgroundUploadSettingsController ()

- (void)logEnabledMediaUploadSwitchChanged:(UISwitch *)aSwitch;
- (void)logEnabledPhotoUploadOnCellularSwitchChanged:(UISwitch *)aSwitch;
- (void)logEnabledVideoUploadOnCellularSwitchChanged:(UISwitch *)aSwitch;

- (BOOL)uploadOn;
- (NSString *)disaplyDestinationPath;
- (NSString *)destinationFolderName;
- (NSString *)destinationPathForItem:(SKYItem *)item;

@end

@implementation SKYBackgroundUploadSettingsController

static UISwitch *mediaUploadSwitch;

#pragma mark - View life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Synchronization Settings", @"Title for auto sync camera roll settings screen.");
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Convenience accessors

- (id <SKYSettingsBehaviour>)settingsBehaviour
{
    return (id <SKYSettingsBehaviour>)self.baseBehaviour;
}

#pragma mark - Base controller

- (SKYViewType)viewType {
    return SKYViewTypeBackgroundUploadSettings;
}

#pragma mark - Actions

- (void)logEnabledMediaUploadSwitchChanged:(UISwitch *)aSwitch {
    if ([self uploadOn] != aSwitch.on) {
        [SKYConfig setMediaUploadEnabled:aSwitch.on];
        
        if (![self uploadOn]) {
            [SKYConfig setPhotoUploadOnCellularEnabled:NO];
            [SKYConfig setVideoUploadOnCellularEnabled:NO];
        } else {
            if (![SKYConfig mediaUploadDestinationPath])
                [self.settingsBehaviour chooseDifferentDirectory:self];
        }
        
        [self.tableView beginUpdates];
        if ([self uploadOn]) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (void)logEnabledPhotoUploadOnCellularSwitchChanged:(UISwitch *)aSwitch {
    [SKYConfig setPhotoUploadOnCellularEnabled:aSwitch.on];
}

- (void)logEnabledVideoUploadOnCellularSwitchChanged:(UISwitch *)aSwitch {
    [SKYConfig setVideoUploadOnCellularEnabled:aSwitch.on];
}

#pragma mark - Auxiliary

- (void)userDidChooseDirectory:(SKYItem *)item {
    [SKYConfig setMediaUploadDestinationPath:[self destinationPathForItem:item]];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

}

- (void)userDidCancelChoosingDirectory {
    mediaUploadSwitch.on = NO;
    [self logEnabledMediaUploadSwitchChanged:mediaUploadSwitch ];
}

- (BOOL)uploadOn {
    return [SKYConfig mediaUploadEnabled];
}

- (NSString *)disaplyDestinationPath {
    NSString *path = [SKYConfig mediaUploadDestinationPath];
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    return path;
}

- (NSString *)destinationFolderName {
    NSString *path = [SKYConfig mediaUploadDestinationPath];
    return [[path componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)destinationPathForItem:(SKYItem *)item {
    return [NSString stringWithFormat:@"%@%@", item.path, item.name];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self uploadOn] ? 4:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDestinationCellReuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDestinationCellReuseIdentifier];
            cell.textLabel.font = [UIFont fontForDetailCellLabels];
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        }
        cell.textLabel.textColor = [UIColor blackColor];
        NSInteger row = indexPath.row;
        if (row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            cell.imageView.image = [UIImage imageNamed:@"folder"];
            cell.textLabel.text = [self destinationFolderName];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUploadToggleCellReuseIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kUploadToggleCellReuseIdentifier];
            cell.textLabel.font = [UIFont fontForStandardCellLabels];
            cell.detailTextLabel.font = [UIFont fontForDetailCellLabels];
        }
        
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        
        NSInteger section = indexPath.section;
        switch (section) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Upload photos/videos", @"Title for background upload setting toggle to enable background media upload.");
                
                mediaUploadSwitch = [UISwitch new];
                mediaUploadSwitch.on = [self uploadOn];
                [mediaUploadSwitch addTarget:self action:@selector(logEnabledMediaUploadSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = mediaUploadSwitch;
                
                break;
            }
            case 2: {
                cell.textLabel.text = NSLocalizedString(@"Upload photos over cellular network", @"Title for background upload setting toggle to enable photo upload on cellular upload.");
                
                UISwitch *aSwitch = [UISwitch new];
                aSwitch.on = [SKYConfig photoUploadOnCellularEnabled];
                [aSwitch addTarget:self action:@selector(logEnabledPhotoUploadOnCellularSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = aSwitch;
                
                break;
            }
            case 3: {
                cell.textLabel.text = NSLocalizedString(@"Upload videos over cellular network", @"Title for background upload setting toggle to enable photo upload on cellular upload.");
                
                UISwitch *aSwitch = [UISwitch new];
                aSwitch.on = [SKYConfig videoUploadOnCellularEnabled];
                [aSwitch addTarget:self action:@selector(logEnabledVideoUploadOnCellularSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = aSwitch;
                
                break;
            }
        }
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 1 ? NSLocalizedString(@"Destination:", @"Title of destination section header on background upload settings screen."):nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Automatically upload new photos and videos", @"Title of section footer on background upload settings screen.");
        case 1: {
            NSString *text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Saving to:", @"Title of section footer on background upload settings screen."), [self disaplyDestinationPath]];
            return text;
        }
        case 2:
            return NSLocalizedString(@"If turned off, upload photos only when connected to wifi", @"Title of section footer on background upload settings screen.");
        case 3:
            return NSLocalizedString(@"If turned off, upload videos only when connected to wifi", @"Title of section footer on background upload settings screen.");
            
        default:
            return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.settingsBehaviour chooseDifferentDirectory:self];
    }
}

@end
