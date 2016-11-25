//
//  SKYBrowseDirectoryViewCell.m
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewCell.h"
#import "UIColor+SKYColor.h"

@implementation SKYBrowseDirectoryViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	
	if (self) {
		[self createSubviews];
	}
	
	return self;
}

- (void)createSubviews
{
	UIView *multipleSelectionBackgroundView = [UIView new];
	multipleSelectionBackgroundView.backgroundColor = [UIColor whiteColor];
	self.multipleSelectionBackgroundView = multipleSelectionBackgroundView;
	
	[self setTintColor:[UIColor skyColorForSelectionCheckmark]];
}

@end
