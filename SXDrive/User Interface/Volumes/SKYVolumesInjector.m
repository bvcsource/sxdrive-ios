//
//  SKYVolumesInjector.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYVolumesInjector.h"

#import "SKYAppInjector.h"
#import "SKYVolumesBehaviourImplementation.h"
#import "SKYVolumesController.h"
#import "SKYVolumesViewImplementation.h"

@implementation SKYVolumesInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYVolumesBehaviourImplementation *behaviour = [[SKYVolumesBehaviourImplementation alloc] init];
	SKYVolumesViewImplementation *view = [[SKYVolumesViewImplementation alloc] init];
	
	SKYVolumesController *controller = [[SKYVolumesController alloc] initWithVolumesView:view volumesBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.viewNavigator = viewNavigator;
	behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	behaviour.syncService = [SKYAppInjector injectObjectForProtocol:@protocol(SKYSyncService)];
	view.interactionDelegate = controller;
	view.dataSource = controller;
	
	return controller;
}

@end
