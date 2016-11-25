//
//  SKYAdvancedSettingsInjector.m
//  SXDrive
//
//  Created by Skylable on 5/19/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYAdvancedSettingsInjector.h"

#import "SKYAppInjector.h"
#import "SKYSettingsBehaviourImplementation.h"
#import "SKYAdvancedSettingsController.h"

@implementation SKYAdvancedSettingsInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator {
    SKYSettingsBehaviourImplementation *behaviour = [[SKYSettingsBehaviourImplementation alloc] init];
    
    SKYAdvancedSettingsController *controller = [[SKYAdvancedSettingsController alloc] initWithBehaviour:behaviour];
    behaviour.presenter = controller;
    behaviour.viewNavigator = viewNavigator;
    behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
    behaviour.networkManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYNetworkManager)];
    behaviour.diskManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYDiskManager)];
    
    return controller;
}

@end
