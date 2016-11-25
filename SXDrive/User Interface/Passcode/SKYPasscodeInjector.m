//
//  SKYPasscodeInjector.m
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPasscodeInjector.h"

#import "SKYAppInjector.h"
#import "SKYPasscodeBehaviourImplementation.h"
#import "SKYPasscodeController.h"
#import "SKYPasscodeViewImplementation.h"
#import "SKYUser.h"

@implementation SKYPasscodeInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYPasscodeBehaviourImplementation *behaviour = [[SKYPasscodeBehaviourImplementation alloc] init];
	SKYPasscodeViewImplementation *view = [[SKYPasscodeViewImplementation alloc] init];
	
	SKYPasscodeController *controller = [[SKYPasscodeController alloc] initWithPasscodeView:view passcodeBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.viewNavigator = viewNavigator;
	behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	view.interactionDelegate = controller;
	
	return controller;
}

@end
