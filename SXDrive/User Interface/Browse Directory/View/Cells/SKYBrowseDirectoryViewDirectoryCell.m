//
//  SKYBrowseDirectoryViewDirectoryCell.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewDirectoryCell.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

/**
 * Reuse identifier for SKYBrowseDirectoryViewDirectoryCell.
 */
NSString * const SKYBrowseDirectoryViewDirectoryCellReuseIdentifier = @"SKYBrowseDirectoryViewDirectoryCellReuseIdentifier";

/**
 * Distance between left edge and icon.
 */
static CGFloat const SKYBrowseDirectoryViewDirectoryCellDistanceFromLeftEdgeAndIcon = 8.f;

/**
 * Distance between left edge and name label.
 */
static CGFloat const SKYBrowseDirectoryViewDirectoryCellDistanceFromLeftEdgeAndText = 45.f;

@interface SKYBrowseDirectoryViewDirectoryCell ()

/**
 * Icon displaying directory.
 */
@property (nonatomic, strong) UIImageView *icon;

/**
 * Label displaying name of the directory.
 */
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation SKYBrowseDirectoryViewDirectoryCell

- (void)createSubviews
{
	[super createSubviews];
	
	_nameLabel = [UILabel new];
	_nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	_nameLabel.font = [UIFont fontForDirectoryNamesOnLists];
	[self.contentView addSubview:_nameLabel];
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[nameLabel]-|" options:0 metrics:@{@"margin": @(SKYBrowseDirectoryViewDirectoryCellDistanceFromLeftEdgeAndText)} views:@{@"nameLabel": _nameLabel}]];

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	_icon = [UIImageView new];
	_icon.translatesAutoresizingMaskIntoConstraints = NO;
	_icon.image = [UIImage imageNamed:@"folder"];
	[self.contentView addSubview:_icon];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYBrowseDirectoryViewDirectoryCellDistanceFromLeftEdgeAndIcon]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

}

- (void)fillWithDirectoryName:(NSString *)directoryName
{
	self.nameLabel.text = directoryName;
}

@end
