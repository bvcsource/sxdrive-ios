//
//  SKYPendingUploadsViewCell.m
//  SXDrive
//
//  Created by Skylable on 17/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPendingUploadsViewCell.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

NSString * const SKYPendingUploadsViewBuiltInCellReuseIdentifier = @"SKYPendingUploadsViewBuiltInCellReuseIdentifier";
NSString * const SKYPendingUploadsViewSummaryCellReuseIdentifier = @"SKYPendingUploadsViewSummaryCellReuseIdentifier";

/**
 * Distance between left edge and icon.
 */
static CGFloat const SKYPendingUploadsViewCellDistanceFromLeftEdgeAndIcon = 8.f;

/**
 * Distance between right edge and cancel button.
 */
static CGFloat const SKYPendingUploadsViewCellDistanceFromRightEdgeAndButton = 8.f;

/**
 * Distance between left edge and texts.
 */
static CGFloat const SKYPendingUploadsViewCellDistanceFromLeftEdgeAndTexts = 45.f;

@interface SKYPendingUploadsViewCell ()

/**
 * Helper method used to create subviews.
 */
- (void)createSubviews;

/**
 * Called when user presses cancel button.
 */
- (void)cancelButtonDidPress;

/**
 * Icon associated with type of the file.
 */
@property (nonatomic, strong) UIImageView *icon;

/**
 * Label displaying name of the file/directory.
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 * Progress bar to display progress.
 */
@property (nonatomic, strong) UIProgressView *progressBar;

/**
 * Cancel button.
 */
@property (nonatomic, strong) UIButton *cancelButton;

/**
 * Label displaying details of the file:
 * Size and creation/modification date, if upload is completed; destination directory, if upload is in progress.
 */
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation SKYPendingUploadsViewCell

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
	UIView *spacer1 = [UIView new];
	spacer1.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:spacer1];
	UIView *spacer2 = [UIView new];
	spacer2.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:spacer2];
    UIView *spacer3 = [UIView new];
    spacer3.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:spacer3];
    UIView *spacer4 = [UIView new];
    spacer4.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:spacer4];
	
	_icon = [UIImageView new];
	_icon.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:_icon];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYPendingUploadsViewCellDistanceFromLeftEdgeAndIcon]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	_nameLabel = [UILabel new];
	_nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_nameLabel.font = [UIFont fontForFilenameOnLists];
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [_nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	_nameLabel.text = @"a";
	[self.contentView addSubview:_nameLabel];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYPendingUploadsViewCellDistanceFromLeftEdgeAndTexts]];
    
    if ([self.reuseIdentifier isEqualToString:SKYPendingUploadsViewSummaryCellReuseIdentifier]) {
        _detailLabel = [UILabel new];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.font = [UIFont fontForFileInfoTextsOnLists];
        _detailLabel.textColor = [UIColor skyColorForFileInfo];
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        _detailLabel.text = @"a";
        [self.contentView addSubview:_detailLabel];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:SKYPendingUploadsViewCellDistanceFromLeftEdgeAndTexts]];
    }
	
	_progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	_progressBar.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:_progressBar];
	
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_cancelButton addTarget:self action:@selector(cancelButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
	[_cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
	[self.contentView addSubview:_cancelButton];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    NSDictionary *metrics = @{@"left": @(SKYPendingUploadsViewCellDistanceFromLeftEdgeAndTexts), @"right": @(SKYPendingUploadsViewCellDistanceFromRightEdgeAndButton)};
    NSDictionary *views = @{@"spacer1": spacer1, @"spacer2": spacer2, @"spacer3": spacer3, @"spacer4": spacer4, @"nameLabel": _nameLabel, @"bar": _progressBar, @"button": _cancelButton};
    if ([self.reuseIdentifier isEqualToString:SKYPendingUploadsViewSummaryCellReuseIdentifier]) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:views];
        [temp setObject:_detailLabel forKey: @"detailLabel"];
        views = [NSDictionary dictionaryWithDictionary:temp];
    }
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[bar]-[button]-(right)-|" options:0 metrics:metrics views:views]];
    if ([self.reuseIdentifier isEqualToString:SKYPendingUploadsViewSummaryCellReuseIdentifier]) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1(>=0)][nameLabel]-1-[detailLabel][spacer2(==spacer1)]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailLabel][spacer3(>=0)][bar][spacer4(==spacer3)]|" options:0 metrics:nil views:views]];
    } else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1(>=0)][nameLabel][spacer2(==spacer1)]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel][spacer3(>=0)][bar][spacer4(==spacer3)]|" options:0 metrics:nil views:views]];
    }
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:_progressBar attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    if ([self.reuseIdentifier isEqualToString:SKYPendingUploadsViewSummaryCellReuseIdentifier]) {
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:_progressBar attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    }
}

- (void)fillWithName:(NSString *)name detailsText:(NSString *)details progress:(float)progress iconImage:(UIImage *)iconImage path:(NSString *)path
{
    BOOL completed = progress == 1.0;
    self.nameLabel.text = (completed && [self.reuseIdentifier isEqualToString:SKYPendingUploadsViewSummaryCellReuseIdentifier]) ? [NSString stringWithFormat:@"%@/%@", path, name]:name;
    self.detailLabel.text = details;
	self.icon.image = iconImage;
	self.progressBar.progress = progress;
    self.cancelButton.hidden = completed;
    self.progressBar.hidden = self.cancelButton.hidden;
}

- (void)cancelButtonDidPress
{
	[self.interactionDelegate userWantsToCancelUploadAtIndexPath:self.indexPath];
}

@end
