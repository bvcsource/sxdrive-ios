//
//  SKYSingleFileInjector.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileInjector.h"

#import "SKYAppInjector.h"
#import "SKYInfoKeys.h"
#import "SKYSingleFileBehaviourImplementation.h"
#import "SKYSingleFileController.h"
#import "SKYSingleFileViewImplementation.h"

@implementation SKYSingleFileInjector

+ (id <SKYBaseController>)injectViewControllerWithItem:(SKYItem *)item
{
	SKYSingleFileBehaviourImplementation *behaviour = [[SKYSingleFileBehaviourImplementation alloc] init];
	SKYSingleFileViewImplementation *view = [[SKYSingleFileViewImplementation alloc] init];
	
	SKYSingleFileController *controller = [[SKYSingleFileController alloc] initWithSingleFileView:view singleFileBehaviour:behaviour];
	behaviour.presenter = controller;
	behaviour.persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	behaviour.syncService = [SKYAppInjector injectObjectForProtocol:@protocol(SKYSyncService)];
	view.interactionDelegate = controller;
	controller.info = @{SKYInfoKeyForItem: item};
	
	return controller;
}

@end
