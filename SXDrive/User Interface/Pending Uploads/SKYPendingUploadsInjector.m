//
//  SKYPendingUploadsInjector.m
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPendingUploadsInjector.h"

#import "SKYAppInjector.h"
#import "SKYPendingUploadsBehaviourImplementation.h"
#import "SKYPendingUploadsController.h"
#import "SKYPendingUploadsViewImplementation.h"
#import "SKYInfoKeys.h"

@interface SKYPendingUploadsInjector ()

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator item:(SKYItem *)item;

@end

@implementation SKYPendingUploadsInjector

+ (id <SKYBaseController>)injectViewControllerWithItem:(SKYItem *)item {
    return [self injectViewControllerWithViewNavigator:nil item:item];
}

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator {
    return [self injectViewControllerWithViewNavigator:viewNavigator item:nil];
}

#pragma mark - Private

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator item:(SKYItem *)item {
    SKYPendingUploadsBehaviourImplementation *behaviour = [[SKYPendingUploadsBehaviourImplementation alloc] init];
    SKYPendingUploadsViewImplementation *view = [[SKYPendingUploadsViewImplementation alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    SKYPendingUploadsController *controller = [[SKYPendingUploadsController alloc] initWithPendingUploadsView:view pendingUploadsBehaviour:behaviour];
    controller.uploadsMode = item != nil ? SKYUploadsModeBuiltIn:SKYUploadsModeSummary;
    behaviour.presenter = controller;
    behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
    behaviour.item = item;
    behaviour.syncService = [SKYAppInjector injectObjectForProtocol:@protocol(SKYSyncService)];
    if (item) {
        behaviour.item = item;
        controller.uploadsMode = SKYUploadsModeBuiltIn;
    } else {
        controller.uploadsMode = SKYUploadsModeSummary;
    }
    if (viewNavigator) {
        behaviour.viewNavigator = viewNavigator;
    }
    view.interactionDelegate = controller;
    view.pendingUploadsDataSource = controller;
    
    return controller;
}

@end
