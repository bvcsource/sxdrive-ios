//
//  SKYPasscodeController.h
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYPasscodeBehaviour.h"
#import "SKYPasscodeView.h"

/**
 * View controller for passcode.
 */
@interface SKYPasscodeController : SKYBaseControllerImplementation <SKYPasscodeBehaviourPresenter, SKYPasscodeViewInteractionDelegate>

/**
 * Creates an instance of passcode controller.
 * @param passcodeView      Passcode view to use.
 * @param passcodeBehaviour Passcode behaviour to use.
 * @return An instance of passcode controller.
 */
- (instancetype)initWithPasscodeView:(UIView <SKYPasscodeView> *)passcodeView passcodeBehaviour:(id <SKYPasscodeBehaviour>)passcodeBehaviour;

@end
