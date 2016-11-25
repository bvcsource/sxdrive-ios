//
//  SKYSetupWizardBehaviour.h
//  SXDrive
//
//  Created by Skylable on 4/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYErrorManager.h"
#import "SKYUser.h"

/**
 * Presenter for the setup wizard behaviour.
 */
@protocol SKYSetupWizardBehaviourPresenter <SKYBaseBehaviourPresenter>

@property (nonatomic, assign) BOOL logInInProgress;

/**
 * Stops login process
 */
- (void)stopLogin;

/**
 * Finalizes login process
 */
- (void)loginDidFinish;

@end

/**
 * Protocol of setup wizard behaviour.
 */
@protocol SKYSetupWizardBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the setup wizard behaviour.
 */
@property (nonatomic, weak) id <SKYSetupWizardBehaviourPresenter> presenter;

/**
 * Injected user.
 */
@property (nonatomic, weak) id <SKYUser> user;

/**
 * Error manager.
 */
@property (nonatomic, strong) id <SKYErrorManager> errorManager;

- (void)applicationDidFailToRetrieveClusterUUID;

/**
 * Tries to login user with given URL.
 *
 * @param url URL containing credentials.
 */
- (void)loginUserWithURL:(NSURL *)url;

@end