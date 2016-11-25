//
//  SKYBrowseDirectoryMultipleSelectionBottomBar.m
//  SXDrive
//
//  Created by Skylable on 20/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryMultipleSelectionBottomBar.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

/**
 * Distance from right edge to delete button.
 */
static CGFloat const SKYBrowseDirectoryMultipleSelectionBottomBarDistanceFromRightEdgeToDeleteButton = 15.f;

@interface SKYBrowseDirectoryMultipleSelectionBottomBar ()

/**
 * Delete button.
 */
@property (nonatomic, strong) UIButton *deleteButton;

/**
 * Creates subviews.
 */
- (void)createSubviews;

/**
 * Called when delete button was pressed.
 */
- (void)deletePressedDidPress;

@end

@implementation SKYBrowseDirectoryMultipleSelectionBottomBar

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		[self createSubviews];
	}
	
	return self;
}

- (void)createSubviews
{
	UITabBar *backgroundTabBar = [UITabBar new];
	backgroundTabBar.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:backgroundTabBar];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|" options:0 metrics:nil views:@{@"bar": backgroundTabBar}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bar]|" options:0 metrics:nil views:@{@"bar": backgroundTabBar}]];
	
	self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.deleteButton.enabled = NO;
	
	NSString *buttonTitle = NSLocalizedString(@"Delete", @"Delete button on multiple selection view.");
	buttonTitle = [buttonTitle stringByAppendingString:@"  "]; // spacing text from icon
	
	self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.deleteButton setTitleColor:[UIColor skyColorForDelete] forState:UIControlStateNormal];
	[self.deleteButton setTitleColor:[[UIColor skyColorForDelete] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
	[self.deleteButton setTitle:buttonTitle forState:UIControlStateNormal]; // font + color + localization
	[self.deleteButton setTitleColor:[UIColor skyColorForSelectionCheckmark] forState:UIControlStateHighlighted];
	self.deleteButton.titleLabel.font = [UIFont fontForBarTexts];
	[self.deleteButton addTarget:self action:@selector(deletePressedDidPress) forControlEvents:UIControlEventTouchUpInside];
	[self.deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
	[self addSubview:self.deleteButton];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button]-(right)-|" options:0 metrics:@{@"right": @(SKYBrowseDirectoryMultipleSelectionBottomBarDistanceFromRightEdgeToDeleteButton)} views:@{@"button": self.deleteButton}]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	[self.deleteButton sizeToFit];
	self.deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, -self.deleteButton.imageView.frame.size.width, 0, self.deleteButton.imageView.frame.size.width);
	self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.deleteButton.titleLabel.frame.size.width, 0, -self.deleteButton.titleLabel.frame.size.width);
}

- (void)deletePressedDidPress
{
	[self.delegate multipleSelectionBottomBarDidPressDelete:self];
}

- (CGSize)intrinsicContentSize
{
	return CGSizeMake(UIViewNoIntrinsicMetric, [UITabBar new].frame.size.height);
}

- (void)setControlsEnabled:(BOOL)enabled
{
	self.deleteButton.enabled = enabled;
}

@end
