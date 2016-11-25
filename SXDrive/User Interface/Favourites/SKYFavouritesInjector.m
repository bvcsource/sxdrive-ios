//
//  SKYFavouritesInjector.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFavouritesInjector.h"

#import "SKYAppInjector.h"
#import "SKYBrowseDirectoryViewImplementation.h"
#import "SKYFavouritesBehaviourImplementation.h"
#import "SKYFavouritesController.h"

@implementation SKYFavouritesInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYFavouritesBehaviourImplementation *behaviour = [[SKYFavouritesBehaviourImplementation alloc] init];
	SKYBrowseDirectoryViewImplementation *view = [[SKYBrowseDirectoryViewImplementation alloc] init];
	
	SKYFavouritesController *controller = [[SKYFavouritesController alloc] initWithBrowseDirectoryView:view favouritesBehaviour:behaviour];
	behaviour.presenter = controller;
    behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	behaviour.viewNavigator = viewNavigator;
	behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	view.interactionDelegate = controller;
	view.browseDirectoryDataSource = controller;
	
	return controller;
}

@end
