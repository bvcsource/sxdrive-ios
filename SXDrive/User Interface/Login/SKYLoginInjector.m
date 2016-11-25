//
//  SKYLoginInjector.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYLoginInjector.h"

#import "SKYAppInjector.h"
#import "SKYLoginBehaviourImplementation.h"
#import "SKYLoginController.h"
#import "SKYLoginViewImplementation.h"
#import "SKYUser.h"

@implementation SKYLoginInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYLoginBehaviourImplementation *behaviour = [[SKYLoginBehaviourImplementation alloc] init];
	SKYLoginViewImplementation *view = [[SKYLoginViewImplementation alloc] init];
	
	SKYLoginController *controller = [[SKYLoginController alloc] initWithLoginView:view loginBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.viewNavigator = viewNavigator;
	behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	behaviour.errorManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYErrorManager)];
	view.interactionDelegate = controller;
	
	return controller;
}

@end
