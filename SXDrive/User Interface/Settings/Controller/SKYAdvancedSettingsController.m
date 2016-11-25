//
//  SKYAdvancedSettingsController.m
//  SXDrive
//
//  Created by Skylable on 5/19/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYAdvancedSettingsController.h"

#import "UIFont+SKYFont.h"
#import "NSByteCountFormatter+Extras.h"
#import "SKYConfig.h"
#import "SKYNotificationNames.h"

@interface SKYAdvancedSettingsController ()

- (void)logEnabledSwitchChanged:(UISwitch *)aSwitch;
- (void)removeCache;

- (void)refreshNetworkUsageCells;
- (void)refreshDiskUsageSection;

@end

@implementation SKYAdvancedSettingsController

#pragma mark - View life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Advanced Settings", @"Title for advanced advanced settings screen.");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshNetworkUsageCells];
    [self refreshDiskUsageSection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNetworkUsageCells) name:SKYNetworkUsageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDiskUsageSection) name:SKYDiskUsageDidChangeNotification object:nil];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Convenience accessors

- (id <SKYSettingsBehaviour>)settingsBehaviour
{
    return (id <SKYSettingsBehaviour>)self.baseBehaviour;
}

#pragma mark - Base controller

- (SKYViewType)viewType {
    return SKYViewTypeAdvancedSettings;
}

#pragma mark - Actions

- (void)logEnabledSwitchChanged:(UISwitch *)aSwitch {
    [SKYConfig setLogEnabled:aSwitch.on];
}

- (void)removeCache {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure you want to delete local cache?", @"Confirmation question for deleting local cache on advanced settings screen.") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.settingsBehaviour removeCache];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)resetNetworkStatistics {
    [self.settingsBehaviour resetNetworkStatistics];
}

#pragma mark - Auxiliary

- (void)refreshNetworkUsageCells {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshDiskUsageSection {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 5;
        case 2:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont fontForStandardCellLabels];
        cell.detailTextLabel.font = [UIFont fontForDetailCellLabels];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = @"";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0: {
            switch (row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"Inbound", @"Title for received data cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalDataSizeDownloaded].unsignedLongLongValue];
                    
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Outbound", @"Title for send data cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalDataSizeUploaded].unsignedLongLongValue];
                    
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"Reset statistics", @"Title for resetting network data statistics on settings screen.");
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1: {
            switch (row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"Pending upload size", @"Title for penidng upload size cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour pendingUploadSize].unsignedLongLongValue];
                    
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Favourites size", @"Title for favourites size cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour favouritesSize].unsignedLongLongValue];
                    
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"Local cache size", @"Title for local cache size cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour ordinarySize].unsignedLongLongValue];
                    
                    break;
                }
                case 3: {
                    cell.textLabel.text = NSLocalizedString(@"Index size", @"Title for index size cell on advanced settings screen.");
                    cell.detailTextLabel.text = [NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour indexSize].unsignedLongLongValue];
                    
                    break;
                }
                case 4: {
                    cell.textLabel.text = NSLocalizedString(@"Delete local cache", @"Title for deleting local cache on advanced settings screen.");
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 2: {
            cell.textLabel.text = NSLocalizedString(@"Enable Log", @"Title for setting toggle to enable log.");
            
            UISwitch *aSwitch = [UISwitch new];
            aSwitch.on = [SKYConfig logEnabled];
            [aSwitch addTarget:self action:@selector(logEnabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = aSwitch;
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Network traffic", @"Title of disk usage section on advanced settings screen.");
        case 1:
            return NSLocalizedString(@"Disk usage", @"Title of disk usage section on advanced settings screen.");
        case 2:
            return nil;
            
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        NSString *localizedTotal = NSLocalizedString(@"Total: [size].", @"Total disk usage, [size] will be replaced with real size value");
        return [localizedTotal stringByReplacingOccurrencesOfString:@"[size]" withString:[NSByteCountFormatter skyStringWithByteCount:[self.settingsBehaviour totalSize].unsignedLongLongValue]];
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self resetNetworkStatistics];
    }
    if (indexPath.section == 1 && indexPath.row == 4) {
        [self removeCache];
    }
}

@end
