//
//  SKYImportFileInjector.m
//  SXDrive
//
//  Created by Skylable on 5/6/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYImportFileInjector.h"

#import "SKYAppInjector.h"
#import "SKYImportFileBehaviourImplementation.h"
#import "SKYImportFileController.h"

@implementation SKYImportFileInjector

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator {
    SKYImportFileBehaviourImplementation *behaviour = [[SKYImportFileBehaviourImplementation alloc] init];
    
    SKYImportFileController *controller = [[SKYImportFileController alloc] initWithBehaviour:behaviour];
    behaviour.presenter = controller;
    behaviour.viewNavigator = viewNavigator;
    behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
    
    return controller;
}

@end
