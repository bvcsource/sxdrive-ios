//
//  SKYPasscodeBehaviour.h
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPasscodeStageEnum.h"
#import "SKYUser.h"

/**
 * Presenter for the passcode behaviour.
 */
@protocol SKYPasscodeBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Asks the presenter to set up for given stage.
 * @param passcodeStage Passcode stage.
 */
- (void)configureForStage:(SKYPasscodeStage)passcodeStage;

/**
 * Asks the presenter to display error that the passcode doesn't match the one associated with the user's account.
 */
- (void)displayInvalidCurrentPasscodeError;

/**
 * Asks the presenter to display error that the passcode confirmation doesn't match the proposed new passcode.
 */
- (void)displayInvalidConfirmPasscodeError;

@end

/**
 * Protocol of passcode behaviour.
 */
@protocol SKYPasscodeBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the settings behaviour.
 */
@property (nonatomic, weak) id <SKYPasscodeBehaviourPresenter> presenter;

/**
 * User.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Processes the passcode (i.g. shows the confirm screen or asks the presenter to show invalid passcode error).
 * @param passcode Passcode to process.
 */
- (void)processPasscode:(NSString *)passcode;

/**
 * Logouts the user if user forgot the passcode.
 */
- (void)logoutUser;

@end
