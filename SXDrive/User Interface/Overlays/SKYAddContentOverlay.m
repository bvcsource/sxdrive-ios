//
//  SKYAddContentOverlay.m
//  SXDrive
//
//  Created by Skylable on 11/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYAddContentOverlay.h"

#import "UIFont+SKYFont.h"
#import "UIColor+SKYColor.h"

@interface SKYAddContentOverlay ()

@end

@implementation SKYAddContentOverlay

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
		cell.textLabel.text = NSLocalizedString(@"Add photo from camera roll", @"Cell title on add content overlay for adding new files");
		cell.imageView.image = [UIImage imageNamed:@"add-photo"];
	}
	else {
		cell.textLabel.text = NSLocalizedString(@"Add new folder", @"Cell title on add content overlay for adding new folder");
		cell.imageView.image = [UIImage imageNamed:@"add-folder"];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self dismissOverlay];
	
	if (indexPath.row == 0) {
		[self.delegate addContentOverlayDidChooseAddNewFile:self];
	}
	else {
		[self.delegate addContentOverlayDidChooseAddNewDirectory:self];
	}
}

@end
