//
//  SKYNoFavouritesCurtain.m
//  SXDrive
//
//  Created by Skylable on 05/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYNoFavouritesCurtain.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

/**
 * Distance between top edge and icon.
 */
static CGFloat const SKYNoFavouritesCurtainDistanceFromTopEdgeAndIcon = 110.f;

/**
 * Distance between icon and title.
 */
static CGFloat const SKYNoFavouritesCurtainDistanceBetweenIconAndTitle = 12.f;

/**
 * Distance between title and subtitle.
 */
static CGFloat const SKYNoFavouritesCurtainDistanceBetweenTitleAndSubtitle = 4.f;

@interface SKYNoFavouritesCurtain ()

/**
 * Creates subviews.
 */
- (void)createSubviews;

@end

@implementation SKYNoFavouritesCurtain

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
	self.backgroundColor = [UIColor whiteColor];
	
	UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favs-blank"]];
	icon.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:icon];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
	UILabel *titleLabel = [UILabel new];
	titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	titleLabel.text = NSLocalizedString(@"You haven't favourite files yet", @"Title on no favourites screen");
	titleLabel.font = [UIFont fontForNoFavouritesTitle];
	[self addSubview:titleLabel];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
	UILabel *subtitleLabel = [UILabel new];
	subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	subtitleLabel.textAlignment = NSTextAlignmentCenter;
	subtitleLabel.numberOfLines = 0;
	subtitleLabel.text = NSLocalizedString(@"Add your favourite files to have\nquick access to them", @"Subtitle on no favourites screen");
	subtitleLabel.font = [UIFont fontForNoFavouritesSubtitle];
	subtitleLabel.textColor = [UIColor skyColorForNoFavouritesSubtitle];
	[self addSubview:subtitleLabel];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:subtitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
	NSDictionary *views = @{@"icon": icon, @"title": titleLabel, @"subtitle": subtitleLabel};
	NSDictionary *metrics = @{
							  @"space1": @(SKYNoFavouritesCurtainDistanceFromTopEdgeAndIcon),
							  @"space2": @(SKYNoFavouritesCurtainDistanceBetweenIconAndTitle),
							  @"space3": @(SKYNoFavouritesCurtainDistanceBetweenTitleAndSubtitle)
							  };
							  
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space1-[icon]-space2-[title]-space3-[subtitle]" options:0 metrics:metrics views:views]];
}

@end
