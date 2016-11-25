//
//  SKYViewControllerFactory.h
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"
#import "SKYViewType.h"

/**
 * Protocol of view controller factory.
 */
@protocol SKYViewControllerFactory <NSObject>

/**
 * Creates a view controller for specified view type.
 * @param viewType      View type.
 * @param viewNavigator View navigator to present the view.
 * @return View controller associated with given type.
 */
- (id <SKYBaseController>)createViewControllerForViewType:(SKYViewType)viewType withViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end
