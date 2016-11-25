//
//  SKYLoginController.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYLoginBehaviour.h"
#import "SKYLoginView.h"

/**
 * View controller for login.
 */
@interface SKYLoginController : SKYBaseControllerImplementation <SKYLoginBehaviourPresenter, SKYLoginViewInteractionDelegate>

/**
 * Creates an instance of login controller.
 * @param loginView      Login view to use.
 * @param loginBehaviour Login behaviour to use.
 * @return An instance of login controller.
 */
- (instancetype)initWithLoginView:(UIView <SKYLoginView> *)loginView loginBehaviour:(id <SKYLoginBehaviour>)loginBehaviour;

@end
