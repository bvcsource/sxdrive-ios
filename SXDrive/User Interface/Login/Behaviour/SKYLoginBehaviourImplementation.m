//
//  SKYLoginBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYLoginBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"

@interface SKYLoginBehaviourImplementation ()

/**
 * Checks the content of pasteboard and if it the login link is found it tries to log in with it.
 */
- (void)checkPasteboard;

@end

@implementation SKYLoginBehaviourImplementation

@synthesize user = _user;
@synthesize errorManager = _errorManager;

- (void)processInfo:(NSDictionary *)info
{	
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYApplicationReceivedActivationURLNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		[self.presenter offerUserToLoginWithURL:note.userInfo[SKYInfoKeyForURL]];
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		[self checkPasteboard];
	}];
	
	[self checkPasteboard];
}

- (void)loginUserWithURL:(NSURL *)url
{
	[self.user loginUserWithURL:url completion:^(SKYUserLoginResult result) {
		if (result == SKYUserLoginResultSuccess) {
			[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeMainTabs];
		}
		else if (result == SKYUserLoginResultNoNetwork) {
			[self.errorManager displayNoInternetError];
		}
		else if (result == SKYUserLoginResultWrongCredentials) {
			[self.errorManager displayInvalidLoginCredentialsError];
		}
		else if (result == SKYUserLoginResultWrongServer) {
			[self.errorManager displayInvalidLoginServerError];
		}
	}];
}

- (void)checkPasteboard
{
	NSString *pasteboard = [UIPasteboard generalPasteboard].string;
	if (pasteboard != nil) {
		
		NSRegularExpression *regex = [NSRegularExpression
									  regularExpressionWithPattern:@"sx://([0-9a-zA-Z\\.\\-\\_]+)([,;=\\.0-9a-zA-Z\\+/=]+)"
									  options:NSRegularExpressionCaseInsensitive
									  error:NULL];
		[regex enumerateMatchesInString:pasteboard options:0 range:NSMakeRange(0, [pasteboard length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
			
			[UIPasteboard generalPasteboard].string = @"";
			
			NSURL *url = [NSURL URLWithString:[pasteboard substringWithRange:match.range]];
			[self.presenter offerUserToLoginWithURL:url];

			*stop = YES;
		}];
		
	}
}

- (void)presentOwnerWebsite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skylable.com"]];
}

- (void)presentSetupWizard {
    [self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeSetupWizard];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
