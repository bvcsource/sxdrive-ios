//
//  SKYViewNavigatorImplementation.h
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

@class SKYNavigationController;

#import "SKYViewNavigator.h"
#import "SKYViewControllerFactory.h"

/**
 * Implementation of the view navigator.
 */
@interface SKYViewNavigatorImplementation : NSObject <SKYViewNavigator>

/**
 * Initialises view navigator.
 * @param viewControllerFactory View controller factory to use when creating views.
 * @param applicationWindow     Application's main window.
 * @return Initialised view navigator.
 */
- (instancetype)initWithViewControllerFactory:(id <SKYViewControllerFactory>)viewControllerFactory applicationWindow:(UIWindow *)applicationWindow;

@end
