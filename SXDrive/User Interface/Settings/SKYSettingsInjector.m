//
//  SKYSettingsInjector.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSettingsInjector.h"

#import "SKYAppInjector.h"
#import "SKYSettingsBehaviourImplementation.h"
#import "SKYSettingsController.h"
#import "SKYSettingsViewImplementation.h"

@implementation SKYSettingsInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	SKYSettingsBehaviourImplementation *behaviour = [[SKYSettingsBehaviourImplementation alloc] init];
	SKYSettingsViewImplementation *view = [[SKYSettingsViewImplementation alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	
	SKYSettingsController *controller = [[SKYSettingsController alloc] initWithSettingsView:view settingsBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.viewNavigator = viewNavigator;
	behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	behaviour.networkManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYNetworkManager)];
	behaviour.diskManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYDiskManager)];
	view.interactionDelegate = controller;
	view.settingsDataSource = controller;
	
	return controller;
}

@end
