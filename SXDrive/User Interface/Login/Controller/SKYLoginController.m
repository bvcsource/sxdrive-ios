//
//  SKYLoginController.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYLoginController.h"

@interface SKYLoginController () <UIAlertViewDelegate>

/**
 * Property for accessing the login view.
 */
@property (weak, nonatomic, readonly) UIView <SKYLoginView> *loginView;

/**
 * Property for accessing the login behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYLoginBehaviour> loginBehaviour;

/**
 * Keeps info if the login offer is displayed (to avoid duplicating offers).
 */
@property (nonatomic) BOOL isDisplayingLoginOffer;

/**
 * Keeps the login offer URL from behaviour.
 */
@property (nonatomic) NSURL *offerURL;

@end

@implementation SKYLoginController

- (instancetype)initWithLoginView:(UIView<SKYLoginView> *)loginView loginBehaviour:(id<SKYLoginBehaviour>)loginBehaviour
{
	self = [super initWithView:loginView behaviour:loginBehaviour];
	
	if (self) {

	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeLogin;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self.loginBehaviour loginUserWithURL:self.offerURL];
	}
	
	self.isDisplayingLoginOffer = NO;
}

#pragma mark - SKYLoginBehaviourPresenter

- (void)offerUserToLoginWithURL:(NSURL *)url
{
	if (self.isDisplayingLoginOffer == NO) {
		self.isDisplayingLoginOffer = YES;
		self.offerURL = url;
		
		NSString *localizedTitle = NSLocalizedString(@"Use the following activation link?", @"Question to proceed with activation link on the login screen.");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:url.absoluteString delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"Generic no") otherButtonTitles:NSLocalizedString(@"Yes", @"Generic yes"), nil];
		[alert show];
	}
}

#pragma mark - SKYLoginViewInteractionDelegate

- (void)userDidPressLogo
{
	[self.loginBehaviour presentOwnerWebsite];
}

- (void)userDidPressLogIn {
    [self.loginBehaviour presentSetupWizard];
}

#pragma mark - Convenience accessors

- (UIView <SKYLoginView> *)loginView
{
	return (UIView <SKYLoginView> *)self.baseView;
}

- (id <SKYLoginBehaviour>)loginBehaviour
{
	return (id <SKYLoginBehaviour>)self.baseBehaviour;
}

@end
