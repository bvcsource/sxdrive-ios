//
//  SKYLoginBehaviour.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYErrorManager.h"
#import "SKYUser.h"

/**
 * Presenter for the login behaviour.
 */
@protocol SKYLoginBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Asks user if app should login the user with given URL.
 *
 * @param url URL.
 */
- (void)offerUserToLoginWithURL:(NSURL *)url;

@end

/**
 * Protocol of login behaviour.
 */
@protocol SKYLoginBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the login behaviour.
 */
@property (nonatomic, weak) id <SKYLoginBehaviourPresenter> presenter;

/**
 * Injected user.
 */
@property (nonatomic, weak) id <SKYUser> user;

/**
 * Error manager.
 */
@property (nonatomic, strong) id <SKYErrorManager> errorManager;

/**
 * Presents owner website in Safari.
 */
- (void)presentOwnerWebsite;

/**
 * Tries to login user with given URL.
 *
 * @param url URL containing credentials.
 */
- (void)loginUserWithURL:(NSURL *)url;

/**
 * Presents setup wizard to generate SX key.
 */
- (void)presentSetupWizard;

@end
