//
//  SKYVolumesViewCollectionCell.m
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYVolumesViewCollectionCell.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"
#import "UIImage+SKYImage.h"

/**
 * Reuse identifier for SKYVolumesViewCollectionCell.
 */
NSString * const SKYVolumesViewCollectionCellReuseIdentifier = @"SKYVolumesViewCollectionCellReuseIdentifier";

/**
 * Distance between right edge and size label.
 */
static CGFloat const SKYVolumesViewCollectionCellSizeLabelDistanceFromRightEdge = 13.f;

/**
 * Distance between top edge and size label.
 */
static CGFloat const SKYVolumesViewCollectionCellSizeLabelDistanceFromTopEdge = 10.f;

/**
 * Distance between bottom edge and name label.
 */
static CGFloat const SKYVolumesViewCollectionCellNameLabelDistanceFromBottomEdge = 10.f;

/**
 * Distance between top edge and volume icon.
 */
static CGFloat const SKYBrowseDirectoryViewDirectoryCellDistanceBetweenTopEdgeAndVolumeIcon = 25.f;

@interface SKYVolumesViewCollectionCell ()

/**
 * Label to display volume size (in kB, MB...).
 */
@property (nonatomic, strong) UILabel *sizeLabel;

/**
 * Label to display volume name.
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 * Volume's icon image view.
 */
@property (nonatomic, strong) UIImageView *iconImageView;

/**
 * Cell's right separator.
 */
@property (nonatomic, strong) UIView *rightSeparator;

/**
 * Cell's bottom separator.
 */
@property (nonatomic, strong) UIView *bottomSeparator;

/**
 * Helper method to create subviews.
 */
- (void)createSubviews;

@end

@implementation SKYVolumesViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self createSubviews];
	}
	
	return self;
}

- (void)configureCellWithVolumeName:(NSString *)volumeName
						 volumeSize:(NSString *)volumeSize
					 isVolumeLocked:(BOOL)isVolumeLocked
                  isVolumeEncrypted:(BOOL)isVolumeEncrypted
                   selectionEnabled:(BOOL)enabled
{
	self.nameLabel.text = volumeName;
	self.sizeLabel.text = volumeSize;
	self.iconImageView.image = [UIImage iconImageForVolumeLocked:isVolumeLocked encrypted:isVolumeEncrypted];
    self.selectedBackgroundView.backgroundColor = enabled ? [UIColor skySelectionBackgroundColor]:[UIColor whiteColor];
}

- (void)createSubviews
{
	self.rightSeparator = [UIView new];
	self.rightSeparator.translatesAutoresizingMaskIntoConstraints = NO;
	self.rightSeparator.backgroundColor = [UIColor skyGridLinesColor];
	[self.contentView addSubview:self.rightSeparator];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightSeparator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sep]|" options:0 metrics:nil views:@{@"sep": self.rightSeparator}]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sep]|" options:0 metrics:nil views:@{@"sep": self.rightSeparator}]];
	
	self.bottomSeparator = [UIView new];
	self.bottomSeparator.translatesAutoresizingMaskIntoConstraints = NO;
	self.bottomSeparator.backgroundColor = [UIColor skyGridLinesColor];
	[self.contentView addSubview:self.bottomSeparator];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomSeparator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sep]|" options:0 metrics:nil views:@{@"sep": self.bottomSeparator}]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sep]|" options:0 metrics:nil views:@{@"sep": self.bottomSeparator}]];
	
	self.iconImageView = [UIImageView new];
	self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:self.iconImageView];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:SKYBrowseDirectoryViewDirectoryCellDistanceBetweenTopEdgeAndVolumeIcon]];
	
	self.sizeLabel = [UILabel new];
	self.sizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.sizeLabel.textColor = [UIColor skyColorForVolumeSizeText];
	self.sizeLabel.font = [UIFont fontForVolumeSize];
	[self.contentView addSubview:self.sizeLabel];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.sizeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-SKYVolumesViewCollectionCellSizeLabelDistanceFromRightEdge]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.sizeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:SKYVolumesViewCollectionCellSizeLabelDistanceFromTopEdge]];
	
	self.nameLabel = [UILabel new];
	self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.nameLabel.textColor = [UIColor skyMainColor];
	self.nameLabel.textAlignment = NSTextAlignmentCenter;
	self.nameLabel.font = [UIFont fontForVolumeName];
	self.nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	[self.contentView addSubview:self.nameLabel];
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[name]-|" options:0 metrics:nil views:@{@"name": self.nameLabel}]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-SKYVolumesViewCollectionCellNameLabelDistanceFromBottomEdge]];
	
	self.selectedBackgroundView = [UIView new];
}

- (void)setDisplayRightSeparator:(BOOL)displayRightSeparator
{
	self.rightSeparator.hidden = !displayRightSeparator;
}

- (void)setDisplayBottomSeparator:(BOOL)displayBottomSeparator
{
	self.bottomSeparator.hidden = !displayBottomSeparator;
}

@end
