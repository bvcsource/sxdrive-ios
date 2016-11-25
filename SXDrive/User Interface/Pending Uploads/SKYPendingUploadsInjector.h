//
//  SKYPendingUploadsInjector.h
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

@class SKYItem;

/**
 * Injector for pending uploads section.
 */
@interface SKYPendingUploadsInjector : NSObject

/**
 * Injects a ready to use pending uploads controller.
 * @param item Item (directory) for observing pending changes.
 * @return An instance of pending uploads controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithItem:(SKYItem *)item;

/**
 * Injects a ready to use pending uploads controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of pending uploads controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end
