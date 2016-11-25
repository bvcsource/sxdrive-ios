//
//  SKYSetupWizardBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 4/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardBehaviourImplementation.h"

@implementation SKYSetupWizardBehaviourImplementation

@synthesize user = _user;
@synthesize errorManager = _errorManager;

- (void)applicationDidFailToRetrieveClusterUUID {
    [self.errorManager displayNoInternetError];
}

- (void)loginUserWithURL:(NSURL *)url {
    if ([self.presenter logInInProgress]) {
        [self.user loginUserWithURL:url completion:^(SKYUserLoginResult result) {
            if ([self.presenter logInInProgress]) {
                if (result == SKYUserLoginResultSuccess) {
                    [self.presenter loginDidFinish];
                    [self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeMainTabs];
                }
                else if (result == SKYUserLoginResultNoNetwork) {
                    [self.errorManager displayNoInternetError];
                    [self.presenter stopLogin];
                }
                else if (result == SKYUserLoginResultWrongCredentials) {
                    [self.errorManager displayInvalidLoginCredentialsError];
                    [self.presenter stopLogin];
                }
                else if (result == SKYUserLoginResultWrongServer) {
                    [self.errorManager displayInvalidLoginServerError];
                    [self.presenter stopLogin];
                }
            }
        }];
    }
}

@end