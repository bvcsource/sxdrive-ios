//
//  SKYMainTabsInjector.h
//  SXDrive
//
//  Created by Skylable on 28/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewControllerFactory.h"
#import "SKYViewNavigator.h"

/**
 * Injector for main tabs section.
 */
@interface SKYMainTabsInjector : NSObject

/**
 * Injects a ready to use main tabs controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of main tabs controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end
