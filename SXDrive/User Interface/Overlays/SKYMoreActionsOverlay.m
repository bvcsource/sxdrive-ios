//
//  SKYMoreActionsOverlay.m
//  SXDrive
//
//  Created by Skylable on 12/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYMoreActionsOverlay.h"

#import "UIFont+SKYFont.h"
#import "UIColor+SKYColor.h"
#import "UIDevice+ScreenSize.h"

@interface SKYMoreActionsOverlay ()

@end

@implementation SKYMoreActionsOverlay

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.textLabel.textColor = [UIColor skyColorForOverlayCellLabels];
	cell.textLabel.font = [UIFont fontForOverlayCellLabels];
	if (indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Select files", @"Cell title on more actions overlay for turn on the selection mode");
		
		cell.imageView.image = [UIImage imageNamed:@"check"];
	}
	else {
		cell.textLabel.text = NSLocalizedString(@"Sort", @"Cell title on more actions overlay to change sorting");
		
		cell.imageView.image = [UIImage imageNamed:@"sort"];		
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self dismissOverlay];

	if (indexPath.row == 0) {
		[self.delegate moreActionsOverlayDidChangeSelectingState:self];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		NSString *title = NSLocalizedString(@"Change sorting", @"Change sorting box title.");
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:[[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad ? UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
		
		NSString *localizedText1 = NSLocalizedString(@"Sort by name ▲", @"Sorting type on the list for name ascending.");
		[alert addAction:[UIAlertAction actionWithTitle:localizedText1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self.delegate moreActionsOverlay:self didChangeSortingType:SKYConfigSortingTypeByNameAscending];
		}]];
		
		NSString *localizedText2 = NSLocalizedString(@"Sort by name ▼", @"Sorting type on the list for name descending.");
		[alert addAction:[UIAlertAction actionWithTitle:localizedText2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self.delegate moreActionsOverlay:self didChangeSortingType:SKYConfigSortingTypeByNameDescending];
		}]];
		
		NSString *localizedText3 = NSLocalizedString(@"Sort by modification date ▲", @"Sorting type on the list for modification name ascending.");
		[alert addAction:[UIAlertAction actionWithTitle:localizedText3 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self.delegate moreActionsOverlay:self didChangeSortingType:SKYConfigSortingTypeByModificationDateAscending];
		}]];
		
		NSString *localizedText4 = NSLocalizedString(@"Sort by modification date ▼", @"Sorting type on the list for modification name descending.");
		[alert addAction:[UIAlertAction actionWithTitle:localizedText4 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self.delegate moreActionsOverlay:self didChangeSortingType:SKYConfigSortingTypeByModificationDateDescending];
		}]];
		
		[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:nil]];
		
		[self.presentingViewController presentViewController:alert animated:YES completion:nil];
	}
}

@end
