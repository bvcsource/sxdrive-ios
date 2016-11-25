//
//  SKYBrowseDirectoryViewFileCell.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewFileCell.h"

#import "SKYDownloadProgressLabel.h"
#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"
#import "UIImage+SKYImage.h"

/**
 * Reuse identifier for SKYBrowseDirectoryViewFileCell.
 */
NSString * const SKYBrowseDirectoryViewFileCellReuseIdentifier = @"SKYBrowseDirectoryViewFileCellReuseIdentifier";

/**
 * Distance between left edge and icon.
 */
static CGFloat const SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndIcon = 8.f;

/**
 * Distance between left edge and texts.
 */
static CGFloat const SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndTexts = 45.f;

/**
 * Distance between left edge and star.
 */
static CGFloat const SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndStar = 24.f;

/**
 * Distance between top edge and star.
 */
static CGFloat SKYBrowseDirectoryViewFileCellDistanceFromTopEdgeAndStar = 27.f;

@interface SKYBrowseDirectoryViewFileCell ()

/**
 * Icon associated with type of the file.
 */
@property (nonatomic, strong) UIImageView *icon;

/**
 * Icon identyfying if the file is favourited.
 */
@property (nonatomic, strong) UIImageView *starIcon;

/**
 * Label displaying name of the file.
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 * Label displaying details of the file - size and creation/modification date.
 */
@property (nonatomic, strong) UILabel *detailLabel;

/**
 * Progress label.
 */
@property (nonatomic, strong) SKYDownloadProgressLabel *progressLabel;

@end

@implementation SKYBrowseDirectoryViewFileCell

- (void)createSubviews
{
	[super createSubviews];
	
	UIView *spacer1 = [UIView new];
	spacer1.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:spacer1];
	UIView *spacer2 = [UIView new];
	spacer2.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:spacer2];
	
	_nameLabel = [UILabel new];
	_nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	_nameLabel.font = [UIFont fontForFilenameOnLists];
	[self.contentView addSubview:_nameLabel];
	
	_detailLabel = [UILabel new];
	_detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_detailLabel.font = [UIFont fontForFileInfoTextsOnLists];
	_detailLabel.textColor = [UIColor skyColorForFileInfo];
	[self.contentView addSubview:_detailLabel];
	
	_progressLabel = [SKYDownloadProgressLabel new];
	_progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_progressLabel.font = [UIFont fontForFileInfoTextsOnLists];
	_progressLabel.textColor = [UIColor skyColorForFileInfo];
	[self.contentView addSubview:_progressLabel];
	
	NSDictionary *views = @{@"spacer1": spacer1, @"spacer2": spacer2, @"nameLabel": _nameLabel, @"detailLabel": _detailLabel, @"progressLabel": _progressLabel};
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1(>=0)][nameLabel]-1-[detailLabel][spacer2(==spacer1)]|" options:0 metrics:nil views:views]];
	
	_icon = [UIImageView new];
	_icon.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:_icon];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndIcon]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	_starIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favs-add-icon"]];
	_starIcon.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:_starIcon];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_starIcon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndStar]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_starIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:SKYBrowseDirectoryViewFileCellDistanceFromTopEdgeAndStar]];
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[nameLabel]-|" options:0 metrics:@{@"margin": @(SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndTexts)} views:views]];
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[detailLabel]-[progressLabel]" options:0 metrics:@{@"margin": @(SKYBrowseDirectoryViewFileCellDistanceFromLeftEdgeAndTexts)} views:views]];

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_progressLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_detailLabel attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
}

- (void)fillWithFileName:(NSString *)fileName fileSize:(NSString *)fileSize modificationDate:(NSString *)modificationDate withStar:(BOOL)withStar item:(SKYItem *)item
{
	self.nameLabel.text = fileName;
	self.detailLabel.text = [NSString stringWithFormat:@"%@   %@", fileSize, modificationDate];
	self.icon.image = [UIImage iconImageForFileWithName:fileName];
	self.starIcon.hidden = !withStar;
	self.progressLabel.displayProgressForZero = withStar;
	self.progressLabel.item = item;
	
	[self setNeedsUpdateConstraints];
}

@end
