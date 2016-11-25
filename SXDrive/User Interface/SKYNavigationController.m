//
//  SKYNavigationController.m
//  SXDrive
//
//  Created by Skylable on 13/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYNavigationController.h"

#import "SKYBaseController.h"
#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

@interface SKYNavigationController () <UINavigationControllerDelegate>

/**
 * Common initialization called in typical init cases.
 */
- (void)commonInitialization;

@end

@implementation SKYNavigationController

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		[self commonInitialization];
	}
	
	return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	
	if (self) {
		[self commonInitialization];
	}
	
	return self;
}

- (void)commonInitialization
{
	self.delegate = self;
    
    self.navigationBar.barTintColor = [UIColor skyMainColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.opaque = YES;
    self.navigationBar.translucent = NO;
    self.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationBar setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont fontForBarTexts]
                                                           }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return self.visibleViewController.preferredStatusBarStyle;
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController conformsToProtocol:@protocol(SKYBaseController)]) {
		self.interactivePopGestureRecognizer.enabled = [(id <SKYBaseController>)viewController swipeToPopGestureEnabled];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
