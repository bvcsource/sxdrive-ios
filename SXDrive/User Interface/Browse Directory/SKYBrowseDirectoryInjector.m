//
//  SKYBrowseDirectoryInjector.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryInjector.h"

#import "SKYAppInjector.h"
#import "SKYBrowseDirectoryBehaviourImplementation.h"
#import "SKYBrowseDirectoryController.h"
#import "SKYBrowseDirectoryViewImplementation.h"

@implementation SKYBrowseDirectoryInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYBrowseDirectoryBehaviourImplementation *behaviour = [[SKYBrowseDirectoryBehaviourImplementation alloc] init];
	SKYBrowseDirectoryViewImplementation *view = [[SKYBrowseDirectoryViewImplementation alloc] init];
	
	SKYBrowseDirectoryController *controller = [[SKYBrowseDirectoryController alloc] initWithBrowseDirectoryView:view browseDirectoryBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.viewNavigator = viewNavigator;
	behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
    behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	behaviour.syncService = [SKYAppInjector injectObjectForProtocol:@protocol(SKYSyncService)];
	behaviour.networkManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYNetworkManager)];
	behaviour.diskManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYDiskManager)];
	view.interactionDelegate = controller;
	view.browseDirectoryDataSource = controller;
	
	return controller;
}

@end
