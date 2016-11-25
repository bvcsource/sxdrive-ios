//
//  SKYFileViewerInjector.m
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerInjector.h"

#import "SKYAppInjector.h"
#import "SKYFileViewerBehaviourImplementation.h"
#import "SKYFileViewerController.h"
#import "SKYFileViewerViewImplementation.h"

@implementation SKYFileViewerInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYFileViewerBehaviourImplementation *behaviour = [[SKYFileViewerBehaviourImplementation alloc] init];
	SKYFileViewerViewImplementation *view = [[SKYFileViewerViewImplementation alloc] init];
	
	SKYFileViewerController *controller = [[SKYFileViewerController alloc] initWithFileViewerView:view fileViewerBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	behaviour.viewNavigator = viewNavigator;
	view.interactionDelegate = controller;
	view.dataSource = controller;
	
	return controller;
}

@end
