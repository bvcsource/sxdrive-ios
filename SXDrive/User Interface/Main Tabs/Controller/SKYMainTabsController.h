//
//  SKYMainTabsController.h
//  SXDrive
//
//  Created by Skylable on 28/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewControllerFactory.h"

/**
 * View controller for main tabs.
 */
@interface SKYMainTabsController : UITabBarController <SKYBaseController>

/**
 * Creates an instance of main tabs controller.
 * @param viewNavigator View navigator to pass to childs.
 * @param vcFactory     View Controller factory to create the childs.
 * @return An instance of main tabs controller.
 */
- (instancetype)initWithViewNavigator:(id <SKYViewNavigator>)viewNavigator viewControllerFactory:(id <SKYViewControllerFactory>)vcFactory;

@end
