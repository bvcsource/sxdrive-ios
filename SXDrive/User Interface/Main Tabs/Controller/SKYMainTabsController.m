//
//  SKYMainTabsController.m
//  SXDrive
//
//  Created by Skylable on 28/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYMainTabsController.h"

#import "SKYNavigationController.h"

@interface SKYMainTabsController ()

@end

@implementation SKYMainTabsController

@synthesize info = _info;
@synthesize swipeToPopGestureEnabled = _swipeToPopGestureEnabled;
@synthesize baseView = _baseView;
@synthesize baseBehaviour = _baseBehaviour;

- (instancetype)initWithViewNavigator:(id <SKYViewNavigator>)viewNavigator viewControllerFactory:(id <SKYViewControllerFactory>)vcFactory
{
	self = [super init];
	
	if (self) {
		id <SKYBaseController> volumesVC = [vcFactory createViewControllerForViewType:SKYViewTypeVolumes withViewNavigator:viewNavigator];
        id <SKYBaseController> uploadsVC = [vcFactory createViewControllerForViewType:SKYViewTypePendingUploads withViewNavigator:viewNavigator];
		id <SKYBaseController> favouritesVC = [vcFactory createViewControllerForViewType:SKYViewTypeFavourites withViewNavigator:viewNavigator];
		id <SKYBaseController> settingsVC = [vcFactory createViewControllerForViewType:SKYViewTypeSettings withViewNavigator:viewNavigator];
		
		SKYNavigationController *volumesNC = [[SKYNavigationController alloc] initWithRootViewController:[volumesVC viewControler]];
        SKYNavigationController *uploadsNC = [[SKYNavigationController alloc] initWithRootViewController:[uploadsVC viewControler]];
		SKYNavigationController *favouritesNC = [[SKYNavigationController alloc] initWithRootViewController:[favouritesVC viewControler]];
		SKYNavigationController *settingsNC = [[SKYNavigationController alloc] initWithRootViewController:[settingsVC viewControler]];
		
		volumesNC.tabBarItem.title = NSLocalizedString(@"Files", @"Files tab title.");
		volumesNC.tabBarItem.image = [[UIImage imageNamed:@"files-tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		volumesNC.tabBarItem.selectedImage = [[UIImage imageNamed:@"files-tab-focus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        uploadsNC.tabBarItem.title = NSLocalizedString(@"Uploads", @"Uploads tab title.");
        uploadsNC.tabBarItem.image = [[UIImage imageNamed:@"uploads-tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        uploadsNC.tabBarItem.selectedImage = [[UIImage imageNamed:@"uploads-tab-focus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		
		favouritesNC.tabBarItem.title = NSLocalizedString(@"Favourites", @"Favourites tab title.");
		favouritesNC.tabBarItem.image = [[UIImage imageNamed:@"favs-tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		favouritesNC.tabBarItem.selectedImage = [[UIImage imageNamed:@"favs-tab-focus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		
		settingsNC.tabBarItem.title = NSLocalizedString(@"Settings", @"Settings tab title.");
		settingsNC.tabBarItem.image = [[UIImage imageNamed:@"settings-tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		settingsNC.tabBarItem.selectedImage = [[UIImage imageNamed:@"settings-tab-focus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		
		self.viewControllers = @[volumesNC, uploadsNC, favouritesNC, settingsNC];
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeMainTabs;
}

- (UIViewController *)viewControler
{
	return self;
}

@end
