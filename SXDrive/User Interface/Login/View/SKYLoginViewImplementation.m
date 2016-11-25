//
//  SKYLoginViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYLoginViewImplementation.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

/**
 * Footer's height.
 */
static CGFloat const SKYLoginViewFooterHeight = 64.f;

/**
 * Distance between top edge and logo.
 */
static CGFloat const SKYLoginViewDistanceBetweenTopEdgeAndLogo = 94.f;

/**
 * Distance between logo and title.
 */
static CGFloat const SKYLoginViewDistanceBetweenLogoAndTitle = 74.f;

/**
 * Distance between title and subtitle.
 */
static CGFloat const SKYLoginViewDistanceBetweenTitleAndSubtitle = 20.f;

/**
 * Minimum distance between side edges and texts.
 */
static CGFloat const SKYLoginViewMinimumDistanceBetweedSideEdgesAndTexts = 20.f;

@interface SKYLoginViewImplementation ()

@end

@implementation SKYLoginViewImplementation

@synthesize interactionDelegate = _interactionDelegate;

- (void)createSubviews
{
	self.backgroundColor = [UIColor skyMainColor];
	
	UIImageView *topLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-top"]];
	topLogo.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:topLogo];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:topLogo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
//	NSString *string = NSLocalizedString(@"Click on the activation link\nto access [boldAppName].", @"Title on the login screen, [boldAppName] will be replaced with application name");
    NSString *string = NSLocalizedString(@"Click [boldButtonTitle] below\nto access [boldAppName].", @"Title on the login screen, [boldAppName] will be replaced with application name");
    
    NSRange range1 = [string rangeOfString:@"[boldButtonTitle]"];
    NSString *logIn = @"Login";
    string = [string stringByReplacingCharactersInRange:range1 withString:logIn];
    
    NSRange range2 = [string rangeOfString:@"[boldAppName]"];
	NSString *appName = NSLocalizedString(@"SXDrive", @"Bold app name on the login screen");
	string = [string stringByReplacingCharactersInRange:range2 withString:appName];

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttributes:@{NSFontAttributeName: [UIFont fontForLoginScreenTitleAppName]}
                              range:NSMakeRange(range1.location, logIn.length)];
	[attributedString addAttributes:@{NSFontAttributeName: [UIFont fontForLoginScreenTitleAppName]}
							  range:NSMakeRange(range2.location, appName.length)];
	
	UILabel *titleLabel = [UILabel new];
	titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	titleLabel.numberOfLines = 0;
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = [UIFont fontForLoginScreenTitle];
	titleLabel.attributedText = attributedString;
	titleLabel.textColor = [UIColor whiteColor];
	[self addSubview:titleLabel];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:-SKYLoginViewMinimumDistanceBetweedSideEdgesAndTexts * 2]];
	
    UIButton *logInButton = [[UIButton alloc] init];
    [logInButton.layer setCornerRadius:8.0f];
    [logInButton.layer setBorderWidth:1.0f];
    [logInButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    logInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [logInButton setTitle:@"Login" forState:UIControlStateNormal];
    [logInButton.titleLabel setFont:[UIFont fontForLoginScreenButton]];
    [logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logInButton addTarget:self.interactionDelegate action:@selector(userDidPressLogIn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logInButton];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:100.0f]];
    
//	UILabel *subtitleLabel = [UILabel new];
//	subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//	subtitleLabel.numberOfLines = 0;
//	subtitleLabel.textAlignment = NSTextAlignmentCenter;
//	subtitleLabel.font = [UIFont fontForLoginScreenSubtitle];
//	subtitleLabel.text = NSLocalizedString(@"Alternatively copy the text\ncontaining the activation link\nand return to this app.", @"Subtitle on the login screen");
//	subtitleLabel.textColor = [UIColor whiteColor];
//	[self addSubview:subtitleLabel];
//	[self addConstraint:[NSLayoutConstraint constraintWithItem:subtitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
//	[self addConstraint:[NSLayoutConstraint constraintWithItem:subtitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:-SKYLoginViewMinimumDistanceBetweedSideEdgesAndTexts * 2]];

    NSDictionary *views = @{@"logo": topLogo, @"title": titleLabel, @"login": logInButton};
    NSDictionary *metrics = @{@"space1": @(SKYLoginViewDistanceBetweenTopEdgeAndLogo),
                              @"space2": @(SKYLoginViewDistanceBetweenLogoAndTitle),
                              @"space3": @(SKYLoginViewDistanceBetweenTitleAndSubtitle)
                              };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(space1)-[logo]-(space2)-[title]-(space3)-[login]" options:0 metrics:metrics views:views]];
    
//	NSDictionary *views = @{@"logo": topLogo, @"title": titleLabel, @"subtitle": subtitleLabel};
//	NSDictionary *metrics = @{@"space1": @(SKYLoginViewDistanceBetweenTopEdgeAndLogo),
//							  @"space2": @(SKYLoginViewDistanceBetweenLogoAndTitle),
//							  @"space3": @(SKYLoginViewDistanceBetweenTitleAndSubtitle)
//							  };
//	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(space1)-[logo]-(space2)-[title]-(space3)-[subtitle]" options:0 metrics:metrics views:views]];

	UIButton *footerView = [UIButton buttonWithType:UIButtonTypeCustom];
	footerView.translatesAutoresizingMaskIntoConstraints = NO;
	footerView.backgroundColor = [UIColor skyColorForLoginFooter];
	[footerView addTarget:self.interactionDelegate action:@selector(userDidPressLogo) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:footerView];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[footer]|" options:0 metrics:nil views:@{@"footer": footerView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[footer]|" options:0 metrics:nil views:@{@"footer": footerView}]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SKYLoginViewFooterHeight]];
	
	UIImageView *footerLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skylablelogo"]];
	footerLogo.translatesAutoresizingMaskIntoConstraints = NO;
	[footerView addSubview:footerLogo];
	[footerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLogo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[footerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
