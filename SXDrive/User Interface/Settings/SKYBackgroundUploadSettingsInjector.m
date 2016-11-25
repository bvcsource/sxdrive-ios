//
//  SKYBackgroundUploadSettingsInjector.m
//  SXDrive
//
//  Created by Skylable on 7/29/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBackgroundUploadSettingsInjector.h"

#import "SKYAppInjector.h"
#import "SKYSettingsBehaviourImplementation.h"
#import "SKYBackgroundUploadSettingsController.h"

@implementation SKYBackgroundUploadSettingsInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator {
    SKYSettingsBehaviourImplementation *behaviour = [[SKYSettingsBehaviourImplementation alloc] init];
    
    SKYBackgroundUploadSettingsController *controller = [[SKYBackgroundUploadSettingsController alloc] initWithBehaviour:behaviour];
    behaviour.presenter = controller;
    behaviour.viewNavigator = viewNavigator;
    behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
    
    return controller;
}

@end
