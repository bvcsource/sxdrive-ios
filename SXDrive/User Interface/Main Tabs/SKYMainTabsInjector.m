//
//  SKYMainTabsInjector.m
//  SXDrive
//
//  Created by Skylable on 28/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYMainTabsInjector.h"

#import "SKYAppInjector.h"
#import "SKYMainTabsController.h"

@implementation SKYMainTabsInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	id <SKYViewControllerFactory> vcFactory = [SKYAppInjector injectObjectForProtocol:@protocol(SKYViewControllerFactory)];
	
	SKYMainTabsController *controller = [[SKYMainTabsController alloc] initWithViewNavigator:viewNavigator viewControllerFactory:vcFactory];
	
	return controller;
}

@end
