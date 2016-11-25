//
//  SKYSetupWizardInjector.m
//  SXDrive
//
//  Created by Skylable on 4/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardInjector.h"

#import "SKYAppInjector.h"
#import "SKYSetupWizardBehaviourImplementation.h"
#import "SKYSetupWizardController.h"

@implementation SKYSetupWizardInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator {
    SKYSetupWizardBehaviourImplementation *behaviour = [[SKYSetupWizardBehaviourImplementation alloc] init];
    
    SKYSetupWizardController *controller = [[SKYSetupWizardController alloc] initWithBehaviour:behaviour];
    behaviour.presenter = controller;
    behaviour.viewNavigator = viewNavigator;
    behaviour.user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
    behaviour.errorManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYErrorManager)];
    
    return controller;
}

@end